-- =========================
-- Database Performance Analysis
-- Monitoring & Optimization Queries
-- =========================

-- =========================
-- 1. TABLE SIZE ANALYSIS
-- =========================

-- View table sizes and row counts
SELECT 
    schemaname,
    tablename,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS total_size,
    pg_size_pretty(pg_relation_size(schemaname||'.'||tablename)) AS table_size,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename) - pg_relation_size(schemaname||'.'||tablename)) AS indexes_size,
    n_live_tup AS row_count,
    n_dead_tup AS dead_rows
FROM pg_stat_user_tables
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;

-- =========================
-- 2. INDEX USAGE STATISTICS
-- =========================

-- Check which indexes are being used
SELECT 
    schemaname,
    tablename,
    indexname,
    idx_scan AS index_scans,
    idx_tup_read AS tuples_read,
    idx_tup_fetch AS tuples_fetched,
    pg_size_pretty(pg_relation_size(indexrelid)) AS index_size
FROM pg_stat_user_indexes
ORDER BY idx_scan DESC;

-- Find unused indexes (candidates for removal)
SELECT 
    schemaname,
    tablename,
    indexname,
    idx_scan AS index_scans,
    pg_size_pretty(pg_relation_size(indexrelid)) AS index_size
FROM pg_stat_user_indexes
WHERE idx_scan = 0
  AND indexrelname NOT LIKE '%_pkey'
ORDER BY pg_relation_size(indexrelid) DESC;

-- =========================
-- 3. QUERY PERFORMANCE
-- =========================

-- Most frequently executed queries (requires pg_stat_statements extension)
-- To enable: CREATE EXTENSION IF NOT EXISTS pg_stat_statements;

SELECT 
    query,
    calls,
    ROUND(total_exec_time::NUMERIC / 1000, 2) AS total_time_seconds,
    ROUND((total_exec_time / calls)::NUMERIC / 1000, 2) AS avg_time_seconds,
    ROUND((100 * total_exec_time / SUM(total_exec_time) OVER())::NUMERIC, 2) AS pct_total_time
FROM pg_stat_statements
WHERE query NOT LIKE '%pg_stat_statements%'
ORDER BY total_exec_time DESC
LIMIT 20;

-- Slowest queries by average execution time
SELECT 
    query,
    calls,
    ROUND((total_exec_time / calls)::NUMERIC / 1000, 2) AS avg_time_seconds,
    ROUND(min_exec_time::NUMERIC / 1000, 2) AS min_time_seconds,
    ROUND(max_exec_time::NUMERIC / 1000, 2) AS max_time_seconds
FROM pg_stat_statements
WHERE query NOT LIKE '%pg_stat_statements%'
  AND calls > 10
ORDER BY (total_exec_time / calls) DESC
LIMIT 20;

-- =========================
-- 4. TABLE BLOAT ANALYSIS
-- =========================

-- Identify tables that may need VACUUM
SELECT 
    schemaname,
    tablename,
    n_live_tup AS live_rows,
    n_dead_tup AS dead_rows,
    ROUND((n_dead_tup::NUMERIC / NULLIF(n_live_tup, 0) * 100), 2) AS dead_row_pct,
    last_vacuum,
    last_autovacuum,
    last_analyze,
    last_autoanalyze
FROM pg_stat_user_tables
WHERE n_dead_tup > 0
ORDER BY n_dead_tup DESC;

-- =========================
-- 5. CONNECTION STATISTICS
-- =========================

-- Active connections and their states
SELECT 
    datname AS database,
    usename AS username,
    application_name,
    client_addr,
    state,
    COUNT(*) AS connection_count
FROM pg_stat_activity
WHERE datname IS NOT NULL
GROUP BY datname, usename, application_name, client_addr, state
ORDER BY connection_count DESC;

-- Long-running queries (running > 5 minutes)
SELECT 
    pid,
    usename,
    datname,
    state,
    ROUND(EXTRACT(EPOCH FROM (NOW() - query_start))::NUMERIC, 2) AS duration_seconds,
    query
FROM pg_stat_activity
WHERE state != 'idle'
  AND query_start < NOW() - INTERVAL '5 minutes'
ORDER BY query_start;

-- =========================
-- 6. CACHE HIT RATIOS
-- =========================

-- Table cache hit ratio (should be > 99%)
SELECT 
    'Table Cache Hit Ratio' AS metric,
    ROUND(
        (SUM(heap_blks_hit)::NUMERIC / NULLIF(SUM(heap_blks_hit) + SUM(heap_blks_read), 0) * 100), 
        2
    ) AS percentage
FROM pg_statio_user_tables;

-- Index cache hit ratio (should be > 99%)
SELECT 
    'Index Cache Hit Ratio' AS metric,
    ROUND(
        (SUM(idx_blks_hit)::NUMERIC / NULLIF(SUM(idx_blks_hit) + SUM(idx_blks_read), 0) * 100), 
        2
    ) AS percentage
FROM pg_statio_user_indexes;

-- =========================
-- 7. SEQUENTIAL SCANS
-- =========================

-- Tables with high sequential scan counts (may need indexes)
SELECT 
    schemaname,
    tablename,
    seq_scan AS sequential_scans,
    seq_tup_read AS rows_read_sequentially,
    idx_scan AS index_scans,
    n_live_tup AS row_count,
    ROUND((seq_scan::NUMERIC / NULLIF(idx_scan, 0)), 2) AS seq_to_idx_ratio
FROM pg_stat_user_tables
WHERE seq_scan > 0
ORDER BY seq_scan DESC;

-- =========================
-- 8. WRITE OPERATIONS
-- =========================

-- Tables with most write activity
SELECT 
    schemaname,
    tablename,
    n_tup_ins AS inserts,
    n_tup_upd AS updates,
    n_tup_del AS deletes,
    (n_tup_ins + n_tup_upd + n_tup_del) AS total_writes
FROM pg_stat_user_tables
ORDER BY total_writes DESC;

-- =========================
-- 9. LOCK MONITORING
-- =========================

-- Current locks in the database
SELECT 
    l.locktype,
    l.relation::regclass AS table_name,
    l.mode,
    l.granted,
    a.usename,
    a.query,
    a.state
FROM pg_locks l
JOIN pg_stat_activity a ON l.pid = a.pid
WHERE l.relation IS NOT NULL
ORDER BY l.granted, l.relation;

-- =========================
-- 10. RECOMMENDATIONS
-- =========================

-- Generate optimization recommendations
WITH stats AS (
    SELECT 
        schemaname,
        tablename,
        seq_scan,
        idx_scan,
        n_live_tup,
        n_dead_tup
    FROM pg_stat_user_tables
)
SELECT 
    'Consider adding index' AS recommendation_type,
    tablename,
    'High sequential scans: ' || seq_scan || ' (Table has ' || n_live_tup || ' rows)' AS reason
FROM stats
WHERE seq_scan > 1000 
  AND n_live_tup > 10000
  AND (idx_scan = 0 OR seq_scan::NUMERIC / NULLIF(idx_scan, 0) > 10)

UNION ALL

SELECT 
    'Run VACUUM ANALYZE',
    tablename,
    'High dead row percentage: ' || ROUND((n_dead_tup::NUMERIC / NULLIF(n_live_tup, 0) * 100), 2) || '%'
FROM stats
WHERE n_dead_tup::NUMERIC / NULLIF(n_live_tup, 0) > 0.2
  AND n_dead_tup > 1000

ORDER BY recommendation_type, tablename;
