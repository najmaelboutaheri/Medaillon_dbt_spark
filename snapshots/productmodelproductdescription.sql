e

{% snapshot productmodelproductdescription_snapshot %}

{{
    config(
      file_format = "delta",
      location_root = "wasbs://silver@datalakegenversion1.blob.core.windows.net/snapshots/productmodelproductdescription",
      target_schema='snapshots',
      invalidate_hard_deletes=True,
      unique_key='ProductModelID',
      strategy='check',
      check_cols='all'
    )
}}

with productmodelproductdescription_snapshot as (
    SELECT
       ProductModelID,
       ProductDescriptionID,
       Culture,
       rowguid,
       ModifiedDat
    FROM {{ source('saleslt', 'productmodelproductdescription') }}
)

select * from productmodelproductdescription_snapshot

{% endsnapshot %}