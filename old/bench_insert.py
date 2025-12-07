#!/usr/bin/env python3
"""
Insert/Delete RAM comparison for users_int vs users_varchar.
"""

import argparse
import random
import time
import uuid

import MySQLdb  # pip install mysqlclient

MEMORY_QUERY = """
SELECT event_name, current_number_of_bytes_used
FROM performance_schema.memory_summary_by_thread_by_event_name
WHERE thread_id = %s
"""
THREAD_ID_QUERY = """
SELECT thread_id
FROM performance_schema.threads
WHERE PROCESSLIST_ID = %s
"""

INSERT_INT = "INSERT INTO users_int (id, data) VALUES (%s, %s)"
DELETE_INT = "DELETE FROM users_int WHERE id = %s"
INSERT_VARCHAR = "INSERT INTO users_varchar (id, data) VALUES (%s, %s)"
DELETE_VARCHAR = "DELETE FROM users_varchar WHERE id = %s"


def parse_args():
    parser = argparse.ArgumentParser(
        description="Measure RAM impact of inserting + deleting rows on INT vs VARCHAR indexes."
    )
    parser.add_argument("--host", default="127.0.0.1")
    parser.add_argument("--port", type=int, default=3306)
    parser.add_argument("--user", default="root")
    parser.add_argument("--password", default="1234")
    parser.add_argument("--database", required=True)
    parser.add_argument("--iterations", type=int, default=200)
    parser.add_argument(
        "--base-id",
        type=int,
        default=2_000_000,
        help="Starting ID to avoid clashing with existing rows.",
    )
    parser.add_argument(
        "--wait-ms",
        type=int,
        default=25,
        help="Pause between operations to give the performance schema time to update.",
    )
    parser.add_argument("--seed", type=int, default=7)
    return parser.parse_args()


def connect(opts):
    return MySQLdb.connect(
        host=opts.host,
        port=opts.port,
        user=opts.user,
        password=opts.password,
        database=opts.database,
        autocommit=True,
    )


def get_thread_id(conn):
    with conn.cursor() as cur:
        cur.execute("SELECT CONNECTION_ID()")
        cid = cur.fetchone()[0]
    with conn.cursor() as cur:
        cur.execute(THREAD_ID_QUERY, (cid,))
        return int(cur.fetchone()[0])


def sum_thread_memory(conn, thread_id):
    with conn.cursor() as cur:
        cur.execute(MEMORY_QUERY, (thread_id,))
        return sum(row[1] or 0 for row in cur.fetchall())


def run_cycles(conn, thread_id, insert_sql, delete_sql, values, wait_ms):
    cursor = conn.cursor()
    baseline = sum_thread_memory(conn, thread_id)
    peak_insert_delta = 0
    peak_delete_delta = 0
    try:
        for row_id, payload in values:
            cursor.execute(insert_sql, (row_id, payload))
            peak_insert_delta = max(
                peak_insert_delta, sum_thread_memory(conn, thread_id) - baseline
            )
            if wait_ms:
                time.sleep(wait_ms / 1000)
            cursor.execute(delete_sql, (row_id,))
            peak_delete_delta = max(
                peak_delete_delta, sum_thread_memory(conn, thread_id) - baseline
            )
            if wait_ms:
                time.sleep(wait_ms / 1000)
    finally:
        cursor.close()
    return peak_insert_delta / 1024.0, peak_delete_delta / 1024.0


def build_payloads(args):
    rng = random.Random(args.seed)
    ids = [args.base_id + i for i in range(args.iterations)]
    return [(i, f"data-{i}-{uuid.UUID(int=rng.getrandbits(128))}") for i in ids]


def measure_for_table(args, insert_sql, delete_sql, values):
    conn = connect(args)
    try:
        tid = get_thread_id(conn)
        return run_cycles(conn, tid, insert_sql, delete_sql, values, args.wait_ms)
    finally:
        conn.close()


def main():
    args = parse_args()
    payloads = build_payloads(args)
    int_stats = measure_for_table(args, INSERT_INT, DELETE_INT, payloads)
    varchar_payloads = [(str(pid), payload) for pid, payload in payloads]
    varchar_stats = measure_for_table(
        args, INSERT_VARCHAR, DELETE_VARCHAR, varchar_payloads
    )
    print("Peak RAM delta (KB) per phase")
    print(f"{'Table':<15}{'Insert Peak':>15}{'Delete Peak':>15}")
    print(f"{'users_int':<15}{int_stats[0]:>15.2f}{int_stats[1]:>15.2f}")
    print(f"{'users_varchar':<15}{varchar_stats[0]:>15.2f}{varchar_stats[1]:>15.2f}")


if __name__ == "__main__":
    main()
