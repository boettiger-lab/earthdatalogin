# Temporary diagnostic: does the netcdf test fail only after other tests
# have run in the same session? Each scenario runs in a fresh R process.
scenario <- commandArgs(TRUE)[1]
Sys.setenv(EDL_ONLINE_TESTS = "true", NOT_CRAN = "true")
files <- switch(scenario,
  netrc_only = "test-edl_netrc.R",
  download_then_netrc = c("test-edl_download.R", "test-edl_netrc.R"))
pkgload::load_all(".", quiet = TRUE)
for (f in files) {
  res <- as.data.frame(testthat::test_file(file.path("tests/testthat", f),
                                           reporter = "silent",
                                           package = "earthdatalogin",
                                           load_package = "none"))
  for (i in seq_len(nrow(res))) {
    cat(sprintf("%-20s %-28s %-45s failed=%d error=%s skipped=%s\n",
                scenario, f, res$test[i], res$failed[i], res$error[i],
                res$skipped[i]))
  }
}
cat(scenario, "GDAL_HTTP_HEADER_FILE set at end:",
    nzchar(Sys.getenv("GDAL_HTTP_HEADER_FILE")), "\n")
