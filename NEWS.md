# earthdatalogin 0.0.6

## Breaking changes

* `earthdatalogin` no longer supplies shared default credentials. The shared
  account has expired, and NASA asks that each user log in with their own
  Earthdata Login account. Credentials now come from the `username` and
  `password` arguments, the `EARTHDATA_USER` and `EARTHDATA_PASSWORD`
  environment variables, or the `urs.earthdata.nasa.gov` entry in
  `~/.netrc`. If none of these provides credentials, functions that need
  them stop with an error explaining how to register. The package no longer
  downloads `inst/.Renviron` from GitHub or falls back to hard-coded
  credentials.

* `edl_search()` searches CMR anonymously when no credentials are
  available, since CMR search does not require a login.

## New features

* New `edl_netrc_check()` verifies the credentials stored in a netrc file
  against Earthdata Login. `edl_netrc()` now runs this check and warns if
  the credentials are missing, rejected, or cannot be verified. It returns
  `TRUE` if they were accepted, `FALSE` if they are missing or rejected, and
  `NA` if they could not be verified, all invisibly. Use `check = FALSE` to
  skip the request (#30, #31, @rupesh2).

## Minor improvements and fixes

* Requests to the Earthdata Login API (`edl_set_token()`,
  `edl_revoke_token()` and `edl_netrc_check()`) retry brief connection
  failures and server errors up to three times. They never retry 4xx
  responses such as a 401 for bad credentials, which could lock the account.

* The deprecated `collections_fetch()` warns once instead of once per page.

* `edl_download()` now stops with an error when the server returns an HTTP
  error, and removes the partial file. Previously the `"httr"` method saved
  the server's error page to `dest` without complaint, and the `"curl"`
  method did the same. The `"httr"` method also retries brief connection
  failures and server errors up to three times.

* `edl_netrc()` no longer writes to `~/.netrc` unless GDAL is older than 3.7,
  which cannot read a netrc file from any other location. Even then it links
  its own netrc there for the session only when `~/.netrc` does not exist,
  and it never appends to an existing `~/.netrc`.

# earthdatalogin 0.0.5

* `edl_download()`, `edl_search()`, and `edl_netrc()` no longer overwrite
  stored credentials. Previously, calling these without arguments rewrote the
  `.netrc` file with the bundled default credentials, clobbering credentials a
  user had already set and causing 401 errors. Now the netrc is only
  (re)written when credentials are supplied explicitly or when no earthdata
  netrc exists yet (#27, #13).

* `edl_extract_urls()` (and `edl_search(parse_results = TRUE)`) now handle
  granules with multiple data assets, e.g. one GeoTIFF per band. Previously
  these failed with "Result must be length 1" (#15).

* `collections_fetch()` is deprecated in favor of `rstac::collections_fetch()`,
  which now provides this functionality upstream (#17).

# earthdatalogin 0.0.4

* Tests no longer attempt network access on CRAN. The `netcdf access` test now
  skips on CRAN and when offline, and the `get_nasa_stac_url()` error-path test
  is mocked so it runs without network access. This resolves the CRAN check
  errors introduced when the protected NetCDF download ran on CRAN machines.

# earthdatalogin 0.0.3

* Bugfix for edl_s3_token() (#21), which now requires cookies

* Adds support for listing NASA STAC catalogs with `list_nasa_stacs()` and
  retrieving specific catalog URLs with `get_nasa_stac_url()` (#19).

* adds experimental support for CMR search with `edl_search()`. Does not support 
  all use cases, STAC-based search is still recommended.

* Adds `collections_fetch()` for working with the results of a `collections()`
  query using the [rstac](https://brazil-data-cube.github.io/rstac/) package. The 
  NASA STAC API by default only return 10 collections for a given catalogue; 
  this function allows you to retrieve them all (#11).
  
* Adds `edl_stac_urls()` for retrieving urls from an `rstac` items list.

* bugfix for default_auth() behavior if credentials are not supplied.

# earthdatalogin 0.0.2

* Adds support for netrc-based authentication. `edl_set_token()` works only
  outside of `us-west-2`, `edl_s3_token()` works only inside `us-west-2`,
  netrc works anywhere.  Additionally, netrc-based auth does not to be 
  deactivated when accessing non-earthdatalogin URLs.  
  
  - `edl_netrc()` sets up netrc-based access.
  - `edl_unset_netrc()` reverses this, but should rarely be needed.
  
  Using other authentication methods in interactive mode will now prompt
  users to switch to `edl_netrc()` as the default.  `edl_download()` will 
  also use netrc auth by default for greater portability.
  
* `gdal_cloud_config()` sets recommended settings for GDAL cloud configuration, 
  see <https://gdalcubes.github.io/source/concepts/config.html#recommended-settings-for-cloud-access>.
  By default, `edl_netrc()` will automatically configure this as well.

* Because the `gdalcubes` package does not read environmental variables set by 
  `edl_netrc()` and other authentication methods, a new helper function,
  `with_gdalcubes()` will set the gdal configuration for the gdalcubes package.
  
* Documentation is also updated. 


# earthdatalogin 0.0.1

* Initial CRAN submission.
