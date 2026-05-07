{{ config(materialized='view') }}

WITH normalized AS (
    SELECT
        j.*,
        regexp_replace(
            lower(coalesce(j.description, '')),
            '\s+', ' ', 'g'
        ) AS _norm_desc
    FROM {{ ref('jobspy_jobs') }} j
    WHERE j.date_posted >= CURRENT_DATE - INTERVAL '7 days'
),
deduped AS (
    SELECT DISTINCT ON (sys_profile, _norm_desc) *
    FROM normalized
    ORDER BY sys_profile, _norm_desc, id
)
SELECT * FROM deduped d
WHERE NOT EXISTS (
    SELECT 1 FROM public.evaluated_jobs e
    WHERE e.job_id = d.id
      AND e.sys_profile = d.sys_profile
)
