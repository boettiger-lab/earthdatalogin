default <- function(what) {

  if (Sys.getenv("EARTHDATA_USER") == "" ||
      Sys.getenv("EARTHDATA_PASSWORD") == "") {
    href <- paste0("https://raw.githubusercontent.com/",
           "boettiger-lab/earthdatalogin/main/inst/.Renviron")
    renviron <- tempfile("Renviron")
    download.file(href, renviron, quiet = TRUE)
    tryCatch(readRenviron(renviron),
             warning = function(e) NULL)
    unlink(renviron) # clean up
  }

    switch(what,
           user = Sys.getenv("EARTHDATA_USER", "earthaccess"),
           password = Sys.getenv("EARTHDATA_PASSWORD", "EDL_test1"))
}
