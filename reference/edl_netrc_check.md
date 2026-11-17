# Check if netrc credentials are accepted by Earthdata Login (EDL)

Reads the Earthdata Login credentials from a netrc file (as created by
[`edl_netrc()`](https://boettiger-lab.github.io/earthdatalogin/reference/edl_netrc.md))
and verifies them against the Earthdata Login API.

## Usage

``` r
edl_netrc_check(netrc_path = edl_netrc_path(), timeout = 10)
```

## Arguments

- netrc_path:

  Path to the .netrc file to be created. Defaults to the appropriate R
  package configuration location given by
  [`tools::R_user_dir()`](https://rdrr.io/r/tools/userdir.html).

- timeout:

  seconds to wait for a response from Earthdata Login.

## Value

Invisibly, `TRUE` if the credentials were accepted, `FALSE` if the netrc
file is missing or the credentials were rejected, and `NA` if the check
could not be completed (e.g. no network access).

## Examples

``` r
if (FALSE) { # interactive()

edl_netrc_check()
}
```
