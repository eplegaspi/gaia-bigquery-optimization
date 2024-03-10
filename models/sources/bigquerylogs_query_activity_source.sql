{% set partitions_to_replace = [
      'timestamp(current_date)',
      'timestamp(date_sub(current_date, interval 1 day))'
] %}

{{ 
   config(
          materialized='incremental',
          partition_by = { 'field': 'created_at', 'data_type': 'timestamp' },
          incremental_strategy = 'insert_overwrite',
          partitions = partitions_to_replace,
          cluster_by = "principalEmail",      
        )
}}

WITH events AS(
  SELECT
    timestamp AS created_at,
    protopayload_auditlog.authenticationInfo.principalEmail AS principalEmail,
    CAST(JSON_EXTRACT_SCALAR(protopayload_auditlog.metadataJson, "$.jobChange.job.jobStats.queryStats.totalBilledBytes") AS INT64)/ POWER(2, 40) AS totalBilledTB,
    CAST(JSON_EXTRACT_SCALAR(protopayload_auditlog.metadataJson, "$.jobChange.job.jobStats.queryStats.totalProcessedBytes") AS INT64)/ POWER(2, 40) AS totalProcessedTB,
    CAST(JSON_EXTRACT_SCALAR(protopayload_auditlog.metadataJson, "$.jobChange.job.jobStats.queryStats.outputRowCount") AS INT64) AS totalProducedRows,
    JSON_EXTRACT(protopayload_auditlog.metadataJson, "$.jobChange.job.jobConfig.queryConfig.query") AS metadataQuery
  FROM
    `mclinica-analytics.bigquery_logs.cloudaudit_googleapis_com_data_access`
  WHERE 1=1
  {% if is_incremental() %}
          -- recalculate yesterday
          AND timestamp_trunc(timestamp, day) in ({{ partitions_to_replace | join(',') }})
  {% endif %}
  AND JSON_EXTRACT_SCALAR(protopayload_auditlog.metadataJson, "$.jobChange.job.jobConfig.type") = "QUERY"
)
SELECT * FROM events