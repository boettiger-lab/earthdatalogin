# Set up Earthdata Login (EDL) credentials using a .netrc file

This function creates a .netrc file with Earthdata Login (EDL)
credentials (username and password) and sets the necessary environment
variables for GDAL to use the .netrc file.

## Usage

``` r
edl_netrc(
  username = default("user"),
  password = default("password"),
  netrc_path = edl_netrc_path(),
  cookie_path = edl_cookie_path(),
  cloud_config = TRUE
)
```

## Arguments

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

- cloud_config:

  set
  [`gdal_cloud_config()`](https://boettiger-lab.github.io/earthdatalogin/reference/gdal_cloud_config.md)
  env vars as well? logical, default `TRUE`.

## Value

TRUE invisibly if successful

## Details

The function sets the environment variables `GDAL_HTTP_NETRC` and
`GDAL_HTTP_NETRC_FILE` to enable GDAL to use the .netrc file for EDL
authentication. GDAL_HTTP_COOKIEFILE and GDAL_HTTP_COOKIEJAR are also
set to allow the authentication to store and read access cookies.

Additionally, it manages the creation of a symbolic link to the .netrc
file if GDAL version is less than 3.7.0 (and thus does not support
GDAL_HTTP_NETRC_FILE location).

## Examples

``` r
if (FALSE) { # interactive()

edl_netrc()
url <- lpdacc_example_url()
terra::rast(url, vsi=TRUE)
}
```
