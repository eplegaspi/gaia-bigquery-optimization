{% set partitions_to_replace = [
      'current_date("UTC")',
      'date_sub(current_date("UTC"), interval 1 day)',
      'date_sub(current_date("UTC"), interval 2 day)',
      'date_sub(current_date("UTC"), interval 3 day)',
      'date_sub(current_date("UTC"), interval 4 day)',
      'date_sub(current_date("UTC"), interval 5 day)',
      'date_sub(current_date("UTC"), interval 6 day)',
      'date_sub(current_date("UTC"), interval 7 day)',
      'date_sub(current_date("UTC"), interval 8 day)'
] %}

{{ 
   config(
          materialized='incremental',
          partition_by = { 'field': 'created_date', 'data_type': 'date' },
          incremental_strategy = 'insert_overwrite',
          partitions = partitions_to_replace,
          cluster_by = "user_email"     
        )
}}

WITH day_on_day_cost AS(
    (
 SELECT
    DATE(creation_time, 'UTC') AS created_date,
    user_email,
    query,
    COUNT(DISTINCT(job_id)) AS job_count,
    ROUND(SUM(total_billed_tb),6) as total_billed_tb,
    ROUND(SUM(total_billed_tb),6) * 8.6088832727448512 AS estimated_usd_cost
  FROM 
    {{ ref('information_schema_jobs_source') }}
  WHERE 1=1
  {% if is_incremental() %}
    -- recalculate yesterday
    AND DATE(creation_time, 'UTC') in ({{ partitions_to_replace | join(',') }})
  {% endif %}
  GROUP BY 
    1, 
    2, 
    3 
  ORDER BY estimated_usd_cost DESC
  )
)
SELECT * FROM day_on_day_cost