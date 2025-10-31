{{ config(
    materialized='view')
    }}

SELECT *
FROM {{ source('jobspy','jobs') }}
