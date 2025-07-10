#' NASA Earthdata S3 Credentials Authentication
#'
#' Authenticates with NASA Earthdata to obtain temporary S3 credentials for
#' accessing NASA Earth observation data stored in S3 buckets. The function
#' performs an OAuth-like authentication flow and automatically sets the
#' required AWS environment variables.
#'
#' Note that these S3 credentials will only work:
#' - On AWS instance in the `us-west-2` region
#' - Only for one hour before they expire
#' - Only on the DAAC requested
#'
#' Please consider using [edl_netrc()] to avoid these limitations
#'
#' @param daac Character string. The base URL for the DAAC (Data Archive Access Center).
#'   Defaults to "https://data.lpdaac.earthdatacloud.nasa.gov".
#' @param username Character string. EarthDataLogin username. Defaults to the
#'   value returned by `default("user")`.
#' @param password Character string. EarthDataLogin password. Defaults to the
#'   value returned by `default("password")`.
#' @param prompt_for_netrc Logical. Often netrc is preferable, so this function will by
#'   default prompt the user to switch. Set to FALSE to silence this.
#'   Defaults to `interactive()`.
#'
#' @return Invisibly returns a list containing the S3 credentials:
#'   \item{accessKeyId}{AWS access key ID}
#'   \item{secretAccessKey}{AWS secret access key}
#'   \item{sessionToken}{AWS session token}
#'   \item{expiration}{Token expiration time}
#'
#' @details
#' This function performs a multi-step authentication process:
#' \enumerate{
#'   \item Requests authorization URL from the credentials endpoint
#'   \item Posts credentials to get a redirect URL
#'   \item Follows redirect to set authentication cookies
#'   \item Makes final request with cookies to obtain S3 credentials
#' }
#'
#' The function automatically sets the following environment variables:
#' \itemize{
#'   \item `AWS_ACCESS_KEY_ID`
#'   \item `AWS_SECRET_ACCESS_KEY`
#'   \item `AWS_SESSION_TOKEN`
#' }
#'
#' @examplesIf interactive()
#' edl_s3_token()
#'
#' @export
edl_s3_token <- function(daac = "https://data.lpdaac.earthdatacloud.nasa.gov",
                         username = default("user"),
                         password = default("password"),
                         prompt_for_netrc = interactive()) {

  if (prompt_for_netrc) {
    done <- we_prefer_netrc(username, password)
    if (done) return(invisible(TRUE))
  }

  # Validate required parameters
  if (any(c(daac, username, password) == "")) {
    stop("Missing required parameters: daac, username, password")
  }

  origin <- "https:"
  credentials_url <- paste0(daac, "/s3credentials")
  auth_encoded <- base64enc::base64encode(charToRaw(paste0(username, ":", password)))

  # Get authorization URL
  initial_resp <- httr2::request(credentials_url) |>
    httr2::req_options(followlocation = FALSE) |>
    httr2::req_perform(verbosity = 0)

  # Check if we got a redirect (3xx status)
  if (httr2::resp_status(initial_resp) >= 300 && httr2::resp_status(initial_resp) < 400) {
    authorize_url <- httr2::resp_header(initial_resp, "Location")
  } else {
    stop("Expected redirect to authorization URL, got status: ", httr2::resp_status(initial_resp))
  }

  if (is.null(authorize_url)) {
    stop("Failed to get authorization URL from redirect")
  }

  # POST credentials to get redirect URL
  auth_resp <- httr2::request(authorize_url) |>
    httr2::req_method("POST") |>
    httr2::req_headers("Origin" = origin) |>
    httr2::req_body_multipart(credentials = auth_encoded) |>
    httr2::req_options(followlocation = FALSE) |>
    httr2::req_perform(verbosity = 0)

  redirect_url <- httr2::resp_header(auth_resp, "Location")
  if (is.null(redirect_url)) {
    stop("Failed to get redirect URL from authorization")
  }

  # Follow redirect to set cookies
  redirect_resp <- httr2::request(redirect_url) |>
    httr2::req_options(followlocation = FALSE) |>
    httr2::req_perform(verbosity = 0)

  # Extract and format cookies
  cookies <- httr2::resp_headers(redirect_resp)[grepl("^set-cookie", names(httr2::resp_headers(redirect_resp)), ignore.case = TRUE)]

  # Build final request with cookies
  final_req <- httr2::request(credentials_url)
  if (length(cookies) > 0) {
    cookie_values <- vapply(cookies, function(x) strsplit(x, ";")[[1]][1], character(1))
    final_req <- final_req |> httr2::req_headers("Cookie" = paste(cookie_values, collapse = "; "))
  }

  # Get S3 credentials
  creds_resp <- final_req |>
    httr2::req_options(followlocation = FALSE) |>
    httr2::req_perform(verbosity = 0)

  # Parse JSON response - mime type will be HTML but body should be JSON
  credentials <- tryCatch({
    body_string <- httr2::resp_body_string(creds_resp)
    jsonlite::fromJSON(body_string)
  }, error = function(e) {
    stop("Authentication failed - unable to parse JSON response")
  })

  # Set AWS environment variables
  Sys.setenv(AWS_ACCESS_KEY_ID = credentials$accessKeyId)
  Sys.setenv(AWS_SECRET_ACCESS_KEY = credentials$secretAccessKey)
  Sys.setenv(AWS_SESSION_TOKEN = credentials$sessionToken)

  # Return credentials invisibly
  invisible(credentials)
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
