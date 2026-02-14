# Search for data products using the EarthData API

**NOTE**: Use as a fallback method only! Users are strongly encouraged
to rely on the STAC endpoints for NASA EarthData, as shown in the
package vignettes. STAC is a widely used metadata standard by both NASA
and many other providers, and can be searched using the feature-rich
`rstac` package. STAC return items can be more easily parsed as well.

## Usage

``` r
edl_search(
  short_name = NULL,
  version = NULL,
  doi = NULL,
  daac = NULL,
  provider = NULL,
  temporal = NULL,
  bounding_box = NULL,
  page_size = 2000,
  recurse = TRUE,
  parse_results = TRUE,
  username = default("user"),
  password = default("password"),
  netrc_path = edl_netrc_path(),
  cookie_path = edl_cookie_path(),
  ...
)
```

## Arguments

- short_name:

  dataset short name e.g. ATL08

- version:

  dataset version

- doi:

  DOI for a dataset

- daac:

  NSIDC or PODAAC

- provider:

  particular to each DAAC, e.g. POCLOUD, LPDAAC etc.

- temporal:

  c("yyyy-mm-dd", "yyyy-mm-dd")

- bounding_box:

  c(lower_left_lon, lower_left_lat, upper_right_lon, upper_right_lat)

- page_size:

  maximum number of results to return per query.

- recurse:

  If a query returns more than page_size results, should we make
  recursive calls to return all results?

- parse_results:

  logical, default TRUE. Calls
  [`edl_extract_urls()`](https://boettiger-lab.github.io/earthdatalogin/reference/edl_extract_urls.md)
  to determine url links to data objects. Set to FALSE to return the
  full API response object, but be wary of large object sizes when
  search returns many results.

- username:

  EarthData Login User

- password:

  EarthData Login Password

- netrc_path:

  Path to the .netrc file to be created. Defaults to the appropriate R
  package configuration location given by
  [`tools::R_user_dir()`](https://rdrr.io/r/tools/userdir.html).

- cookie_path:

  Path to the file where cookies will be stored. Defaults to the
  appropriate R package configuration location given by
  [`tools::R_user_dir()`](https://rdrr.io/r/tools/userdir.html).

- ...:

  additional query parameters

## Value

A character vector of data URLs matching the search criteria, if
`parse_results = TRUE` (default). Otherwise, returns a response object
of the returned search information if `parse_results = FALSE`.

## Examples

``` r
if (FALSE) { # interactive()

items <- edl_search(short_name = "MUR-JPL-L4-GLOB-v4.1",
                   temporal = c("2002-01-01", "2021-12-31"),
                   recurse = TRUE,
                   parse_urls = TRUE)

urls <- edl_extract_urls(items)
}
```
