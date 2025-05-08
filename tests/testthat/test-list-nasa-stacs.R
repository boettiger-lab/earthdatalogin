test_that("list_nasa_stacs() works", {
  skip_on_cran()
  skip_if_offline()

  ret_cloud <- list_nasa_stacs()
  ret <- list_nasa_stacs(cloud_only = FALSE)

  expect_s3_class(ret, "data.frame")
  expect_s3_class(ret_cloud, "data.frame")
  expect_lte(nrow(ret_cloud), nrow(ret))
})

test_that("get_nasa_stac_url() works", {
  skip_on_cran()
  skip_if_offline()

  url <- get_nasa_stac_url("LPCLOUD")
  expect_type(url, "character")
  expect_length(url, 1)
  expect_match(url, "https://.+LPCLOUD")
})

test_that("get_nasa_stac_url() fails correctly", {
  expect_error(get_nasa_stac_url("notadaac"), "notadaac not found in stacs")
})
