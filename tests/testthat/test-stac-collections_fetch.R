test_that("collections_fetch works", {
  skip_online()
  skip_if_not_installed("rstac")

  # The unpaged response now has  20 records
  coll1 <- skip_on_server_error(
    rstac::stac("https://cmr.earthdata.nasa.gov/stac/LARC_CLOUD") |>
      rstac::collections() |>
      rstac::get_request()
  )
  expect_gt(length(coll1$collections), 2)

  # collections_fetch() is deprecated in favour of rstac::collections_fetch()
  # In testthat edition 3, expect_warning() returns the warning, not the
  # value, so assign inside it.
  skip_on_server_error(
    expect_warning(coll2 <- collections_fetch(coll1), "deprecated")
  )
  expect_s3_class(coll2, c("doc_collections", "rstac_doc", "list"))

  # At time of writing (2025-02-15) there were 70 collections in the LARC STAC
  # catalogue
  expect_gt(length(coll2$collections), 2)

})
