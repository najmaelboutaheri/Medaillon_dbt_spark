{% snapshot product_snapshot %}

{{
    config(
      file_format = "delta",
      location_root = "wasbs://silver@datalakegenversion1.blob.core.windows.net/snapshots/product",

      target_schema='snapshots',
      invalidate_hard_deletes=True,
      unique_key='ProductID',
      strategy='check',
      check_cols='all'
    )
}}

with product_snapshot as (
    SELECT
        ProductID,
        Name,
        ProductNumber,
        Color,
        StandardCost,
        ListPrice,
        Size,
        Weight,
        ProductCategoryID,
        ProductModelID,
        SellStartDate,
        SellEndDate,
        DiscontinuedDate,
        ThumbNailPhoto,
        ThumbnailPhotoFileName
    FROM {{ source('saleslt', 'product') }}
)

select * from product_snapshot

{% endsnapshot %}