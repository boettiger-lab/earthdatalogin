default <- function(what) {

  href <- paste0("https://raw.githubusercontent.com/",
         "boettiger-lab/earthdatalogin/main/inst/.Renviron")
  tryCatch(readRenviron(href),
           warning = function(e) NULL)
  switch(what,
         user = Sys.getenv("EARTHDATA_USER", "earthaccess"),
         password = Sys.getenv("EARTHDATA_PASSWORD", "EDL_test1"))
}
