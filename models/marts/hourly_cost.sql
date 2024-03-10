{{ config(materialized='table') }}

WITH hourly_cost AS (
    SELECT 
        FORMAT_TIMESTAMP('%d %H', creation_time)  AS hour_of_day,
        COUNT(DISTINCT(job_id)) as job_count,
        ROUND(SUM(total_bytes_billed / POWER(2, 40)),6) * 8.6088832727448512 as estimated_usd_cost
    FROM  `region-asia-southeast1.INFORMATION_SCHEMA.JOBS`
    WHERE timestamp_trunc(creation_time, day) in (timestamp(current_date), timestamp(date_sub(current_date, interval 1 day)))
    GROUP BY hour_of_day
    ORDER BY estimated_usd_cost DESC
)
SELECT * FROM hourly_cost