# A fake httr::RETRY that writes `body` to the destination file, as
# httr::write_disk() would, and returns a response with `status`.
mock_retry <- function(status, body, env = parent.frame()) {
  local_mocked_bindings(
    RETRY = function(verb, url, ...) {
      args <- list(...)
      for (a in args) {
        if (inherits(a, "request") && !is.null(a$output$path)) {
          writeLines(body, a$output$path)
        }
      }
      structure(list(url = url, status_code = status, headers = list()),
                class = "response")
    },
    .package = "httr", .env = env
  )
}

test_that("a successful download keeps the file", {
  dest <- withr::local_tempfile()
  mock_retry(200L, "data")
  httr_download("https://example.com/file.tif", dest)
  expect_equal(readLines(dest), "data")
})

test_that("a server error removes the error page and stops", {
  dest <- withr::local_tempfile()
  mock_retry(503L, "<html>Service Unavailable</html>")
  expect_error(httr_download("https://example.com/file.tif", dest),
               "HTTP 503")
  expect_false(file.exists(dest))
})

test_that("a rejected login removes the error page and stops", {
  dest <- withr::local_tempfile()
  mock_retry(401L, "Unauthorized")
  expect_error(httr_download("https://example.com/file.tif", dest),
               "HTTP 401")
  expect_false(file.exists(dest))
})
