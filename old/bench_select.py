import argparse
import math
import random
import statistics
import time

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
INT_SELECT = "SELECT data FROM users_int WHERE id = %s"
VARCHAR_SELECT = "SELECT data FROM users_varchar WHERE id = %s"


def parse_args():
    parser = argparse.ArgumentParser(
        description="Compare RAM pressure when hitting INT vs VARCHAR indexes."
    )
    parser.add_argument("--host", default="127.0.0.1")
    parser.add_argument("--port", type=int, default=3306)
    parser.add_argument("--user", default="root")
    parser.add_argument("--password", default="1234")
    parser.add_argument("--database", required=True)
    parser.add_argument(
        "--iterations",
        type=int,
        default=75,
        help="Number of indexed lookups to perform per table.",
    )
    parser.add_argument("--min-id", type=int, default=1)
    parser.add_argument(
        "--max-id",
        type=int,
        default=100000,
        help="Upper bound of the IDs inserted by appendices/mysqlscript.sql.",
    )
    parser.add_argument(
        "--wait-ms",
        type=int,
        default=50,
        help="Optional pause between iterations so performance_schema can settle.",
    )
    parser.add_argument(
        "--seed",
        type=int,
        default=42,
        help="Seed used to pick the same IDs for both comparisons.",
    )
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
        connection_id = cur.fetchone()[0]
    with conn.cursor() as cur:
        cur.execute(THREAD_ID_QUERY, (connection_id,))
        return int(cur.fetchone()[0])


def sum_thread_memory(conn, thread_id):
    with conn.cursor() as cur:
        cur.execute(MEMORY_QUERY, (thread_id,))
        rows = cur.fetchall()
    return sum(row[1] or 0 for row in rows)


def percentile(values, pct):
    if not values:
        return 0.0
    sorted_vals = sorted(values)
    k = (len(sorted_vals) - 1) * (pct / 100.0)
    floor = math.floor(k)
    ceil = math.ceil(k)
    if floor == ceil:
        return sorted_vals[int(k)]
    return sorted_vals[floor] * (ceil - k) + sorted_vals[ceil] * (k - floor)


def run_measurement(conn, thread_id, query, values, wait_ms):
    peak_delta = 0
    timings = []
    baseline = sum_thread_memory(conn, thread_id)
    cursor = conn.cursor()
    try:
        for value in values:
            start = time.perf_counter()
            cursor.execute(query, (value,))
            cursor.fetchall()
            timings.append((time.perf_counter() - start) * 1000.0)
            current = sum_thread_memory(conn, thread_id)
            peak_delta = max(peak_delta, current - baseline)
            if wait_ms:
                time.sleep(wait_ms / 1000.0)
    finally:
        cursor.close()
    return {
        "peak_kb": peak_delta / 1024.0,
        "avg_ms": statistics.fmean(timings) if timings else 0.0,
        "p95_ms": percentile(timings, 95),
        "iterations": len(values),
    }


def pick_ids(args):
    rng = random.Random(args.seed)
    population = range(args.min_id, args.max_id + 1)
    if args.iterations > (args.max_id - args.min_id + 1):
        raise ValueError("iterations exceed available ID range")
    return rng.sample(population, args.iterations)


def measure_table(args, query, values):
    conn = connect(args)
    try:
        tid = get_thread_id(conn)
        return run_measurement(conn, tid, query, values, args.wait_ms)
    finally:
        conn.close()


def print_report(int_stats, varchar_stats):
    print("\nRAM impact per index type")
    print(f"{'Table':<15}{'Peak KB':>12}{'Avg ms':>12}{'p95 ms':>12}{'Samples':>12}")
    print(
        f"{'users_int':<15}"
        f"{int_stats['peak_kb']:>12.2f}"
        f"{int_stats['avg_ms']:>12.3f}"
        f"{int_stats['p95_ms']:>12.3f}"
        f"{int_stats['iterations']:>12d}"
    )
    print(
        f"{'users_varchar':<15}"
        f"{varchar_stats['peak_kb']:>12.2f}"
        f"{varchar_stats['avg_ms']:>12.3f}"
        f"{varchar_stats['p95_ms']:>12.3f}"
        f"{varchar_stats['iterations']:>12d}"
    )


def main():
    args = parse_args()
    sample_ids = pick_ids(args)
    int_stats = measure_table(args, INT_SELECT, sample_ids)
    varchar_values = [str(value) for value in sample_ids]
    varchar_stats = measure_table(args, VARCHAR_SELECT, varchar_values)
    print_report(int_stats, varchar_stats)


if __name__ == "__main__":
    main()
