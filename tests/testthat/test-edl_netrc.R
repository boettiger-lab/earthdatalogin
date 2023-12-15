

test_that("edl_netrc", {

  skip_on_cran()
  skip_if_offline()

  # test in clean setting
  edl_unset_token()
  unlink( edl_cookie_path() )

  # here we go
  edl_netrc()

  url <- lpdacc_example_url()
  r <- terra::rast(url, vsi=TRUE)
  expect_true(inherits(r, "SpatRaster"))

  edl_unset_netrc()

  })
