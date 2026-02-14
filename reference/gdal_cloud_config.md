# Recommended GDAL configuration for cloud-based access

Sets GDAL environmental variables to recommended optimum settings for
cloud-based access.

## Usage

``` r
gdal_cloud_config()
```

## Value

sets recommended environmental variables and returns invisible TRUE if
successful.

## Details

Based on
<https://gdalcubes.github.io/source/concepts/config.html#recommended-settings-for-cloud-access>

## See also

[`gdal_cloud_unconfig()`](https://boettiger-lab.github.io/earthdatalogin/reference/gdal_cloud_unconfig.md)

## Examples

``` r
if (FALSE) { # interactive()
gdal_cloud_config()

# remove settings:
gdal_cloud_unconfig()
}
```
