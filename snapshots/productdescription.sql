
{% snapshot productdescription_snapshot %}

{{
    config(
      file_format = "delta",
      location_root = "wasbs://silver@datalakegenversion1.blob.core.windows.net/snapshots/productdescription",
      target_schema='snapshots',
      invalidate_hard_deletes=True,
      unique_key='ProductDescriptionID',
      strategy='check',
      check_cols='all'
    )
}}

with source_data as (
    select
        ProductDescriptionID,
        Description,
        rowguid,
        ModifiedDate
    from {{ source('saleslt', 'productdescription') }}
)
select *
from source_data

{% endsnapshot %}