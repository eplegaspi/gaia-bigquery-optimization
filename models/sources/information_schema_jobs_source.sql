{% set partitions_to_replace = [
      'timestamp(current_date)',
      'timestamp(date_sub(current_date, interval 1 day))'
] %}

{{ 
   config(
          materialized='incremental',
          partition_by = { 'field': 'creation_time', 'data_type': 'timestamp' },
          incremental_strategy = 'insert_overwrite',
          partitions = partitions_to_replace,
          cluster_by = "user_email",      
        )
}}

WITH events AS(
  SELECT
    user_email,
    job_id,
    creation_time,
    query,
    total_bytes_billed / POWER(2, 40) as total_billed_tb
  FROM
    `region-asia-southeast1.INFORMATION_SCHEMA.JOBS`
  WHERE 1=1
  {% if is_incremental() %}
          -- recalculate yesterday
          AND timestamp_trunc(creation_time, day) in ({{ partitions_to_replace | join(',') }})
  {% endif %}
)
SELECT * FROM events