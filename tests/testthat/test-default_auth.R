# No network: credentials come only from env vars or the user's ~/.netrc.

local_no_credentials <- function(env = parent.frame()) {
  home <- withr::local_tempdir(.local_envir = env)
  withr::local_envvar(HOME = home, R_USER = home, USERPROFILE = home,
                      EARTHDATA_USER = NA, EARTHDATA_PASSWORD = NA,
                      .local_envir = env)
  home
}

test_that("default() errors with registration help when no credentials", {
  local_no_credentials()
  expect_null(edl_default_credentials())
  expect_error(default("user"), "urs.earthdata.nasa.gov")
  expect_error(default("password"), "EARTHDATA_USER and EARTHDATA_PASSWORD")
})

test_that("default() reads EARTHDATA_USER and EARTHDATA_PASSWORD", {
  local_no_credentials()
  withr::local_envvar(EARTHDATA_USER = "alice", EARTHDATA_PASSWORD = "secret")
  expect_equal(default("user"), "alice")
  expect_equal(default("password"), "secret")
})

test_that("default() falls back to the user's ~/.netrc", {
  home <- local_no_credentials()
  writeLines(c("machine example.com login bob password nope",
               "machine urs.earthdata.nasa.gov",
               "  login alice",
               "  password secret",
               "default login anon password anon"),
             file.path(home, ".netrc"))
  expect_equal(default("user"), "alice")
  expect_equal(default("password"), "secret")
})

test_that("environment variables take precedence over ~/.netrc", {
  home <- local_no_credentials()
  writeLines("machine urs.earthdata.nasa.gov login bob password pw",
             file.path(home, ".netrc"))
  withr::local_envvar(EARTHDATA_USER = "alice", EARTHDATA_PASSWORD = "secret")
  expect_equal(default("user"), "alice")
})

test_that("read_netrc_credentials() ignores other machines and partial entries", {
  netrc <- withr::local_tempfile()
  writeLines(c("machine example.com login bob password nope",
               "machine urs.earthdata.nasa.gov login alice"),
             netrc)
  expect_null(read_netrc_credentials(netrc))
  expect_null(read_netrc_credentials(tempfile()))
})

test_that("edl_netrc() without credentials errors instead of using defaults", {
  local_no_credentials()
  netrc <- withr::local_tempfile()
  expect_error(
    edl_netrc(netrc_path = netrc, cookie_path = tempfile(),
              cloud_config = FALSE, check = FALSE),
    "No Earthdata Login credentials"
  )
  expect_false(file.exists(netrc))
})
