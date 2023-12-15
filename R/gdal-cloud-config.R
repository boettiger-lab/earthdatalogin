
#' Recommended GDAL configuration for cloud-based access
#'
#' Sets GDAL environmental variables to recommended optimum settings for
#' cloud-based access.
#'
#' Based on
#' <https://gdalcubes.github.io/source/concepts/config.html#recommended-settings-for-cloud-access>
#' @return sets recommended environmental variables and returns invisible TRUE
#' if successful.
#' @examplesIf interactive()
#' gdal_cloud_config()
#'
#' # remove settings:
#' gdal_cloud_unconfig()
#' @seealso [gdal_cloud_unconfig()]
#' @export
gdal_cloud_config <- function() {
  # Highly recommended variables for improved cloud access performance:
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

  # Be more stubborn -- earthaccess can be flaky
  Sys.setenv("GDAL_HTTP_CONNECTTIMEOUT" = "20")
  Sys.setenv("GDAL_HTTP_TIMEOUT" = "60")
  Sys.setenv("GDAL_HTTP_MAX_RETRY" = "10")

}


#' Restores GDAL default configuration
#'
#'
#' Unsets GDAL environmental variables set by [gdal_cloud_config()]
#'
#' @return invisible TRUE if successful.
#' @examplesIf interactive()
#' gdal_cloud_config()
#'
#' # remove settings:
#' gdal_cloud_unconfig()
#' @seealso [gdal_cloud_config()]
#' @export
gdal_cloud_unconfig <- function() {
  Sys.unsetenv("VSI_CACHE")
  Sys.unsetenv("GDAL_CACHEMAX")
  Sys.unsetenv("VSI_CACHE_SIZE")
  Sys.unsetenv("GDAL_HTTP_MULTIPLEX")
  Sys.unsetenv("GDAL_INGESTED_BYTES_AT_OPEN")
  Sys.unsetenv("GDAL_DISABLE_READDIR_ON_OPEN")
  Sys.unsetenv("GDAL_HTTP_VERSION")
  Sys.unsetenv("GDAL_HTTP_MERGE_CONSECUTIVE_RANGES")
  Sys.unsetenv("GDAL_NUM_THREADS")

  # support TIF writes to S3
  Sys.unsetenv("CPL_VSIL_USE_TEMP_FILE_FOR_RANDOM_WRITE")

  # Be more stubborn
  Sys.unsetenv("GDAL_HTTP_CONNECTTIMEOUT")
  Sys.unsetenv("GDAL_HTTP_TIMEOUT")
  Sys.unsetenv("GDAL_HTTP_MAX_RETRY")

}
