test_that("edl_search", {

  skip_online()

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

  skip_online()

  bbox_results <- edl_search(
    short_name = "ATL08",
    bounding_box = c(-92.86, 16.26, -91.58, 16.97),
    parse_results = FALSE
  )

  expect_s3_class(bbox_results, "cmr_items")
  expect_gt(length(bbox_results), 1)
})

test_that("doi_concept_id resolves a DOI to a collection concept id", {
  # when no network, the CMR collection search is mocked.
  local_mocked_bindings(cmr_collection_search = function(query, ...) {
    expect_equal(query$doi, "10.5067/HLS/HLSL30.002")
    list(list(id = "C1-A"))
  })
  expect_equal(doi_concept_id("10.5067/HLS/HLSL30.002"), "C1-A")

  # when several matches, the first is used, with a warning & listing of all
  local_mocked_bindings(cmr_collection_search = function(...) {
    list(list(id = "C1-A", short_name = "X", version_id = "1",
              data_center = "PROV_A"),
         list(id = "C2-B", short_name = "X", version_id = "1",
              data_center = "PROV_B"))
  })
  expect_warning(id <- doi_concept_id("10.5067/X"),
                 "Multiple CMR collections.*C2-B.*Using the first: C1-A")
  expect_equal(id, "C1-A")

  # including provider narrows the collection lookup
  local_mocked_bindings(cmr_collection_search = function(query, ...) {
    expect_equal(query$provider, "PROV_B")
    list(list(id = "C2-B"))
  })
  expect_equal(doi_concept_id("10.5067/X", provider = "PROV_B"), "C2-B")

  # unknown DOI produces anerror
  local_mocked_bindings(cmr_collection_search = function(...) list())
  expect_error(doi_concept_id("10.0000/nope"), "No CMR collection found")
})

test_that("edl_search by DOI matches search by short_name", {

  skip_online()

  by_doi <- edl_search(doi = "10.5067/HLS/HLSL30.002",
                       temporal = c("2025-07-01", "2025-07-02"))
  by_name <- edl_search(short_name = "HLSL30", version = "2.0",
                        temporal = c("2025-07-01", "2025-07-02"))
  expect_gt(length(by_doi), 0)
  expect_setequal(by_doi, by_name)
})

test_that("cmr_temporal includes the whole end day", {
  expect_null(cmr_temporal(NULL))
  # single day with no time is extended to the end of the day
  expect_equal(cmr_temporal(c("2025-07-01", "2025-07-01")),
               "2025-07-01T00:00:00Z,2025-07-01T23:59:59Z")
  expect_equal(cmr_temporal(as.Date(c("2025-07-01", "2025-07-03"))),
               "2025-07-01T00:00:00Z,2025-07-03T23:59:59Z")
  # date times in UTC are kept as it is
  expect_equal(cmr_temporal(c("2025-07-01T06:00:00Z", "2025-07-01T12:00:00Z")),
               "2025-07-01T06:00:00Z,2025-07-01T12:00:00Z")
  expect_equal(
    cmr_temporal(as.POSIXct(c("2025-07-01 06:00", "2025-07-01 12:00"),
                            tz = "UTC")),
    "2025-07-01T06:00:00Z,2025-07-01T12:00:00Z")
  # POSIXct in another time zone is converted to UTC
  expect_equal(
    cmr_temporal(as.POSIXct("2025-07-01 06:00", tz = "America/New_York")),
    "2025-07-01T10:00:00Z,")
  # NA, "NA" and "" are all treated as open-ended
  expect_equal(cmr_temporal("2025-07-01"), "2025-07-01T00:00:00Z,")
  expect_equal(cmr_temporal(c(NA, "2025-07-01")), ",2025-07-01T23:59:59Z")
  expect_equal(cmr_temporal(c("NA", "2025-07-01")), ",2025-07-01T23:59:59Z")
  expect_equal(cmr_temporal(c("", "2025-07-01")), ",2025-07-01T23:59:59Z")
  expect_equal(cmr_temporal(c("2025-07-01", "NA")), "2025-07-01T00:00:00Z,")
  expect_equal(cmr_temporal(c("2025-07-01", NA)), "2025-07-01T00:00:00Z,")
  expect_equal(cmr_temporal(c("2025-07-01", "")), "2025-07-01T00:00:00Z,")
  # length must be 1 or 2
  expect_error(cmr_temporal(character(0)), "temporal")
  expect_error(cmr_temporal(c("a", "b", "c")), "temporal")
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
