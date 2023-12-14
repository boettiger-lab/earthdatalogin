
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
#'
#' edl_netrc()
#' url <- lpdacc_example_url()
#' terra::rast(url, vsi=TRUE)
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
  Sys.setenv("GDAL_HTTP_NETRC" = "YES")
  Sys.setenv("GDAL_HTTP_NETRC_FILE" = netrc_path)  # GDAL >= 3.7.0

  # GDAL < 3.7 cannot use an alternative location for .netrc
  old_gdal_compatibility(netrc_path, contents)

  # Set cookie paths as GDAL env vars
  Sys.setenv("GDAL_HTTP_COOKIEFILE" = cookie_path)
  Sys.setenv("GDAL_HTTP_COOKIEJAR" = cookie_path)
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
                            cookie_path = edl_cookie_path()) {

  unlink(netrc_path)
  unlink(cookie_path)

  Sys.unsetenv("GDAL_HTTP_NETRC")
  Sys.unsetenv("GDAL_HTTP_NETRC_FILE")

  # Set cookie paths as GDAL env vars
  Sys.unsetenv("GDAL_HTTP_COOKIEFILE")
  Sys.unsetenv("GDAL_HTTP_COOKIEJAR")
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
