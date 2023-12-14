#' Receive and set temporary AWS Tokens for S3 access
#'
#' Note that these S3 credentials will only work:
#'
#' - On AWS instance in the us-west-2 region
#' - Only for one hour before they expire
#' - Only on the DACC requested
#'
#' Please consider using [edl_netrc()] to avoid these limitations
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

  done <- we_prefer_netrc(username, password)
  if (done) return(invisible(NULL))

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

#' Unset AWS S3 Environment Variables
#'
#' This function unsets the AWS S3-related environment variables:
#' \code{AWS_ACCESS_KEY_ID}, \code{AWS_SECRET_ACCESS_KEY}, and \code{AWS_SESSION_TOKEN}.
#'
#' @description
#' The function uses \code{Sys.unsetenv()} to remove the specified environment variables.
#'
#' @seealso
#' \code{\link{Sys.unsetenv}}
#'
#' @examplesIf interactive()
#' edl_unset_s3()
#'
#' @export
edl_unset_s3 <- function() {
  Sys.unsetenv("AWS_ACCESS_KEY_ID")
  Sys.unsetenv("AWS_SECRET_ACCESS_KEY")
  Sys.unsetenv("AWS_SESSION_TOKEN")
}
