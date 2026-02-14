# Changelog

## earthdatalogin 0.0.3

CRAN release: 2025-07-11

- Bugfix for edl_s3_token()
  ([\#21](https://github.com/boettiger-lab/earthdatalogin/issues/21)),
  which now requires cookies

- Adds support for listing NASA STAC catalogs with
  [`list_nasa_stacs()`](https://boettiger-lab.github.io/earthdatalogin/reference/list_nasa_stacs.md)
  and retrieving specific catalog URLs with
  [`get_nasa_stac_url()`](https://boettiger-lab.github.io/earthdatalogin/reference/get_nasa_stac_url.md)
  ([\#19](https://github.com/boettiger-lab/earthdatalogin/issues/19)).

- adds experimental support for CMR search with
  [`edl_search()`](https://boettiger-lab.github.io/earthdatalogin/reference/edl_search.md).
  Does not support all use cases, STAC-based search is still
  recommended.

- Adds
  [`collections_fetch()`](https://boettiger-lab.github.io/earthdatalogin/reference/collections_fetch.md)
  for working with the results of a
  [`collections()`](https://brazil-data-cube.github.io/rstac/reference/collections.html)
  query using the [rstac](https://brazil-data-cube.github.io/rstac/)
  package. The NASA STAC API by default only return 10 collections for a
  given catalogue; this function allows you to retrieve them all
  ([\#11](https://github.com/boettiger-lab/earthdatalogin/issues/11)).

- Adds
  [`edl_stac_urls()`](https://boettiger-lab.github.io/earthdatalogin/reference/edl_stac_urls.md)
  for retrieving urls from an `rstac` items list.

- bugfix for default_auth() behavior if credentials are not supplied.

## earthdatalogin 0.0.2

CRAN release: 2023-12-15

- Adds support for netrc-based authentication.
  [`edl_set_token()`](https://boettiger-lab.github.io/earthdatalogin/reference/edl_set_token.md)
  works only outside of `us-west-2`,
  [`edl_s3_token()`](https://boettiger-lab.github.io/earthdatalogin/reference/edl_s3_token.md)
  works only inside `us-west-2`, netrc works anywhere. Additionally,
  netrc-based auth does not to be deactivated when accessing
  non-earthdatalogin URLs.

  - [`edl_netrc()`](https://boettiger-lab.github.io/earthdatalogin/reference/edl_netrc.md)
    sets up netrc-based access.
  - [`edl_unset_netrc()`](https://boettiger-lab.github.io/earthdatalogin/reference/edl_unset_netrc.md)
    reverses this, but should rarely be needed.

  Using other authentication methods in interactive mode will now prompt
  users to switch to
  [`edl_netrc()`](https://boettiger-lab.github.io/earthdatalogin/reference/edl_netrc.md)
  as the default.
  [`edl_download()`](https://boettiger-lab.github.io/earthdatalogin/reference/edl_download.md)
  will also use netrc auth by default for greater portability.

- [`gdal_cloud_config()`](https://boettiger-lab.github.io/earthdatalogin/reference/gdal_cloud_config.md)
  sets recommended settings for GDAL cloud configuration, see
  <https://gdalcubes.github.io/source/concepts/config.html#recommended-settings-for-cloud-access>.
  By default,
  [`edl_netrc()`](https://boettiger-lab.github.io/earthdatalogin/reference/edl_netrc.md)
  will automatically configure this as well.

- Because the `gdalcubes` package does not read environmental variables
  set by
  [`edl_netrc()`](https://boettiger-lab.github.io/earthdatalogin/reference/edl_netrc.md)
  and other authentication methods, a new helper function,
  [`with_gdalcubes()`](https://boettiger-lab.github.io/earthdatalogin/reference/with_gdalcubes.md)
  will set the gdal configuration for the gdalcubes package.

- Documentation is also updated.

## earthdatalogin 0.0.1

CRAN release: 2023-11-16

- Initial CRAN submission.
