WITH mtd_cost_by_email AS (
    SELECT 
        SPLIT(user_email, '@')[OFFSET(0)] AS name,
        COUNT(DISTINCT(job_id)) as job_count,
        ROUND(SUM(total_bytes_billed / POWER(2, 40)),6) * 8.6088832727448512 as estimated_usd_cost
    FROM 
        `region-asia-southeast1.INFORMATION_SCHEMA.JOBS`
    WHERE
        TIMESTAMP_TRUNC(creation_time, MONTH) = TIMESTAMP_TRUNC(CURRENT_TIMESTAMP(), MONTH)
    GROUP BY user_email 
    ORDER BY estimated_usd_cost DESC
)
SELECT * FROM mtd_cost_by_email