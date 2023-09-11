
knitr::knit("inst/tutorials/gdalcubes-stac-cog.Rmd", "vignettes/gdalcubes-stac-cog.Rmd")
knitr::knit("inst/tutorials/legacy-formats.Rmd", "vignettes/legacy-formats.Rmd")
fs::file_move("img", "vignettes/img")
