
test_that("edl_s3", {

  skip_on_cran()
  skip_if_offline()
  # tokens can only be used inside S3
  p <-  edl_s3_token(prompt_for_netrc = FALSE)
  expect_type(p, "list")
})


test_that("edl_unset_s3", {

  x <- edl_unset_s3()
  expect_true(x)

})

test_that("edl_unset_s3", {

  href <- lpdacc_example_url()
  addr <- edl_as_s3(href)
  expect_match(addr, "^s3://")

 })
