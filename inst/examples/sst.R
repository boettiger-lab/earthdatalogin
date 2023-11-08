
# remotes::install_github("boettiger-lab/earthdatalogin@edl_search", force=TRUE)
library(earthdatalogin)
devtools::load_all()
resp <- edl_search(short_name = "MUR-JPL-L4-GLOB-v4.1",
                   temporal = c("2020-01-01", "2020-12-31"))
urls <- edl_extract_urls(resp)

prefix <-  "vrt://NETCDF:/vsicurl/"
suffix <- ":analysed_sst?a_srs=OGC:CRS84&a_ullr=-180,90,180,-90"
uri <- paste0(prefix, urls, suffix)


library(gdalcubes)
header = edl_set_token(format="header", set_env_var = FALSE)
gdalcubes_set_gdal_config("GDAL_HTTP_HEADERS", header)
gdalcubes_options(parallel = 100)


dates <- stringr::str_extract(basename(urls), "\\d{14}") |> lubridate::as_datetime()


bench::bench_time({
col <- create_image_collection(uri, date_time = dates )
})

# Desired data cube shape & resolution
v = cube_view(srs = "EPSG:4326",
              extent = list(t0 = "2020-01-01", t1 = "2020-12-31",
                            left = -93, right = -76,
                            top = 41, bottom = 49),
              nx = 1000, ny = 1000, dt = "P1M")

bench::bench_time({
raster_cube(col, v) |> gdalcubes::write_tif("~/sst2")
})


f <- fs::dir_ls("~/sst2")
dates <- stringr::str_extract(f, "\\d{4}-\\d{2}-\\d{2}")
library(stars)
x = read_stars(f, along=list(time=dates))
plot(x, col = viridisLite::mako(30), nbreaks =31)


# not sure why this fails
# stack_cube(f, datetime_values = dates) |> plot(zlim=c(-27000,2100))
