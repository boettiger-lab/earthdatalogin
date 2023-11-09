
# remotes::install_github("boettiger-lab/earthdatalogin@edl_search", force=TRUE)
library(earthdatalogin)
resp <- edl_search(short_name = "MUR-JPL-L4-GLOB-v4.1",
                   temporal = c("2020-01-01", "2021-12-31"))
urls <- edl_extract_urls(resp)

prefix <-  "vrt://NETCDF:/vsicurl/"
suffix <- ":analysed_sst?a_srs=OGC:CRS84&a_ullr=-180,90,180,-90"
uri <- paste0(prefix, urls, suffix)


library(gdalcubes)
header = edl_set_token(format="header", set_env_var = FALSE)
gdalcubes_set_gdal_config("GDAL_HTTP_HEADERS", header)
gdalcubes_options(parallel = 100)

dates <- stringr::str_extract(basename(urls), "\\d{14}") |> lubridate::as_datetime()
cube <- stack_cube(uri, datetime_values = dates)


bench::bench_time({ # ~ 20 min
  cube |>
    gdalcubes::crop(extent = list(t0 = "2020-01-01T09:00:00",
                                  t1 = "2021-12-03T09:00:00",
                                  left = -93, right = -76,
                                  top = 41, bottom = 49) ) |>
    gdalcubes::write_tif("~/sst_2yr")
})


## Now we can quickly manipulate, aggregate and plot
files <- fs::dir_ls("~/sst_2yr")
dates_values <- stringr::str_extract(files, "\\d{4}-\\d{2}-\\d{2}")
cube2 <- stack_cube(files, datetime_values = dates_values)

cube2 |>
  aggregate_time("P2Y") |>
  plot(col = viridisLite::viridis(30), nbreaks=31)

