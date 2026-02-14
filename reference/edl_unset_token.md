# unset token

External sources that don't need the token may error if token is set.
Call `edl_unset_token` before accessing non-EarthData URLs.

## Usage

``` r
edl_unset_token()
```

## Value

unsets environmental variables token (no return object)

## Examples

``` r
edl_unset_token()
```
