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

# Describe what a server returns for `url` when requested with the
# earthdatalogin netrc and cookie file, as GDAL would request it. Used when
# GDAL fails with only "not recognized as being in a supported format".
# Query strings are dropped from URLs so signed links are not printed, and
# only the names of credential-like environment variables are shown.
edl_request_diagnostics <- function(url) {
  strip_query <- function(x) sub("\\?.*$", "?...", x)
  out <- character()

  netrc_path <- Sys.getenv("GDAL_HTTP_NETRC_FILE", edl_netrc_path())
  cookie_path <- Sys.getenv("GDAL_HTTP_COOKIEFILE", "")
  out <- c(out,
    paste("netrc file:", netrc_path, "exists:", file.exists(netrc_path),
          "has EDL entry:", has_edl_netrc(netrc_path)),
    paste("cookie file:", if (nzchar(cookie_path)) cookie_path else "(unset)"))
  if (nzchar(cookie_path) && file.exists(cookie_path)) {
    cookies <- grep("^[^#]", readLines(cookie_path, warn = FALSE), value = TRUE)
    domains <- unique(vapply(strsplit(cookies, "\t"), `[`, "", 1))
    out <- c(out, paste("cookie domains:",
                        if (length(domains)) paste(domains, collapse = ", ")
                        else "(none)"))
  }

  env <- Sys.getenv()
  env <- env[grepl("^(GDAL_|CPL_|AWS_|VSI)", names(env))]
  secret <- grepl("KEY|TOKEN|SECRET|PASSWORD|HEADER", names(env))
  shown <- ifelse(secret, "(set)", strip_query(env))
  out <- c(out, "GDAL environment:",
           if (length(env)) paste0("  ", names(env), "=", shown)
           else "  (none)")

  check <- tryCatch(suppressWarnings(edl_netrc_check(netrc_path)),
                    error = function(e) conditionMessage(e))
  out <- c(out, paste("edl_netrc_check():", format(check)))

  config <- httr::config(netrc = TRUE, netrc_file = netrc_path)
  if (nzchar(cookie_path)) {
    config <- c(config, httr::config(cookiefile = cookie_path,
                                     cookiejar = tempfile()))
  }
  resp <- tryCatch(
    httr::GET(url, config, httr::add_headers(Range = "bytes=0-1023"),
              httr::timeout(60)),
    error = function(e) e)
  if (inherits(resp, "error")) {
    return(paste(c(out, paste("request error:", conditionMessage(resp))),
                 collapse = "\n"))
  }

  hops <- vapply(resp$all_headers, function(h) {
    loc <- h$headers[["location"]]
    paste0("  HTTP ", h$status,
           if (length(loc)) paste0(" -> ", strip_query(loc[[1]])) else "")
  }, character(1))
  type <- httr::headers(resp)[["content-type"]]
  out <- c(out, "request:", hops,
           paste("final status:", httr::status_code(resp),
                 "content-type:", if (is.null(type)) "(none)" else type))
  if (!is.null(type) && grepl("text|json|xml|html", type)) {
    body <- substr(httr::content(resp, "text", encoding = "UTF-8"), 1, 500)
    out <- c(out, "body:", body)
  } else {
    raw <- httr::content(resp, "raw")
    out <- c(out, paste("first bytes:",
                        paste(as.character(utils::head(raw, 8)),
                              collapse = " ")))
  }
  paste(out, collapse = "\n")
}
