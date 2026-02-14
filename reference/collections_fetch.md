# Fetch all collections from an [`rstac::collections()`](https://brazil-data-cube.github.io/rstac/reference/collections.html) query

By default, NASA STAC catalogue collections queries only return 10
collections at a time. This function will page through the collections
and return them all.

## Usage

``` r
collections_fetch(collections, ...)
```

## Arguments

- collections:

  an object of class `doc_collections` as returned by calling
  [`rstac::get_request()`](https://brazil-data-cube.github.io/rstac/reference/request.html)
  on an
  [`rstac::collections()`](https://brazil-data-cube.github.io/rstac/reference/collections.html)
  query

- ...:

  Optional arguments passed on to
  [`httr::GET()`](https://httr.r-lib.org/reference/GET.html)

## Value

A `doc_collections` object with all of the collections from the
catalogue specified in the
[`rstac::collections()`](https://brazil-data-cube.github.io/rstac/reference/collections.html)
query.

## Examples

``` r
if (FALSE) { # interactive()

 rstac::stac("https://cmr.earthdata.nasa.gov/stac/LPCLOUD") |> 
   rstac::collections() |> 
   rstac::get_request() |> 
   collections_fetch()
}
```
