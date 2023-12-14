test_that("edl_download", {

  skip_on_cran()
  skip_if_offline()

  url <- lpdacc_example_url()
  f <- tempfile(fileext = ".tif")
  edl_download(url, f)

  expect_true(file.exists(f))

  r <- terra::rast(url, vsi=TRUE)
  expect_true(inherits(r, "SpatRaster"))

  unlink(f)

})

test_that("edl_download via token", {

  skip_on_cran()
  skip_if_offline()

  url <- lpdacc_example_url()
  f <- tempfile(fileext = ".tif")
  edl_download(url, f, auth="token", method = "httr")

  expect_true(file.exists(f))

  r <- terra::rast(url, vsi=TRUE)
  expect_true(inherits(r, "SpatRaster"))

  unlink(f)

})
