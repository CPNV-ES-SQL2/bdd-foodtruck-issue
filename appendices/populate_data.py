#!/usr/bin/env python3
import mysql.connector
from faker import Faker
import sys
from datetime import datetime

# Configuration
DB_CONFIG = {
    "host": "localhost",
    "user": "root",
    "password": "1234",  # Update with your MySQL password
    "database": "index_demo",
}

BATCH_SIZE = 10000  # Insert in batches for better performance
TOTAL_RECORDS = 10000000


def create_connection():
    try:
        conn = mysql.connector.connect(**DB_CONFIG)
        return conn
    except mysql.connector.Error as err:
        print(f"Error connecting to MySQL: {err}")
        sys.exit(1)


def generate_batch(fake, batch_size):
    batch = []
    for _ in range(batch_size):
        record = (
            fake.first_name(),
            fake.last_name(),
            fake.email(),
            fake.phone_number(),
            fake.street_address(),
            fake.city(),
            fake.canton()[1],
            fake.postcode(),
            fake.country(),
            fake.date_of_birth(minimum_age=18, maximum_age=90),
        )
        batch.append(record)
    return batch


def populate_database():
    print("Starting data population...")
    print(f"Target: {TOTAL_RECORDS:,} records")
    print(f"Batch size: {BATCH_SIZE:,}")

    fake = Faker("fr_CH")
    conn = create_connection()
    cursor = conn.cursor()

    # Disable autocommit and keys for faster inserts
    cursor.execute("SET autocommit=0")
    cursor.execute("ALTER TABLE personas DISABLE KEYS")

    insert_query = """
        INSERT INTO personas 
        (first_name, last_name, email, phone, address, city, state, zip_code, country, date_of_birth)
        VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
    """

    total_inserted = 0
    start_time = datetime.now()

    try:
        while total_inserted < TOTAL_RECORDS:
            # Generate batch
            batch = generate_batch(fake, BATCH_SIZE)

            # Insert batch
            cursor.executemany(insert_query, batch)
            conn.commit()

            total_inserted += len(batch)

            # Progress update every 100k records
            if total_inserted % 100000 == 0:
                elapsed = (datetime.now() - start_time).total_seconds()
                rate = total_inserted / elapsed if elapsed > 0 else 0
                percentage = (total_inserted / TOTAL_RECORDS) * 100
                print(
                    f"Progress: {total_inserted:,} / {TOTAL_RECORDS:,} ({percentage:.1f}%) - "
                    f"Rate: {rate:.0f} records/sec"
                )

        # Re-enable keys
        print("\nRe-enabling keys...")
        cursor.execute("ALTER TABLE personas ENABLE KEYS")

        total_time = (datetime.now() - start_time).total_seconds()
        print(f"\n✓ Successfully inserted {total_inserted:,} records")
        print(
            f"Total time: {total_time:.2f} seconds ({total_inserted/total_time:.0f} records/sec)"
        )

    except mysql.connector.Error as err:
        print(f"\n✗ Error during insertion: {err}")
        conn.rollback()
        sys.exit(1)
    except KeyboardInterrupt:
        print("\n\n✗ Operation interrupted by user")
        conn.rollback()
        sys.exit(1)
    finally:
        cursor.close()
        conn.close()


def main():
    print("=" * 70)
    print("MySQL Index Demo - Data Population Script")
    print("=" * 70)
    print()

    # Check if user wants to proceed
    response = input(f"This will insert {TOTAL_RECORDS:,} records. Continue? (y/n): ")
    if response.lower() != "y":
        print("Operation cancelled.")
        sys.exit(0)

    populate_database()

    print("\n" + "=" * 70)
    print("Data population complete!")
    print("=" * 70)


if __name__ == "__main__":
    main()
