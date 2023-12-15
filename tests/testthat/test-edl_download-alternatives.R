test_that("edl_download via httr", {

  skip("not implemented")

  skip_on_cran()
  skip_if_offline()

  edl_unset_netrc()

  url <- lpdacc_example_url()
  f <- tempfile(pattern = "HSL", fileext = ".tif")

  edl_download(url, f, method="httr")


  expect_true(file.exists(f))
  r <- terra::rast(f)
  expect_true(inherits(r, "SpatRaster"))

  unlink(f)

})


test_that("httr download via auth", {

  skip("not implemented")

  skip_on_cran()
  skip_if_offline()
  edl_unset_netrc()


  edl_netrc()
  dest <- tempfile(fileext = ".tif")
  url <- lpdacc_example_url()


  # netrc_file does not seem to be respected
  # attempts non-basic auth instead,
  # though succeeds anyway if cookie is already set

  r <- httr::GET(url,
                 httr::config(netrc_file = edl_netrc_path(),
                              cookiefile = edl_cookie_path(),
                              cookiejar = edl_cookie_path()),
                 httr::verbose(),
                 httr::write_disk(dest, overwrite = TRUE))
  expect_true(httr::status_code(r) < 300)

})



test_that("nope", {

  skip("not implemented")

  edl_unset_netrc()
  edl_netrc()
  dest <- tempfile(fileext = ".tif")
  url <- lpdacc_example_url()

  h <- curl::new_handle(netrc_file = edl_netrc_path(),
                        cookiefile = edl_cookie_path(),
                        cookiejar = edl_cookie_path(),
                        verbose = TRUE)
  curl::curl_download(url, dest, handle = h)

  edl_unset_netrc()
  edl_netrc()

  r <- httr::HEAD(url,
                  httr::verbose(),
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
                 httr::verbose(),
                 httr::add_headers(Authorization= paste("Basic", pw)),
                 httr::write_disk(dest, overwrite = TRUE)
  )

  expect_true(httr::status_code(r) < 300)




})

