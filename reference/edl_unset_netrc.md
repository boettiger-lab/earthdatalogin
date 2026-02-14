# edl_unset_netrc

Unsets environmental variables set by edl_netrc() and removes
configuration files set by
[`edl_netrc()`](https://boettiger-lab.github.io/earthdatalogin/reference/edl_netrc.md).

## Usage

``` r
edl_unset_netrc(
  netrc_path = edl_netrc_path(),
  cookie_path = edl_cookie_path(),
  cloud_config = TRUE
)
```

## Arguments

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

invisible TRUE, if successful (even if no env is set.)

## Details

Note that this function should rarely be necessary, as unlike bearer
token-based auth, netrc is mapped by domain name and will not interfere
with access to non-earthdata-based URLs. It may still be necessary to
deactivate in order to use one of the other earthdatalogin
authentication methods.

To unset environmental variables without removing files, set that file
path argument to `""` (see examples)

Note that GDAL_HTTP_NETRC defaults to YES.

## Examples

``` r
if (FALSE) { # interactive()

 edl_unset_netrc()

 # unset environmental variables only
 edl_unset_netrc("", "")
}
```
