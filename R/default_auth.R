default <- function(what) {

  href <- paste0("https://raw.githubusercontent.com/",
         "boettiger-lab/earthdatalogin/main/inst/.Renviron")
  renviron <- tempfile("Renviron")
  download.file(href, renviron)
  tryCatch(readRenviron(renviron),
           warning = function(e) NULL)
  unlink(renviron) # clean up
  switch(what,
         user = Sys.getenv("EARTHDATA_USER", "earthaccess"),
         password = Sys.getenv("EARTHDATA_PASSWORD", "EDL_test1"))
}
