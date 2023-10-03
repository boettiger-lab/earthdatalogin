
knitr::knit("inst/vignette-sources/data-formats.Rmd", "vignettes/data-formats.Rmd")
knitr::knit("inst/vignette-sources/gdalcubes-stac-cog.Rmd", "vignettes/gdalcubes-stac-cog.Rmd")
knitr::knit("inst/vignette-sources/legacy-formats.Rmd", "vignettes/legacy-formats.Rmd")


#fs::file_copy(fs::dir_ls("inst/vignette-sources/img"), "vignettes/img", overwrite = TRUE)
fs::file_copy(fs::dir_ls("img"), "vignettes/img", overwrite = TRUE)
#fs::dir_delete("img")
