

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
#' @examplesIf interactive()
#' edl_netrc()
#'
#' @export
edl_netrc <- function(username = default("user"),
                      password = default("password"),
                      netrc_path = edl_netrc_path(),
                      cookie_path = edl_cookie_path()) {

  # Create a .netrc for earthdatalogin
  contents <- paste("machine urs.earthdata.nasa.gov login",
                    username, "password", password)
  writeLines(contents, netrc_path)

  # set GDAL env vars to use this netrc
  Sys.setenv("GDAL_HTTP_NETRC" = TRUE)
  Sys.setenv("GDAL_HTTP_NETRC_FILE" = netrc_path)  # GDAL >= 3.7.0

  # GDAL < 3.7 cannot use an alternative location for .netrc
  old_gdal_compatibility(netrc_path, contents)

  # Set cookie paths as GDAL env vars
  Sys.setenv("GDAL_HTTP_COOKIEFILE" = cookie_path)
  Sys.setenv("GDAL_HTTP_COOKIEJAR" = cookie_path)
}


old_gdal_compatibility <- function (netrc_path, contents) {
  if (!file.exists("~/.netrc")) {
    file.link(netrc_path, "~/.netrc")

    ## clean up on exit -- packages shouldn't persist files to `~`
    e <- .GlobalEnv
    f <- function(e) { unlink("~/.netrc") }
    reg.finalizer(e, f, onexit = TRUE)

  } else {
    ## append to an existing netrc file -- only once
    current <- readLines("~/.netrc")
    if (!any(grepl("machine urs.earthdata.nasa.gov", current))) {
      write(contents,file="~/.netrc",append=TRUE)
    }
  }

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


# wget --load-cookies $GDAL_HTTP_COOKIEFILE --save-cookies $GDAL_HTTP_COOKIEJAR --keep-session-cookies https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/HLSL30.020/HLS.L30.T13QFD.2013161T171945.v2.0/HLS.L30.T13QFD.2013161T171945.v2.0.SAA.tif

