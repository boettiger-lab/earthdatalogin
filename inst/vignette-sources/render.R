
knitr::knit("inst/vignette-sources/gdalcubes-stac-cog.Rmd", "vignettes/gdalcubes-stac-cog.Rmd")
knitr::knit("inst/vignette-sources/legacy-formats.Rmd", "vignettes/legacy-formats.Rmd")
fs::file_move("img", "vignettes/img")
