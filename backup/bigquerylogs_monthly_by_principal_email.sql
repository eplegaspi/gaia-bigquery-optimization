{% set partitions_to_replace = [
      'DATE_TRUNC(created_date, MONTH)',
      'DATE_ADD(DATE_TRUNC(created_date, MONTH), INTERVAL 1 MONTH) '
] %}

{{ 
   config(
          materialized='incremental',
          partition_by = { 'field': 'created_date', 'data_type': 'date',  "granularity": "month"},
          incremental_strategy = 'insert_overwrite',
          partitions = partitions_to_replace,
          cluster_by = "principalEmail"      
        )
}}

WITH bigquerylogs_daily AS(
  (
  SELECT
    DATE_TRUNC(created_date, month) AS created_date,
    principalEmail,
    SUM(run_count) AS run_count,
    ROUND(SUM(tb_billed),6) AS tb_billed,
    ROUND(SUM(tb_processed),6) AS tb_processed,
    ROUND(SUM(estimated_usd_cost),6) AS estimated_usd_cost
  FROM
     {{ ref('bigquerylogs_daily') }}
  WHERE 1=1
  {% if is_incremental() %}
          -- recalculate yesterday
          AND DATE_TRUNC(created_date, month) in ({{ partitions_to_replace | join(',') }})
  {% endif %}
  GROUP BY
    1,
    2
  ORDER BY estimated_usd_cost DESC
  ) 
)
SELECT * FROM bigquerylogs_daily