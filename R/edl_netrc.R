
edl_netrc <- function(username = default("user"),
                      password = default("password"),
                      netrc_path = edl_netrc_path(),
                      cookie_path = edl_cookie_path()) {

  contents <- paste("machine urs.earthdata.nasa.gov login",
                    username, "password", password)
  writeLines(contents, netrc_path)
  Sys.setenv("GDAL_HTTP_NETRC" = TRUE)
  Sys.setenv("GDAL_HTTP_NETRC_FILE" = netrc_path)  # GDAL >= 3.7.0

  # GDAL < 3.7 cannot use an alternative location for .netrc
  if(!file.exists("~/.netrc")) {
    file.link(netrc_path, "~/.netrc")
    reg.finalizer(.GlobalEnv, function() unlink("~/.netrc"), onexit = FALSE)
  }

  edl_cookies(cookie_path)

}

edl_cookies <- function(path = edl_cookie_path()) {
  Sys.setenv("GDAL_HTTP_COOKIEFILE" = path)
  Sys.setenv("GDAL_HTTP_COOKIEJAR" = path)
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

