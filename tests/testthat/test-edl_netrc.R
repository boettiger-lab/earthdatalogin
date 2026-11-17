test_that("edl_netrc and edl_download do not overwrite stored credentials", {
  # No network needed: we only check what gets written to the netrc file,
  # so the Earthdata Login credential check is mocked out.
  local_mocked_bindings(
    urs_auth_response = function(...) list(status = 200L, reason = "")
  )
  home <- withr::local_tempdir()
  withr::local_envvar(HOME = home, R_USER = home)
  netrc <- tempfile()
  cookie <- tempfile()
  on.exit(unlink(c(netrc, cookie)), add = TRUE)

  # explicit credentials are written
  edl_netrc(username = "alice", password = "secret",
            netrc_path = netrc, cookie_path = cookie, cloud_config = FALSE)
  expect_match(readLines(netrc), "login alice password secret")

  # a bare call must NOT overwrite the stored credentials with the defaults
  edl_netrc(netrc_path = netrc, cookie_path = cookie, cloud_config = FALSE)
  expect_match(readLines(netrc), "login alice password secret")

  # a download without credentials must also leave the netrc intact
  tryCatch(
    edl_download("https://urs.earthdata.nasa.gov/nonexistent",
                 dest = tempfile(), netrc_path = netrc,
                 cookie_path = cookie, quiet = TRUE),
    error = function(e) NULL, warning = function(w) NULL
  )
  expect_match(readLines(netrc), "login alice password secret")

  # but explicit credentials at download time are honored
  tryCatch(
    edl_download("https://urs.earthdata.nasa.gov/nonexistent",
                 dest = tempfile(), username = "bob", password = "pw2",
                 netrc_path = netrc, cookie_path = cookie, quiet = TRUE),
    error = function(e) NULL, warning = function(w) NULL
  )
  expect_match(readLines(netrc), "login bob password pw2")
})

test_that("edl_netrc", {
  skip_online()
  skip_if_no_edl_credentials()

  # test in clean setting
  edl_unset_token()
  edl_unset_netrc()
  unlink(edl_cookie_path())

  # here we go
  edl_netrc()

  url <- lpdacc_example_url()
  r <- terra::rast(url, vsi = TRUE)
  expect_true(inherits(r, "SpatRaster"))

  edl_unset_netrc()
})


test_that("netcdf access", {
  skip_online()
  skip_if_no_edl_credentials()

  # Since GDAL 2.4 libnetcdf >= 4.5, Mac and Windos lack netcdf vsi support
  # https://gdal.org/en/stable/drivers/raster/netcdf.html#vsi-virtual-file-system-api-support
  url <- "https://archive.podaac.earthdata.nasa.gov/podaac-ops-cumulus-protected/AVHRR_OI-NCEI-L4-GLOB-v2.1/20200115120000-NCEI-L4_GHRSST-SSTblend-AVHRR_OI-GLOB-v02.0-fv02.1.nc"
  edl_netrc()

  driver <- NULL
  arch <- tolower(Sys.info()[["sysname"]])
  if (arch %in% c("windows", "darwin")) {
    warning("Windows or MacOS detected, using HDF5")
    driver <- "HDF5"
    # Sys.setenv(GDAL_SKIP="netCDF") # doesn't work
  }

  # On some CI runs GDAL reports this file as an unsupported format, which
  # usually means the server sent something other than the file. Retry a few
  # times with GDAL's cache off for this URL, and if every attempt fails,
  # report what the server returns so the cause can be found.
  withr::local_envvar(CPL_VSIL_CURL_NON_CACHED = paste0("/vsicurl/", url))
  for (attempt in 1:3) {
    r <- tryCatch(terra::rast(url, vsi = TRUE, drivers = driver),
                  error = function(e) e)
    if (!inherits(r, "error")) break
    Sys.sleep(5)
  }
  if (inherits(r, "error")) {
    stop(conditionMessage(r), "\n\n", edl_request_diagnostics(url),
         call. = FALSE)
  }
  expect_true(inherits(r, "SpatRaster"))

  edl_unset_netrc()
})
