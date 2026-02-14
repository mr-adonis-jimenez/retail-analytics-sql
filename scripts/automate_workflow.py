#!/usr/bin/env python3
"""Workflow automation for retail analytics - validates, optimizes, and monitors the database"""
import os
import sys
import logging
import psycopg2

logging.basicConfig(level=logging.INFO, format="%(asctime)s [%(levelname)s] %(message)s")
logger = logging.getLogger(__name__)

DB_CONFIG = {
    "dbname": os.getenv("PGDATABASE", "retail_analytics"),
    "user": os.getenv("PGUSER", "postgres"),
    "password": os.getenv("PGPASSWORD", "postgres"),
    "host": os.getenv("PGHOST", "localhost"),
    "port": os.getenv("PGPORT", "5432"),
}

SQL_DIR = os.path.dirname(os.path.abspath(__file__))
PROJECT_ROOT = os.path.dirname(SQL_DIR)

WORKFLOW_STEPS = [
    ("Schema Setup", os.path.join(PROJECT_ROOT, "schema", "schema.sql")),
    ("Data Quality Checks", os.path.join(PROJECT_ROOT, "validation", "data_quality_checks.sql")),
    ("KPI Dashboard", os.path.join(PROJECT_ROOT, "analytics", "kpi_dashboard.sql")),
    ("Performance Analysis", os.path.join(PROJECT_ROOT, "admin", "performance_analysis.sql")),
]


def connect_db():
    """Establish database connection."""
    try:
        conn = psycopg2.connect(**DB_CONFIG)
        logger.info("Connected to database: %s", DB_CONFIG["dbname"])
        return conn
    except psycopg2.OperationalError as e:
        logger.error("Database connection failed: %s", e)
        raise


def run_sql_file(conn, label, filepath):
    """Execute a SQL file against the database."""
    if not os.path.isfile(filepath):
        logger.warning("Skipping %s: file not found (%s)", label, filepath)
        return False

    logger.info("Running %s (%s)...", label, os.path.basename(filepath))
    cur = conn.cursor()
    try:
        with open(filepath, "r") as f:
            cur.execute(f.read())
        conn.commit()
        logger.info("%s completed successfully.", label)
        return True
    except psycopg2.Error as e:
        logger.error("%s failed: %s", label, e)
        conn.rollback()
        return False
    finally:
        cur.close()


def run_workflow():
    """Execute the full analytics workflow."""
    logger.info("Starting retail analytics workflow")

    try:
        conn = connect_db()
    except Exception:
        logger.error("Cannot proceed without database connection.")
        return False

    success_count = 0
    fail_count = 0

    try:
        for label, filepath in WORKFLOW_STEPS:
            if run_sql_file(conn, label, filepath):
                success_count += 1
            else:
                fail_count += 1
    finally:
        conn.close()
        logger.info("Database connection closed.")

    logger.info("Workflow complete: %d succeeded, %d failed", success_count, fail_count)
    return fail_count == 0


if __name__ == "__main__":
    ok = run_workflow()
    sys.exit(0 if ok else 1)
