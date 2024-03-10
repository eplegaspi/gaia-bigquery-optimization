{% set partitions_to_replace = [
      'current_date("UTC")',
      'date_sub(current_date("UTC"), interval 1 day)'
] %}

{{ 
   config(
          materialized='incremental',
          partition_by = { 'field': 'created_date', 'data_type': 'date' },
          incremental_strategy = 'insert_overwrite',
          partitions = partitions_to_replace,
          cluster_by = "user_email",      
        )
}}

WITH day_on_day_cost_by_email AS(
  (
  SELECT
    created_date,
    user_email,
    SUM(job_count) AS job_count,
    ROUND(SUM(total_billed_tb),6) AS total_billed_tb,
    ROUND(SUM(estimated_usd_cost),6) AS estimated_usd_cost
  FROM
     {{ ref('day_on_day_cost') }}
  WHERE 1=1
  {% if is_incremental() %}
          -- recalculate yesterday
          AND created_date in ({{ partitions_to_replace | join(',') }})
  {% endif %}
  GROUP BY
    1,
    2
  ORDER BY estimated_usd_cost DESC
  ) 
)
SELECT * FROM day_on_day_cost_by_email