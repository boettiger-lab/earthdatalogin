# Extract data URLs from edl_search

**NOTE** this function uses heuristic rules to extract data from
edl_search(). Users are strongly encouraged to rely on STAC searches
instead.

## Usage

``` r
edl_extract_urls(items)
```

## Arguments

- items:

  the content object from edl_search

## Value

a character vector of URLs

## Examples

``` r
if (FALSE) { # interactive()

items <- edl_search(short_name = "MUR-JPL-L4-GLOB-v4.1",
                   temporal = c("2020-01-01", "2021-12-31"),
                   parse_urls = FALSE)

urls <- edl_extract_urls(items)
}
```
