{% set partitions_to_replace = [
      'current_date("UTC")',
      'date_sub(current_date("UTC"), interval 1 day)'
] %}


{{ 
   config(
          materialized='incremental',
          partition_by = { 'field': 'created_date', 'data_type': 'date' },
          incremental_strategy = 'insert_overwrite',
          partitions = partitions_to_replace
        )
}}

WITH bigquerylogs_daily AS(
  (
  SELECT
    created_date,
    metadataquery,
    SUM(run_count) AS run_count,
    ROUND(SUM(tb_billed),6) AS tb_billed,
    ROUND(SUM(tb_processed),6) AS tb_processed,
    ROUND(SUM(estimated_usd_cost),6) AS estimated_usd_cost
  FROM
     {{ ref('bigquerylogs_daily') }}
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
SELECT * FROM bigquerylogs_daily