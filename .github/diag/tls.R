# Temporary diagnostic: does using GDAL in the same session break TLS to
# urs.earthdata.nasa.gov for R's curl on Linux?  Dummy credentials: a
# healthy connection returns HTTP 401; a broken one raises an SSL error.
pkgload::load_all(".", quiet = TRUE)
probe <- function(label) {
  out <- tryCatch({
    r <- httr::GET("https://urs.earthdata.nasa.gov/api/users/tokens",
                   httr::authenticate("nobody", "x"))
    paste("HTTP", httr::status_code(r))
  }, error = function(e) conditionMessage(e))
  cat(sprintf("%-28s %s\n", label, gsub("\n", " ", out)))
}
print(curl::curl_version()[c("version", "ssl_version")])
probe("fresh session")
library(terra)
probe("after library(terra)")
Sys.setenv(GDAL_HTTP_NETRC = "YES")
r <- try(rast(paste0("/vsicurl/", lpdacc_example_url())), silent = TRUE)
probe("after terra COG read")
gdal_cloud_config()
r <- try(rast(paste0("/vsicurl/", lpdacc_example_url())), silent = TRUE)
probe("after cloud config + read")
nc <- "https://archive.podaac.earthdata.nasa.gov/podaac-ops-cumulus-protected/AVHRR_OI-NCEI-L4-GLOB-v2.1/20200115120000-NCEI-L4_GHRSST-SSTblend-AVHRR_OI-GLOB-v02.0-fv02.1.nc"
r <- try(rast(nc, vsi = TRUE), silent = TRUE)
probe("after netcdf read")
for (i in 1:5) probe(paste("repeat", i))
