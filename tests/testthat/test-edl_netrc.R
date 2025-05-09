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
