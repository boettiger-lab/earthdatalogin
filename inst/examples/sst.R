

devtools::load_all()
resp <- edl_search(short_name = "MUR-JPL-L4-GLOB-v4.1",
                   temporal = c("2020-01-01", "2020-12-31"))
urls <- edl_extract_urls(resp)

urls <- urls[1:4]
prefix <-  "vrt://NETCDF:/vsicurl/"
suffix <- ":analysed_sst?a_srs=OGC:CRS84&a_ullr=-180,90,180,-90"
uri <- paste0(prefix, urls, suffix)


library(gdalcubes)
header = edl_set_token(format="header", set_env_var = FALSE)
gdalcubes_set_gdal_config("GDAL_HTTP_HEADERS", header)
gdalcubes_options(parallel = TRUE)


dates <- stringr::str_extract(basename(urls), "\\d{14}") |> lubridate::as_datetime()
col <- create_image_collection(uri, date_time = dates )

# Desired data cube shape & resolution
v = cube_view(srs = "EPSG:4326",
              extent = list(t0 = "2020-01-01", t1 = "2020-12-31",
                            left = -93, right = -76,
                            top = 41, bottom = 49),
              nx = 2000, ny = 2000, dt = "P1M")

bench::bench_time({
raster_cube(col, v) |> gdalcubes::write_tif("~/test")
})

bench::bench_time({
  f <- fs::dir_ls("~/test")
  dates <- paste("2020", 1:12, "01", sep="-")
  stack_cube(f, datetime_values = dates) |> plot()
})


library(stars)
read_stars(f, along=dates) |>
plot(col = viridisLite::magma(30), nbreaks=31)
#col <- stack_cube(uri, datetime_values = dates )
#plot(col)
