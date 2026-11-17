test_that("edl_download", {

  skip_online()
  skip_if_no_edl_credentials()

  edl_unset_netrc()

  url <- lpdacc_example_url()
  f <- tempfile(pattern = "HSL", fileext = ".tif")

  edl_download(url, f)


  expect_true(file.exists(f))
  r <- terra::rast(f)
  expect_true(inherits(r, "SpatRaster"))

  unlink(f)

})

test_that("edl_download via token", {

  skip_online()
  skip_if_no_edl_credentials()
  edl_unset_netrc()

  url <- lpdacc_example_url()
  f <- tempfile(fileext = ".tif")
  edl_download(url, f, auth="token", method = "httr")

  expect_true(file.exists(f))

  r <- terra::rast(f)
  expect_true(inherits(r, "SpatRaster"))

  unlink(f)

})



test_that("edl_download, netrc+libcurl", {

  skip_online()
  skip_if_no_edl_credentials()

  edl_unset_netrc()

  url <- lpdacc_example_url()
  f <- tempfile(fileext = ".tif")

  edl_download(url, f, auth = "netrc", method = "httr", quiet = TRUE)

  expect_true(file.exists(f))
  r <- terra::rast(f)
  expect_true(inherits(r, "SpatRaster"))

  unlink(f)

})


