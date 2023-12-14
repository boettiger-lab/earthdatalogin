#' download assets from earthdata over https using bearer tokens
#'
#' NOTE: This should be used primarily as a fallback mechanism!
#' EarthData Cloud resources are often best accessed directly over
#' HTTPS without download.  This allows subsets to be extracted instead
#' of downloading unnecessary bits.  Unfortunately, certain formats do
#' not support such HTTP-based range requests (e.g. HDF4), and require
#' the asset is downloaded to a local POSIX filesystem first.
#' @param href the https URL of the asset
#' @param dest local destination
#' @param auth the authentication method ("token" for Bearer tokens
#' or "netrc" for netrc.)
#' @param method The download method, either "httr" or "curl".
#' @inheritParams edl_netrc
#' @param ... additional arguments to `download.file()`, e.g. quiet = TRUE.
#' @return the `dest` path, invisibly
#' @export
#' @examplesIf interactive()
#' href <- lpdacc_example_url()
#' edl_download(href)
edl_download <- function(href,
                         dest = basename(href),
                         auth = "netrc",
                         method = "httr",
                         username = default("user"),
                         password = default("password"),
                         netrc_path = edl_netrc_path(),
                         cookie_path = edl_cookie_path(),
                         ...) {

  if (auth == "token") {

    download_using_token(href, dest, method, ...)

  } else {

    edl_netrc(username = default("user"),
              password = default("password"),
              netrc_path = edl_netrc_path(),
              cookie_path = edl_cookie_path(),
              cloud_config = FALSE)


    if (method == "httr") {
      pw <- openssl::base64_encode(paste0(username, ":", password))
      httr::GET(href,
                httr::config(#netrc_file = netrc_path,
                             cookiefile = cookie_path,
                             cookiejar = cookie_path),
                httr::add_headers(Authorization= paste("Basic", pw)),
                httr::write_disk(dest, overwrite = TRUE))

    } else {

      ## check syntax, curl_args not working properly
      curl_args <- paste("--netrc-file", netrc_path,
                         "-b", cookie_path,
                         "-c", cookie_path)
      utils::download.file(href, dest, method = "curl",
                           extra = curl_args, ...)
    }
  }
  invisible(dest)
}





download_using_token <- function(href, dest, method, ...) {
  header <- edl_set_token()
  bearer <- paste("Bearer", header)
  if (method == "httr") {
    httr::GET(href,
              httr::write_disk(dest, overwrite = TRUE),
              httr::add_headers(Authorization = bearer))
  } else {
    utils::download.file(href, dest, ...,
                         header = list(Authorization = bearer))
  }
}
