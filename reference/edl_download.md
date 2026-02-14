# download assets from earthdata over https using bearer tokens

NOTE: This should be used primarily as a fallback mechanism! EarthData
Cloud resources are often best accessed directly over HTTPS without
download. This allows subsets to be extracted instead of downloading
unnecessary bits. Unfortunately, certain formats do not support such
HTTP-based range requests (e.g. HDF4), and require the asset is
downloaded to a local POSIX filesystem first.

## Usage

``` r
edl_download(
  href,
  dest = basename(href),
  auth = "netrc",
  method = "httr",
  username = default("user"),
  password = default("password"),
  netrc_path = edl_netrc_path(),
  cookie_path = edl_cookie_path(),
  quiet = TRUE,
  ...
)
```

## Arguments

- href:

  the https URL of the asset

- dest:

  local destination

- auth:

  the authentication method ("token" for Bearer tokens or "netrc" for
  netrc.)

- method:

  The download method, either "httr" or "curl".

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

- quiet:

  logical default TRUE. Show progress in download?

- ...:

  additional arguments to
  [`download.file()`](https://rdrr.io/r/utils/download.file.html), e.g.
  quiet = TRUE.

## Value

the `dest` path, invisibly

## Examples

``` r
if (FALSE) { # interactive()
href <- lpdacc_example_url()
edl_download(href)
}
```
