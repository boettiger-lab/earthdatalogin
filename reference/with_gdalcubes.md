# with_gdalcubes

expose any `GDAL_*` or `VSI_*` environmental variables to gdalcubes,
which calls GDAL in an isolated environment and does not respect the
global environmental variables.

## Usage

``` r
with_gdalcubes(env = Sys.getenv())
```

## Arguments

- env:

  a named vector of set environmental variables. Default is usually
  best, which will configure all relevant global environmental variables
  for gdalcubes.

## Value

NULL, invisibly.

## Examples

``` r
 with_gdalcubes()
```
