# Helper function for extracting URLs from STAC

Helper function for extracting URLs from STAC

## Usage

``` r
edl_stac_urls(items, assets = "data")
```

## Arguments

- items:

  an items list from rstac

- assets:

  name(s) of assets to extract

## Value

a vector of hrefs for all discovered assets.
