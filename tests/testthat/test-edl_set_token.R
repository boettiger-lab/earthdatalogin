test_that("edl_set_token", {
  skip_on_cran()
  skip_if_offline()
  token <- edl_set_token()
  expect_type(token, "character")
  expect_gt(nchar(token), 100)
})
