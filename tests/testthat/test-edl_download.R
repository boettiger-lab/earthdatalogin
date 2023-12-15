test_that("edl_download", {

  skip_on_cran()
  skip_if_offline()

  url <- lpdacc_example_url()
  f <- tempfile(pattern = "HSL", fileext = ".tif")

  #edl_netrc()
  #r1 <- terra::rast(url, vsi=TRUE)

  edl_download(url, f)


  expect_true(file.exists(f))
  r <- terra::rast(f)
  expect_true(inherits(r, "SpatRaster"))

  unlink(f)

})

test_that("edl_download via token", {

  skip_on_cran()
  skip_if_offline()

  url <- lpdacc_example_url()
  f <- tempfile(fileext = ".tif")
  edl_download(url, f, auth="token", method = "httr")

  expect_true(file.exists(f))

  r <- terra::rast(f)
  expect_true(inherits(r, "SpatRaster"))

  unlink(f)

})



test_that("edl_download, netrc+curl", {

  skip_on_cran()
  skip_if_offline()
  skip("not implemented")

  url <- lpdacc_example_url()
  f <- tempfile(fileext = ".tif")

  edl_download(url, f, auth = "netrc", method = "curl")

  expect_true(file.exists(f))
  r <- terra::rast(f)
  expect_true(inherits(r, "SpatRaster"))

  unlink(f)

})






test_that("httr download via auth", {

  skip_on_cran()
  skip_if_offline()


  edl_netrc()
  dest <- tempfile(fileext = ".tif")
  url <- lpdacc_example_url()
  r <- httr::HEAD(url,
                  httr::config(netrc_file = edl_netrc_path(),
                               cookiefile = edl_cookie_path(),
                               cookiejar = edl_cookie_path()))


  expect_true(httr::status_code(r) < 300)

  username = default("user")
  password = default("password")
  pw <- openssl::base64_encode(paste0(username, ":", password))
  r <- httr::GET(url,
                 httr::config(#netrc_file = netrc_path,
                   cookiefile = edl_cookie_path(),
                   cookiejar = edl_cookie_path()),
                 httr::add_headers(Authorization= paste("Basic", pw)),
                 httr::write_disk(dest, overwrite = TRUE)
  )

  expect_true(httr::status_code(r) < 300)


  # netrc_file does not seem to be respected
  # attempts non-basic auth instead,
  # though succeeds anyway if cookie is already set

    r <- httr::GET(url,
                   httr::config(netrc_file = edl_netrc_path(),
                                cookiefile = edl_cookie_path(),
                                cookiejar = edl_cookie_path()),
                   httr::write_disk(dest, overwrite = TRUE))
    expect_true(httr::status_code(r) < 300)

})

