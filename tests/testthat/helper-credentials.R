# Online tests need the tester's own Earthdata Login credentials, from the
# EARTHDATA_USER and EARTHDATA_PASSWORD environment variables (set from
# repository secrets on GitHub Actions) or from ~/.netrc.
skip_if_no_edl_credentials <- function() {
  if (is.null(edl_default_credentials())) {
    skip("No Earthdata Login credentials (set EARTHDATA_USER and EARTHDATA_PASSWORD)")
  }
}
