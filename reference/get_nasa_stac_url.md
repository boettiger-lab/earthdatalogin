# Get NASA STAC URL for a Provider

Retrieves the STAC catalog URL for a specific NASA provider

## Usage

``` r
get_nasa_stac_url(provider, cloud_only = TRUE)
```

## Arguments

- provider:

  Character; the name of the NASA STAC provider

- cloud_only:

  Logical; if TRUE (default), returns only cloud-hosted STAC catalogs

## Value

A character string containing the STAC catalog URL for the specified
provider

## See also

[`list_nasa_stacs()`](https://boettiger-lab.github.io/earthdatalogin/reference/list_nasa_stacs.md)

## Examples

``` r
if (FALSE) { # \dontrun{
get_nasa_stac_url("LPDAAC", cloud_only = FALSE)
get_nasa_stac_url("LPCLOUD")
} # }
```
