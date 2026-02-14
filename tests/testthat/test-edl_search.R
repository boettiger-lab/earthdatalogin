test_that("edl_search", {

  skip_if_offline()
  skip_on_cran()

  resp <- edl_search(short_name = "MUR-JPL-L4-GLOB-v4.1",
                     temporal = c("2020-01-01", "2021-12-31"),
                     parse_results = FALSE)
  expect_type(resp, "list")

  urls <- edl_extract_urls(resp)
  expect_gt(length(urls), 1)
  expect_type(urls, "character")

  href <- edl_search(short_name = "MUR-JPL-L4-GLOB-v4.1",
                     temporal = c("2018-01-01", "2021-12-31"),
                     parse_results = TRUE)

  expect_gt(length(href), 1)
  expect_type(href, "character")

})

test_that("edl_search with bounding box", {

  skip_if_offline()
  skip_on_cran()

  bbox_results <- edl_search(
    short_name = "ATL08",
    bounding_box = c(-92.86, 16.26, -91.58, 16.97),
    parse_results = FALSE
  )

  expect_s3_class(bbox_results, "cmr_items")
  expect_gt(length(bbox_results), 1)
})
