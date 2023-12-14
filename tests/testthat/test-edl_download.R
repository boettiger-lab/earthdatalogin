test_that("edl_download", {

  skip_on_cran()
  skip_if_offline()


  url <- lpdacc_example_url()
  f <- tempfile(pattern = "HSL", fileext = ".tif")
  edl_download(url, f)


  expect_true(file.exists(f))
  r <- terra::rast(f)
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

  r <- terra::rast(f)
  expect_true(inherits(r, "SpatRaster"))

  unlink(f)

})



test_that("edl_download, netrc+curl", {

  skip_on_cran()
  skip_if_offline()
  skip("not implemented")

  url <- lpdacc_example_url()
  f <- tempfile(fileext = ".tif")

  edl_download(url, f, auth = "netrc", method = "curl")

  expect_true(file.exists(f))
  r <- terra::rast(f)
  expect_true(inherits(r, "SpatRaster"))

  unlink(f)

})
