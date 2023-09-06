# Proto-package functions for dealing with NASA's earthdata login
# Requires GDAL >= 3.6

#' Get or set an earthdata login token
#'
#' This function will ping the EarthData API for any available tokens.
#' If a token is not found, it will request one.  You may only have
#' two active tokens at any given time.  Use edl_revoke_token to remove
#' unwanted tokens.
#'
#' NOTE: GDAL >= 3.6 is required to utilize GDAL_HTTP_HEADERS.
#' @param username EarthData Login User
#' @param password EarthData Login Password
#' @param token_number Which token (1 or 2)
#' @return the Authorization header for curl request, invisibly.
#' Will also set the GDAL_HTTP_HEADERS environmental variable for
#' compatibility with GDAL.
edl_set_token <- function (username = Sys.getenv("EARTHDATA_USER"),
                           password = Sys.getenv("EARTHDATA_PASSWORD"),
                           token_number = 1
) {
  base <- 'https://urs.earthdata.nasa.gov'
  list_tokens <- "/api/users/tokens"
  pw <- openssl::base64_encode(paste0(username, ":", password))
  resp <- httr::GET(paste0(base,list_tokens),
                    httr::add_headers(Authorization= paste("Basic", pw)))
  p <- httr::content(resp, "parsed")[[token_number]]

  if(is.null(p$access_token)) {
    request_token <- "/api/users/token"
    resp <- httr::GET(paste0(base,request_token),
                      httr::add_headers(Authorization= paste("Basic", pw)))
    p <- httr::content(resp, "parsed")
  }
  header = paste("Authorization: Bearer", p$access_token)
  Sys.setenv("GDAL_HTTP_HEADERS"=header)
  invisible(header)
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
#'
edl_download <- function(href,
                         dest = basename(href),
                         header = edl_set_token(),
                         use_httr = TRUE,
                         ...) {
  bearer <- gsub("Authorization: ", "", header)
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

#' Helper function for extracting URLs from STAC
#' @param items an items list from rstac
#' @param assets name(s) of assets to extract
#' @return a vector of hrefs for all discovered assets.
edl_stac_urls <- function(items, assets = "data") {
  purrr::map(items$features, list("assets")) |>
    purrr::map(list(assets)) |>
    purrr::map_chr("href")
}


#' Receive and set temporary AWS Tokens for S3 access
#' @param daac the base URL for the DAAC
#' @param username EarthDataLogin user
#' @param password EarthDataLogin Password
#' @return list of access key, secret key, session token and expiration,
#' invisibly.  Also sets the corresponding AWS environmental variables.
edl_s3_token <- function(daac = "https://data.lpdaac.earthdatacloud.nasa.gov",
                         username = Sys.getenv("EARTHDATA_USER"),
                         password = Sys.getenv("EARTHDATA_PASSWORD")) {
  endpoint <- "/s3credentials"
  pw <- openssl::base64_encode(paste0(username, ":", password))
  resp <- httr::GET(paste0(daac,endpoint),
                    httr::add_headers(Authorization= paste("Basic", pw)))
  p <- httr::content(resp, "parsed", "application/json")
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
edl_as_s3 <- function(href, prefix = "s3://") {
  p <- httr::parse_url(href)
  paste0(prefix, p$path)
}

