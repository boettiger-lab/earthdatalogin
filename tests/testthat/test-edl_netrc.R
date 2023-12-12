

test_that("edl_netrc", {

  # test in clean setting
  edl_unset_token()
  unlink( edl_cookie_path() )
  edl_netrc()

  r <- terra::rast("/vsicurl/https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/HLSL30.020/HLS.L30.T56JKT.2023246T235950.v2.0/HLS.L30.T56JKT.2023246T235950.v2.0.SAA.tif")

  expect_true(inherits(r, "SpatRaster"))
  })
