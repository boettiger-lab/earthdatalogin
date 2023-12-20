test_that("edl_search", {

  skip_if_offline()
  skip_on_cran()

  resp <- edl_search(short_name = "MUR-JPL-L4-GLOB-v4.1",
                     temporal = c("2020-01-01", "2021-12-31"))

  urls <- edl_extract_urls(resp)

  expect_gt(length(urls), 1)
})
