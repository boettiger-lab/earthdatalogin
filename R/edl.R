# Proto-package functions for dealing with NASA's earthdata login
# Requires GDAL >= 3.6


#' Get or set an earthdata login token
#'
#' This function will ping the EarthData API for any available tokens.
#' If a token is not found, it will request one.  You may only have
#' two active tokens at any given time.  Use edl_revoke_token to remove
#' unwanted tokens.  By default, the function will also set an environmental
#' variable for the active R session to store the token.  This allows
#' popular R packages which use gdal to immediately authenticate any http
#' addresses to NASA EarthData assets.
#'
#' IMPORTANT: it is necessary to unset this token using `edl_unset_token()`
#' **before** trying to access HTTP resources that are not part of EarthData,
#' as setting this token will cause those calls to fail!
#'
#' NOTE: GDAL >= 3.6.1 is required to recognize the GDAL_HTTP_HEADERS variable.
#' The function can still generate and access tokens without GDAL, and curl
#' requests can still use the token (e.g. edl_download()). This function will
#' try and warn the user if an older version of GDAL is found.
#'
#' @param username EarthData Login User
#' @param password EarthData Login Password
#' @param token_number Which token (1 or 2)
#' @param set_env_var Should we set the GDAL_HTTP_HEADERS
#' environmental variable?  logical, default TRUE.
#' @param format One of "token" or "header".  The latter adds the prefix
#' used by http headers to the return string.
#' @return A text string containing only the token (format=token),
#' or a token with the header prefix included, `Authorization: Bearer <token>`
#' @export
#' @examplesIf interactive()
#' edl_set_token()
edl_set_token <- function (username = default("user"),
                           password = default("password"),
                           token_number = 1,
                           set_env_var = TRUE,
                           format = c("token", "header")
){

  p <- edl_api("/api/users/tokens", username, password)

  if(length(p) < token_number) {
    p <- edl_api("/api/users/token", username, password, method = httr::POST)
  } else {
    p <- p[[token_number]]
  }
  token <- p$access_token

  if (set_env_var) {
    edl_setenv(token)
  }
  format <- match.arg(format)
  out <- switch(format,
                token = token,
                header = edl_header(token)
  )
  invisible(out)
}


edl_setenv <- function(token) {

  # NOTE: GDAL_HTTP_HEADER_FILE is supported in any GDAL
  #if(requireNamespace("terra", quietly = TRUE)) {
  #  gdal_version <- terra::gdal()
  #  if (!utils::compareVersion(gdal_version, "3.6.1") >= 0) {
  #    warning(paste("GDAL VSI auth will require GDAL version >= 3.6.1\n",
  #                  "but found only gdal version", gdal_version))
  #  }
  #}

  header = edl_header(token)
  #Sys.setenv("GDAL_HTTP_HEADERS"=header)

  headerfile <- tempfile(pattern="GDAL_HTTP_HEADERS", fileext = "")
  writeLines(header, headerfile)
  Sys.setenv("GDAL_HTTP_HEADER_FILE"=headerfile)

}

default <- function(what) {
  switch(what,
         user = Sys.getenv("EARTHDATA_USER", "earthaccess"),
         password = Sys.getenv("EARTHDATA_PASSWORD", "EDL_test1"))
}


edl_header <- function(token) {
  paste("Authorization: Bearer", token)
}


edl_api <- function(endpoint,
                    username,
                    password,
                    ...,
                    base = "https://urs.earthdata.nasa.gov",
                    method = httr::GET) {

  pw <- openssl::base64_encode(paste0(username, ":", password))
  resp <- method(paste0(base, endpoint),
                    ...,
                    httr::add_headers(Authorization= paste("Basic", pw)))
  httr::stop_for_status(resp)
  p <- httr::content(resp, "parsed", "application/json")
  p
}

#' download assets from earthdata over https using bearer tokens
#'
#' NOTE: This should be used primarily as a fallback mechanism!
#' EarthData Cloud resources are often best accessed directly over
#' HTTPS without download.  This allows subsets to be extracted instead
#' of downloading unnecessary bits.  Unfortunately, certain formats do
#' not support such HTTP-based range requests (e.g. HDF4), and require
#' the asset is downloaded to a local POSIX filesystem first.
#' @param href the https URL of the earthdata asset
#' @param dest lcoal filepath destination
#' @param header the Authorization header (`Bearer <token>`).  Will be
#' requested automatically if not provided.
#' @param use_httr logical, default TRUE. Should we use httr or base method?
#' @param ... additional arguments to the [utils::download.file()] (ignored
#' if `use_httr=TRUE`).
#' @return the `dest` path, invisibly
#' @export
#' @examplesIf interactive()
#' href <- lpdacc_example_url()
#' edl_download(href)
edl_download <- function(href,
                         dest = basename(href),
                         header = edl_set_token(),
                         use_httr = TRUE,
                         ...) {
  bearer <- paste("Bearer", header)
  if (use_httr) {
    httr::GET(href,
              httr::write_disk(dest, overwrite = TRUE),
              httr::add_headers(Authorization = bearer))
  } else {
    utils::download.file(href, dest, ...,
                         header = list(Authorization = bearer))
  }
  invisible(dest)
}


#' Receive and set temporary AWS Tokens for S3 access
#'
#' @param daac the base URL for the DAAC
#' @param username EarthDataLogin user
#' @param password EarthDataLogin Password
#' @return list of access key, secret key, session token and expiration,
#' invisibly.  Also sets the corresponding AWS environmental variables.
#'
#' @examplesIf interactive()
#' edl_s3_token()
#' @export
edl_s3_token <- function(daac = "https://data.lpdaac.earthdatacloud.nasa.gov",
                         username = default("user"),
                         password = default("password")) {

  p <- edl_api(endpoint = "/s3credentials",
               username = username,
               password = password,
               base = daac)
  Sys.setenv(AWS_ACCESS_KEY_ID = p$accessKeyId)
  Sys.setenv(AWS_SECRET_ACCESS_KEY = p$secretAccessKey)
  Sys.setenv(AWS_SESSION_TOKEN = p$sessionToken)

  invisible(p)
}

#' Replace https URLs with S3 URIs
#' @param href a https URL from an EarthData Cloud address
#' @param prefix the preferred s3 prefix, e.g. `s3://` (understood by gdalcubes),
#' or `/vsis3`, for terra/stars/sf or other GDAL-based interfaces.
#' @return a URI that strips basename and protocol and appends prefix
#' @export
#' @examples
#' href <- lpdacc_example_url()
#' edl_as_s3(href)
edl_as_s3 <- function(href, prefix = "s3://") {
  p <- httr::parse_url(href)
  paste0(prefix, p$path)
}


#' URL for an example of an LP DAAC COG file
#'
#' @return The URL to a Cloud-Optimized Geotiff file from the LP DAAC.
#'
#' @examples
#' lpdacc_example_url()
#'
#' @export
lpdacc_example_url <- function() {
  paste0("https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/",
         "HLSL30.020/HLS.L30.T56JKT.2023246T235950.v2.0/",
         "HLS.L30.T56JKT.2023246T235950.v2.0.SAA.tif")
}



#' Helper function for extracting URLs from STAC
#'
#' @param items an items list from rstac
#' @param assets name(s) of assets to extract
#' @return a vector of hrefs for all discovered assets.
#'
edl_stac_urls <- function(items, assets = "data") {
  purrr::map(items$features, list("assets")) |>
    purrr::map(list(assets)) |>
    purrr::map_chr("href")
}


#' unset token
#'
#' External sources that don't need the token may error if token is set.
#' Call `edl_unset_token` before accessing non-EarthData URLs.
#' @export
#'
#' @examples
#' edl_unset_token()
edl_unset_token <- function() {
  Sys.unsetenv("GDAL_HTTP_HEADER_FILE")
}

#' Revoke an EarthData token
#'
#' Users can only have at most 2 active tokens at any time.
#' You don't need to keep track of a token since earthdatalogin can
#' retrieve your tokens with your user name and password.  However,
#' should you want to revoke a token, you can do so with this function.
#'
#' @inheritParams edl_set_token
#' @return API response (invisibly)
#' @examplesIf interactive()
#' edl_revoke_token()
#'
#' @export
edl_revoke_token <- function(
    username = default("user"),
    password = default("password"),
    token_number = 1
){

  if(username == "" || password == "") {
    message("You must provide a username and password either in .Renviron\n",
            "or using the optional arguments")
  }

  p <- edl_api("/api/users/tokens", username, password)
  if(length(p) == 0) {
    message("No tokens to revoke")
    return(invisible(NULL))
  } else {
    token <- p[[token_number]]$access_token
    p2 <- edl_api(paste0("/api/users/revoke_token?token=", token),
                  username, password, method=httr::POST)

  }
  invisible(p2)
}
