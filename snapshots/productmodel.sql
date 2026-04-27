{% snapshot productmodel_snapshot %}

{{
    config(
      file_format = "delta",
      location_root = "wasbs://silver@datalakegenversion1.blob.core.windows.net/snapshots/productmodel",
      target_schema='snapshots',
      invalidate_hard_deletes=True,
      unique_key='ProductModelID',
      strategy='check',
      check_cols='all'
    )
}}

with productmodel_snapshot as (
    SELECT
        ProductModelID,
        Name,
        CatalogDescription,
        rowguid,
        ModifiedDate
    FROM {{ source('saleslt', 'productmodel') }}
)

select * from productmodel_snapshot

{% endsnapshot %}
