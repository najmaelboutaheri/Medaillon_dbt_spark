{% snapshot address_snapshot %}

{{
    config(
      file_format = "delta",
      location_root = "wasbs://silver@datalakegenversion1.blob.core.windows.net/snapshots/address",
      target_schema='snapshots',
      invalidate_hard_deletes=True,
      unique_key='AddressID',
      strategy='check',
      check_cols='all'
    )
}}

with source_data as (
    select
        AddressID,
        AddressLine1,
        AddressLine2,
        City,
        StateProvince,
        CountryRegion,
        PostalCode
    from {{ source('saleslt', 'address') }}
)
select *
from source_data

{% endsnapshot %}