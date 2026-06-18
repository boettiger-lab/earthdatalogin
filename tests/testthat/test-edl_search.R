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

test_that("edl_extract_urls flattens multi-asset granules (#15)", {
  # No network: a granule with several data links (e.g. one tif per band)
  # must not error and should return all data URLs.
  data_link <- function(href) {
    list(rel = "http://esipfed.org/ns/fedsearch/1.1/data#",
         title = "Download file", href = href)
  }
  items <- list(
    list(links = list(data_link("https://example.org/a_B01.tif"),
                      data_link("https://example.org/a_B02.tif"),
                      list(rel = "self", title = "metadata",
                           href = "https://example.org/a.xml"))),
    list(links = list(data_link("https://example.org/b_B01.tif")))
  )

  urls <- edl_extract_urls(items)
  expect_type(urls, "character")
  expect_equal(urls, c("https://example.org/a_B01.tif",
                       "https://example.org/a_B02.tif",
                       "https://example.org/b_B01.tif"))
})
