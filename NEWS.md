# earthdatalogin (development version)

* Adds `collections_fetch()` for working with the results of a `collections()`
  query using the [rstac](https://brazil-data-cube.github.io/rstac/) package. The 
  NASA STAC API by default only return 10 collections for a given catalogue; 
  this function allows you to retrieve them all (#11).
* Adds `edl_stac_urls()` for retrieving urls from an `rstac` items list.

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

