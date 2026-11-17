# These tests point HOME at a temporary directory. On Windows, R fixes "~"
# at startup, so the old-GDAL cases would touch the real home directory.

local_home <- function(env = parent.frame()) {
  home <- withr::local_tempdir(.local_envir = env)
  withr::local_envvar(HOME = home, .local_envir = env)
  home
}

local_edl_netrc_file <- function(env = parent.frame()) {
  path <- withr::local_tempfile(.local_envir = env)
  writeLines("machine urs.earthdata.nasa.gov login user password pass", path)
  path
}

test_that("GDAL 3.7 or later leaves ~/.netrc alone", {
  skip_on_os("windows")
  home <- local_home()
  netrc <- local_edl_netrc_file()
  local_mocked_bindings(gdal_version = function() package_version("3.7.0"))

  expect_false(old_gdal_compatibility(netrc))
  expect_false(file.exists(file.path(home, ".netrc")))
})

test_that("no GDAL leaves ~/.netrc alone", {
  skip_on_os("windows")
  home <- local_home()
  netrc <- local_edl_netrc_file()
  local_mocked_bindings(gdal_version = function() NULL)

  expect_false(old_gdal_compatibility(netrc))
  expect_false(file.exists(file.path(home, ".netrc")))
})

test_that("old GDAL links the netrc to ~/.netrc when there is none", {
  skip_on_os("windows")
  home <- local_home()
  netrc <- local_edl_netrc_file()
  local_mocked_bindings(gdal_version = function() package_version("3.6.2"))

  expect_true(old_gdal_compatibility(netrc))
  expect_equal(readLines(file.path(home, ".netrc")), readLines(netrc))
})

test_that("old GDAL never modifies an existing ~/.netrc", {
  skip_on_os("windows")
  home <- local_home()
  netrc <- local_edl_netrc_file()
  local_mocked_bindings(gdal_version = function() package_version("3.6.2"))
  home_netrc <- file.path(home, ".netrc")
  writeLines("machine example.com login a password b", home_netrc)

  expect_message(out <- old_gdal_compatibility(netrc), "upgrade to GDAL 3.7")
  expect_false(out)
  expect_equal(readLines(home_netrc), "machine example.com login a password b")
})

test_that("old GDAL is silent when ~/.netrc already has Earthdata credentials", {
  skip_on_os("windows")
  home <- local_home()
  netrc <- local_edl_netrc_file()
  local_mocked_bindings(gdal_version = function() package_version("3.6.2"))
  home_netrc <- file.path(home, ".netrc")
  writeLines("machine urs.earthdata.nasa.gov login a password b", home_netrc)

  expect_silent(out <- old_gdal_compatibility(netrc))
  expect_false(out)
  expect_equal(readLines(home_netrc),
               "machine urs.earthdata.nasa.gov login a password b")
})

test_that("gdal_version reports the version terra uses", {
  skip_if_not_installed("terra")
  expect_s3_class(gdal_version(), "package_version")
})
