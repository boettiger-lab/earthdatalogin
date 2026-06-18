test_that("edl_netrc and edl_download do not overwrite stored credentials", {
  # No network needed: we only check what gets written to the netrc file.
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
  skip_on_cran()
  skip_if_offline()

  # test in clean setting
  edl_unset_token()
  unlink(edl_cookie_path())

  # here we go
  edl_netrc()

  url <- lpdacc_example_url()
  r <- terra::rast(url, vsi = TRUE)
  expect_true(inherits(r, "SpatRaster"))

  edl_unset_netrc()
})


test_that("netcdf access", {
  skip_on_cran()
  skip_if_offline()

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

  r <- terra::rast(url, vsi = TRUE, drivers = driver)
  expect_true(inherits(r, "SpatRaster"))

  edl_unset_netrc()
})
