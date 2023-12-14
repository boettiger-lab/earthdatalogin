test_that("edl_set_token", {
  skip_on_cran()
  skip_if_offline()
  token <- edl_set_token()
  expect_type(token, "character")
  expect_gt(nchar(token), 100)

  url <- lpdacc_example_url()
  r <- terra::rast(url, vsi=TRUE)
  expect_true(inherits(r, "SpatRaster"))

})
