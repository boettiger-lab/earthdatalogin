# Restores GDAL default configuration

Unsets GDAL environmental variables set by
[`gdal_cloud_config()`](https://boettiger-lab.github.io/earthdatalogin/reference/gdal_cloud_config.md)

## Usage

``` r
gdal_cloud_unconfig()
```

## Value

invisible TRUE if successful.

## See also

[`gdal_cloud_config()`](https://boettiger-lab.github.io/earthdatalogin/reference/gdal_cloud_config.md)

## Examples

``` r
if (FALSE) { # interactive()
gdal_cloud_config()

# remove settings:
gdal_cloud_unconfig()
}
```
