## Submission

This release removes the shared Earthdata Login credentials that earlier
versions used by default. The shared account has expired, and NASA asked that
each user log in with their own account. Functions that need credentials now
take them from their arguments, the `EARTHDATA_USER` and `EARTHDATA_PASSWORD`
environment variables, or `~/.netrc`, and stop with an error that explains how
to register when none are found.

The release also fixes `edl_download()`, which saved server error pages in
place of the requested file, and stops `edl_netrc()` from writing to
`~/.netrc` when GDAL is 3.7 or later.

Tests and examples that need the network or credentials are skipped on CRAN.

## Test environments

* Local Ubuntu 26.04, R 4.6.2
* GitHub Actions: Ubuntu with R devel, release and oldrel-1; macOS and
  Windows with R release
* win-builder, R devel

## R CMD check results

0 errors | 0 warnings | 0 notes

## Reverse dependencies

There are no reverse dependencies on CRAN.
