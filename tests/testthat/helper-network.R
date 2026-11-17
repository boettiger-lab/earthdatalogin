# NASA's servers sometimes return 5xx errors, e.g. the CMR STAC catalogue
# takes about 30 s to build when uncached and its gateway gives up with HTTP
# 502. Run `code`, and skip the test rather than fail it when the server
# errors, so CI reports problems in this package and not NASA outages.
skip_on_server_error <- function(code) {
  tryCatch(code, error = function(e) {
    msg <- conditionMessage(e)
    if (inherits(e, "http_500") ||
        grepl("HTTP status '5[0-9][0-9]'|\\(HTTP 5[0-9][0-9]\\)", msg)) {
      skip(paste("NASA server error:", msg))
    }
    stop(e)
  })
}

# Online tests hit NASA services and, with credentials, log in to Earthdata
# Login. Skip them on CRAN and offline. On CI, run them in only one job
# (the one that sets EDL_ONLINE_TESTS=true) rather than in every job of the
# matrix at once, which loads NASA's servers and can trip Earthdata Login's
# rate limits.
skip_online <- function() {
  skip_on_cran()
  skip_if_offline()
  if (nzchar(Sys.getenv("CI")) &&
      !identical(tolower(Sys.getenv("EDL_ONLINE_TESTS")), "true")) {
    skip("Online tests run only in the CI job with EDL_ONLINE_TESTS=true")
  }
}
