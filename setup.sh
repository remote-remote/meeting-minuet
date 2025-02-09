#!/usr/bin/env bash
set -e

# Define locations and port
DATA_DIR="tmp/pgdata"
LOG_FILE="${DATA_DIR}/pg.log"
PORT=5432

if [ ! -f "$DATA_DIR/PG_VERSION" ]; then
  initdb -D $DATA_DIR
fi

echo "Using data directory: ${DATA_DIR}"
echo "Log file: ${LOG_FILE}"

# Initialize the data directory if it doesn't exist
if [ ! -d "${DATA_DIR}" ]; then
    echo "Data directory not found. Initializing a new PostgreSQL database..."
    mkdir -p "${DATA_DIR}"
    initdb -D "${DATA_DIR}"
fi

# Start PostgreSQL using pg_ctl and log output to the log file
echo "Starting PostgreSQL..."
pg_ctl -D "${DATA_DIR}" -l "${LOG_FILE}" start

# Wait for PostgreSQL to become available
echo "Waiting for PostgreSQL to become ready..."
until pg_isready -h localhost -p "${PORT}" > /dev/null 2>&1; do
    sleep 1
done

# Set the password for user 'postgres'
echo "Configuring the postgres user..."
psql -d postgres -c "CREATE USER postgres WITH SUPERUSER PASSWORD 'postgres'"

echo "PostgreSQL is running."
echo "Data directory: ${DATA_DIR}"
echo "Log file: ${LOG_FILE}"

mix ecto.create
