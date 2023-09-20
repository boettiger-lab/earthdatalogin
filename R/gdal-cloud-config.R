
#' Recommended GDAL configuration for cloud-based access
#'
#' Sets GDAL environmental variables to recommended optimum settings for
#' cloud-based access.
#'
#' Based on
#' <https://gdalcubes.github.io/source/concepts/config.html#recommended-settings-for-cloud-access>
#' @return sets recommended environmental variables
#' @examplesIf interactive()
#' gdal_cloud_config()
#'
#' @export
gdal_cloud_config <- function() {
  # set recommended variables for cloud access:
  Sys.setenv("VSI_CACHE" = "TRUE")
  Sys.setenv("GDAL_CACHEMAX" = "30%")
  Sys.setenv("VSI_CACHE_SIZE" = "10000000")
  Sys.setenv("GDAL_HTTP_MULTIPLEX" = "YES")
  Sys.setenv("GDAL_INGESTED_BYTES_AT_OPEN" = "32000")
  Sys.setenv("GDAL_DISABLE_READDIR_ON_OPEN" = "EMPTY_DIR")
  Sys.setenv("GDAL_HTTP_VERSION" = "2")
  Sys.setenv("GDAL_HTTP_MERGE_CONSECUTIVE_RANGES" = "YES")
  Sys.setenv("GDAL_NUM_THREADS" = "ALL_CPUS")

  # support TIF writes to S3
  Sys.setenv("CPL_VSIL_USE_TEMP_FILE_FOR_RANDOM_WRITE"="YES")

  # Be more stubborn
  Sys.setenv("GDAL_HTTP_CONNECTTIMEOUT" = "20")
  Sys.setenv("GDAL_HTTP_TIMEOUT" = "60")
  Sys.setenv("GDAL_HTTP_MAX_RETRY" = "10")

}

# GDAL_PROXY_AUTH="BEARER" take
# just set CURLOPT_XOAUTH2_BEARER as token?
