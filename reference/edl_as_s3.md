# Replace https URLs with S3 URIs

Replace https URLs with S3 URIs

## Usage

``` r
edl_as_s3(href, prefix = "s3://")
```

## Arguments

- href:

  a https URL from an EarthData Cloud address

- prefix:

  the preferred s3 prefix, e.g. `s3://` (understood by gdalcubes), or
  `/vsis3`, for terra/stars/sf or other GDAL-based interfaces.

## Value

a URI that strips basename and protocol and appends prefix

## Examples

``` r
href <- lpdacc_example_url()
edl_as_s3(href)
#> [1] "s3://lp-prod-protected/HLSL30.020/HLS.L30.T56JKT.2023246T235950.v2.0/HLS.L30.T56JKT.2023246T235950.v2.0.SAA.tif"
```
