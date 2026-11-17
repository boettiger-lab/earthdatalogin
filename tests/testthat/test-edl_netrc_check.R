# These tests mock the Earthdata Login request, so they need no network
# access or real credentials.

local_netrc <- function(env = parent.frame()) {
  netrc <- withr::local_tempfile(.local_envir = env)
  writeLines("machine urs.earthdata.nasa.gov login alice password secret",
             netrc)
  netrc
}

# edl_netrc() sets GDAL env vars and may write ~/.netrc, so point HOME at a
# temporary directory and restore the env vars afterwards.
local_edl_sandbox <- function(env = parent.frame()) {
  home <- withr::local_tempdir(.local_envir = env)
  withr::local_envvar(HOME = home, R_USER = home, USERPROFILE = home,
                      GDAL_HTTP_NETRC = NA, GDAL_HTTP_NETRC_FILE = NA,
                      GDAL_HTTP_COOKIEFILE = NA, GDAL_HTTP_COOKIEJAR = NA,
                      .local_envir = env)
}

mock_urs <- function(status, reason = "", env = parent.frame()) {
  local_mocked_bindings(
    urs_auth_response = function(...) list(status = status, reason = reason),
    .env = env
  )
}

test_that("accepted credentials return TRUE silently", {
  netrc <- local_netrc()
  mock_urs(200L)
  expect_silent(out <- edl_netrc_check(netrc))
  expect_true(out)
})

test_that("rejected credentials warn and return FALSE", {
  netrc <- local_netrc()
  mock_urs(401L, "Invalid user credentials")
  expect_warning(out <- edl_netrc_check(netrc),
                 "HTTP 401: Invalid user credentials")
  expect_false(out)

  mock_urs(403L)
  expect_warning(out <- edl_netrc_check(netrc), "authentication failed")
  expect_false(out)
})

test_that("other HTTP errors warn and return NA", {
  netrc <- local_netrc()
  mock_urs(503L)
  expect_warning(out <- edl_netrc_check(netrc), "returned HTTP 503")
  expect_identical(out, NA)
})

test_that("network errors warn and return NA", {
  netrc <- local_netrc()
  local_mocked_bindings(
    urs_auth_response = function(...) stop("Could not resolve host")
  )
  expect_warning(out <- edl_netrc_check(netrc), "Could not resolve host")
  expect_identical(out, NA)
})

test_that("a missing netrc warns without a network request", {
  local_mocked_bindings(
    urs_auth_response = function(...) stop("should not be called")
  )
  expect_warning(out <- edl_netrc_check(tempfile()), "No Earthdata Login")
  expect_false(out)
})

test_that("edl_netrc() returns the check result", {
  netrc <- withr::local_tempfile()
  cookie <- withr::local_tempfile()
  local_edl_sandbox()

  mock_urs(401L, "Invalid user credentials")
  expect_warning(
    out <- edl_netrc("alice", "wrong", netrc_path = netrc,
                     cookie_path = cookie, cloud_config = FALSE),
    "Invalid user credentials"
  )
  expect_false(out)

  mock_urs(200L)
  expect_true(edl_netrc("alice", "secret", netrc_path = netrc,
                        cookie_path = cookie, cloud_config = FALSE))
})

test_that("edl_netrc(check = FALSE) skips the request", {
  netrc <- withr::local_tempfile()
  cookie <- withr::local_tempfile()
  local_edl_sandbox()
  local_mocked_bindings(
    urs_auth_response = function(...) stop("should not be called")
  )
  expect_silent(
    out <- edl_netrc("alice", "secret", netrc_path = netrc,
                     cookie_path = cookie, cloud_config = FALSE,
                     check = FALSE)
  )
  expect_identical(out, NA)
})

test_that("edl_error_reason() extracts the EDL error description", {
  fake_response <- function(status, body) {
    structure(list(url = "https://urs.earthdata.nasa.gov/api/users/tokens",
                   status_code = status,
                   headers = list(`content-type` = "application/json"),
                   content = charToRaw(body)),
              class = "response")
  }
  expect_equal(
    edl_error_reason(fake_response(
      401L, '{"error":"invalid_credentials","error_description":"Invalid user credentials"}'
    )),
    "Invalid user credentials"
  )
  expect_equal(edl_error_reason(fake_response(401L, '{"error":"locked"}')),
               "locked")
  expect_equal(edl_error_reason(fake_response(500L, "<html>oops</html>")), "")
  expect_equal(edl_error_reason(fake_response(200L, "[]")), "")
})
