
#' with_gdalcubes
#'
#' expose any `GDAL_*` or `VSI_*` environmental variables to
#' gdalcubes, which calls GDAL in an isolated environment
#' and does not respect the global environmental variables.
#'
#' @param env a named vector of set environmental variables. Default
#'  is usually best, which will configure all relevant global environmental
#'  variables for gdalcubes.
#' @return NULL, invisibly.
#' @examplesIf requireNamespace("gdalcubes", quietly = TRUE)
#'  with_gdalcubes()
#'
#' @export
with_gdalcubes <- function(env = Sys.getenv()) {

  gdal_vars <- grepl("^GDAL_", names(env))
  gdalcubes_config(env[gdal_vars])

  vsi_vars <- grepl("^VSI_", names(env))
  gdalcubes_config(env[vsi_vars])

  cpl_var <- grepl("^CPL_VSIL_", names(env))
  gdalcubes_config(env[cpl_var])

}


gdalcubes_config <- function(vars) {

  if(!requireNamespace("gdalcubes", quietly = TRUE)) {
    return(invisible(NULL))
  }

  labels <- names(vars)
  for(i in seq_along(vars)) {
    key <- labels[[i]]
    value <- vars[[i]]
    gdalcubes::gdalcubes_set_gdal_config(key, value)
  }

}
