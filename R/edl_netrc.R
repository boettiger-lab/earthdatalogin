
#' Set up Earthdata Login (EDL) credentials using a .netrc file
#'
#' This function creates a .netrc file with Earthdata Login (EDL) credentials
#' (username and password) and sets the necessary environment variables for GDAL
#' to use the .netrc file.
#'
#' @inheritParams edl_set_token
#' @param netrc_path Path to the .netrc file to be created. Defaults to the
#'   appropriate R package configuration location given by [tools::R_user_dir()].
#' @param cookie_path Path to the file where cookies will be stored.  Defaults
#'   to the appropriate R package configuration location given by
#'   [tools::R_user_dir()].
#' @param cloud_config set [gdal_cloud_config()] env vars as well? logical,
#' default `TRUE`.
#' @param check verify the stored credentials with Earthdata Login using
#'   [edl_netrc_check()]? logical, default `TRUE`. Set to `FALSE` to skip
#'   the network request, e.g. when working offline.
#'
#' @details The function sets the environment variables \code{GDAL_HTTP_NETRC}
#'   and \code{GDAL_HTTP_NETRC_FILE} to enable GDAL to use the .netrc file for
#'   EDL authentication. GDAL_HTTP_COOKIEFILE and GDAL_HTTP_COOKIEJAR are also
#'   set to allow the authentication to store and read access cookies.
#'
#'   Additionally, it manages the creation of a symbolic
#'   link to the .netrc file if GDAL version is less than 3.7.0 (and thus
#'   does not support GDAL_HTTP_NETRC_FILE location).
#'
#'   Unless `check = FALSE`, the credentials stored in the .netrc file are
#'   verified against Earthdata Login (see [edl_netrc_check()]). A warning is
#'   issued if they are rejected or cannot be verified.
#'
#' @returns Invisibly, `TRUE` if the credentials were accepted by Earthdata
#'   Login, `FALSE` if they are missing or were rejected, or `NA` if they
#'   could not be verified (e.g. no network access, or `check = FALSE`).
#' @examplesIf interactive()
#'
#' edl_netrc()
#' url <- lpdacc_example_url()
#' terra::rast(url, vsi=TRUE)
#'
#' @export
edl_netrc <- function(username = default("user"),
                      password = default("password"),
                      netrc_path = edl_netrc_path(),
                      cookie_path = edl_cookie_path(),
                      cloud_config = TRUE,
                      check = TRUE) {

  # Bearer auth can conflict
  edl_unset_token()

  # Don't clobber stored credentials.  If the caller did not explicitly
  # supply a username/password and the netrc file already holds earthdata
  # credentials, keep them rather than overwriting them with the
  # EARTHDATA_USER / EARTHDATA_PASSWORD defaults (#13, #27).
  if (!missing(username) || !missing(password) ||
      !has_edl_netrc(netrc_path)) {

    # Create a .netrc for earthdatalogin
    contents <- paste("machine urs.earthdata.nasa.gov login",
                      username, "password", password)
    writeLines(contents, netrc_path)

    # GDAL < 3.7 cannot use an alternative location for .netrc
    old_gdal_compatibility(netrc_path)
  }

  # set GDAL env vars to use this netrc
  Sys.setenv("GDAL_HTTP_NETRC" = "YES")
  Sys.setenv("GDAL_HTTP_NETRC_FILE" = netrc_path)  # GDAL >= 3.7.0

  # Set cookie paths as GDAL env vars
  Sys.setenv("GDAL_HTTP_COOKIEFILE" = cookie_path)
  Sys.setenv("GDAL_HTTP_COOKIEJAR" = cookie_path)

  if (cloud_config) {
    gdal_cloud_config()
  }

  # verify the stored credentials actually authenticate (#30)
  if (!check) {
    return(invisible(NA))
  }
  invisible(edl_netrc_check(netrc_path))
}

#' Check if netrc credentials are accepted by Earthdata Login (EDL)
#'
#' Reads the Earthdata Login credentials from a netrc file (as created by
#' [edl_netrc()]) and verifies them against the Earthdata Login API.
#'
#' @inheritParams edl_netrc
#' @param timeout seconds to wait for a response from Earthdata Login.
#'
#' @returns Invisibly, `TRUE` if the credentials were accepted, `FALSE` if
#'   the netrc file is missing or the credentials were rejected, and `NA` if
#'   the check could not be completed (e.g. no network access).
#' @examplesIf interactive()
#'
#' edl_netrc_check()
#'
#' @export
edl_netrc_check <- function(netrc_path = edl_netrc_path(),
                            timeout = 10) {
  say <- function(fn, ...) fn(..., call. = FALSE)

  if (!has_edl_netrc(netrc_path)) {
    say(warning, "No Earthdata Login credentials found in ", netrc_path, ". ",
        "Run edl_netrc(username, password) to store your credentials. ",
        "Register at https://urs.earthdata.nasa.gov if needed.")
    return(invisible(FALSE))
  }

  resp <- tryCatch(
    urs_auth_response(netrc_path, timeout),
    error = function(e) e
  )

  if (inherits(resp, "error")) {
    say(warning, "Could not verify Earthdata Login credentials: ",
        conditionMessage(resp))
    return(invisible(NA))
  }

  status <- resp$status
  reason <- if (nzchar(resp$reason)) paste0(": ", resp$reason) else ""

  if (status == 200) {
    return(invisible(TRUE))
  }

  if (status %in% c(401, 403)) {
    say(warning, "Earthdata Login authentication failed (HTTP ", status,
        reason, "). Check your username and password, then run ",
        "edl_netrc(username, password) to update the stored credentials. ",
        "Register at https://urs.earthdata.nasa.gov if needed.")
    return(invisible(FALSE))
  }

  say(warning, "Could not verify Earthdata Login credentials: ",
      "Earthdata Login returned HTTP ", status, reason, ".")
  invisible(NA)
}

#' Basic-auth request to the Earthdata Login API using a netrc file
#'
#' httr reads the credentials from the netrc file.
#' @return list(status = HTTP status code, reason = EDL error text or "")
#' @noRd
urs_auth_response <- function(netrc_path = edl_netrc_path(), timeout = 10) {
  # Retry brief connection failures and server errors, never 4xx responses
  # such as 401 for bad credentials (a retry could lock the account).
  resp <- httr::RETRY("GET", "https://urs.earthdata.nasa.gov/api/users/tokens",
                      httr::config(netrc = 1L,
                                   netrc_file = normalizePath(netrc_path),
                                   httpauth = 1L),
                      httr::accept_json(),
                      httr::user_agent(edl_user_agent()),
                      httr::timeout(timeout),
                      times = 3, pause_base = 1, pause_cap = 5,
                      terminate_on = 400:499, quiet = TRUE)
  list(status = httr::status_code(resp), reason = edl_error_reason(resp))
}

#' Extract EDL's error description, e.g. "Invalid user credentials"
#' @noRd
edl_error_reason <- function(resp) {
  if (httr::status_code(resp) < 400) return("")
  body <- tryCatch(
    jsonlite::fromJSON(httr::content(resp, "text", encoding = "UTF-8")),
    error = function(e) NULL
  )
  reason <- if (is.list(body)) body$error_description %||% body$error
  if (is.character(reason) && length(reason) == 1) reason else ""
}

edl_user_agent <- function() {
  paste0("earthdatalogin/", utils::packageVersion("earthdatalogin"))
}

`%||%` <- function(x, y) if (is.null(x)) y else x


#' Does an earthdata .netrc file already exist at this path?
#' @noRd
has_edl_netrc <- function(netrc_path = edl_netrc_path()) {
  file.exists(netrc_path) &&
    any(grepl("machine urs.earthdata.nasa.gov",
              readLines(netrc_path, warn = FALSE)))
}

#' edl_unset_netrc
#'
#'
#' Unsets environmental variables set by edl_netrc() and removes
#' configuration files set by [edl_netrc()].
#'
#' Note that this function should rarely be necessary, as unlike bearer
#' token-based auth, netrc is mapped by domain name and will not interfere
#' with access to non-earthdata-based URLs.  It may still be necessary
#' to deactivate in order to use one of the other earthdatalogin authentication
#' methods.
#'
#' To unset environmental variables without removing files, set that file
#' path argument to `""` (see examples)
#'
#' Note that GDAL_HTTP_NETRC defaults to YES.
#'
#' @inheritParams edl_netrc
#' @return invisible TRUE, if successful (even if no env is set.)
#' @examplesIf interactive()
#'
#'  edl_unset_netrc()
#'
#'  # unset environmental variables only
#'  edl_unset_netrc("", "")
#'
#' @export
edl_unset_netrc <- function(netrc_path = edl_netrc_path(),
                            cookie_path = edl_cookie_path(),
                            cloud_config = TRUE) {

  unlink(netrc_path)
  unlink(cookie_path)

  Sys.unsetenv("GDAL_HTTP_NETRC")
  Sys.unsetenv("GDAL_HTTP_NETRC_FILE")

  # Set cookie paths as GDAL env vars
  Sys.unsetenv("GDAL_HTTP_COOKIEFILE")
  Sys.unsetenv("GDAL_HTTP_COOKIEJAR")

  if (cloud_config) {
    gdal_cloud_unconfig()
  }
}


# GDAL < 3.7 ignores GDAL_HTTP_NETRC_FILE and reads only ~/.netrc. For those
# versions only, link our netrc to ~/.netrc for the rest of the session. An
# existing ~/.netrc is never modified.
old_gdal_compatibility <- function(netrc_path) {
  version <- gdal_version()
  if (is.null(version) || version >= "3.7.0") {
    return(invisible(FALSE))
  }

  home_netrc <- path.expand("~/.netrc")
  if (file.exists(home_netrc)) {
    if (!has_edl_netrc(home_netrc)) {
      message("GDAL ", version, " reads credentials only from ", home_netrc,
              ", which has no urs.earthdata.nasa.gov entry. Add one, or ",
              "upgrade to GDAL 3.7 or later.")
    }
    return(invisible(FALSE))
  }

  file.link(netrc_path, home_netrc)
  # Packages should not leave files in the home directory.
  reg.finalizer(.GlobalEnv, function(e) unlink(home_netrc), onexit = TRUE)
  invisible(TRUE)
}

# The GDAL version used by terra or sf, or NULL if neither is installed.
gdal_version <- function() {
  if (requireNamespace("terra", quietly = TRUE)) {
    return(package_version(terra::gdal()))
  }
  if (requireNamespace("sf", quietly = TRUE)) {
    return(package_version(sf::sf_extSoftVersion()[["GDAL"]]))
  }
  NULL
}

edl_cookie_path <- function() {
  path <- file.path(tools::R_user_dir("earthdatalogin"), "urs_cookies")
  if(!dir.exists(dirname(path))) {
    dir.create(dirname(path), FALSE, TRUE)
  }

  if(!file.exists(path)){
    file.create(path)
  }
  path
}

edl_netrc_path <- function() {

  path <- file.path(tools::R_user_dir("earthdatalogin"), "netrc")
  if(!dir.exists(dirname(path))) {
    dir.create(dirname(path), FALSE, TRUE)
  }

  path
}



we_prefer_netrc <- function(username, password) {
  done <- FALSE
  if(interactive()){
    message(paste(
      " Consider using edl_netrc() instead.\n",
      "edl_netrc() works everywhere, inside and outside `us-west-2`.\n"
    ))
    choose_netrc <- utils::askYesNo("Use edl_netrc() instead?")
    if(choose_netrc) {
      message("configuring netrc-based auth instead as requested...")
      edl_netrc(username, password)
      done <- TRUE
    }
  }
  done
}
