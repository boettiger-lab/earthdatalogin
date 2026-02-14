# List NASA STAC Catalogs

Retrieves available STAC catalogs from NASA's Common Metadata Repository
(CMR)

## Usage

``` r
list_nasa_stacs(cloud_only = TRUE)
```

## Arguments

- cloud_only:

  Logical; if TRUE (default), returns only cloud-hosted STAC catalogs

## Value

A data frame of STAC catalog urls for all STAC providers in the CMR

## See also

[`get_nasa_stac_url()`](https://boettiger-lab.github.io/earthdatalogin/reference/get_nasa_stac_url.md)

## Examples

``` r
if (FALSE) { # \dontrun{
list_nasa_stacs()
list_nasa_stacs(cloud_only = FALSE)
} # }
```
