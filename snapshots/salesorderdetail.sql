{% snapshot salesorderdetail_snapshot %}

{{
    config(
      file_format = "delta",
      location_root = "wasbs://silver@datalakegenversion1.blob.core.windows.net/snapshots/salesorderdetail",
      target_schema='snapshots',
      invalidate_hard_deletes=True,
      unique_key='SalesOrderDetailID',
      strategy='check',
      check_cols='all'
    )
}}

with salesorderdetail_snapshot as (
    SELECT
        SalesOrderID,
        SalesOrderDetailID,
        OrderQty,
        ProductID,
        UnitPrice,
        UnitPriceDiscount,
        LineTotal
    FROM {{ source('saleslt', 'salesorderdetail') }}
)

select * from salesorderdetail_snapshot

{% endsnapshot %}