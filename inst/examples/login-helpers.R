
#' Renviron Helper utility
#'
#' Asks user for their username and password and store the result in
#' an Renviron file.
#' @param user your EDL username (created at
#'  <https://urs.earthdata.nasa.gov/home>)
#' @param password your EDL password (created at
#' <https://urs.earthdata.nasa.gov/home>)
#' @param verbose show messages?
#' @return adds environmental variables to .Renviron and returns
#' NULL (invisibly.)
#' @examplesIf interactive()
#' edl_renviron()
#'
#' @export
edl_renviron <- function(user = "", password = "", verbose=TRUE) {

  env <- Sys.getenv("EARTHDATA_USER")
  if (env != "") {
    if(verbose) message("EARTHDATA_USER already set")
  } else {
    if(user == "") {
      if(interactive()) user <- readline("Enter your username: ")
      Sys.setenv("EARTHDATA_USER" = user)
      add_renviron("EARTHDATA_USER", user)
    }
  }

  env <- Sys.getenv("EARTHDATA_PASSWORD")
  if (env != "") {
    if(verbose) message("EARTHDATA_PASSWORD already set")
  } else {
    if(password == "") {
      if(interactive()) password <- readline("Enter your password: ")
      Sys.setenv("EARTHDATA_PASSWORD" = password)
      add_renviron("EARTHDATA_PASSWORD", password)
      if(verbose) message("cache set!")
    }
  }

  readRenviron(renviron_path())
  return(invisible(NULL))
}


add_renviron <- function(var, value){
  if(not_defined(var)) {
    readr::write_lines(paste0(var, '="', value, '"'),
               renviron_path(),
               append=TRUE)
  }
}

not_defined <- function(var) {
  readRenviron(renviron_path())
  Sys.getenv(var) == ""
}

renviron_path <- function() {
  fs::path_home_r(".Renviron")
}
