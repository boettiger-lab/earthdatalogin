# Temporary diagnostic: why does the PODAAC NetCDF read fail on CI?
# Prints only status codes, hosts and content types; never headers, query
# strings or credentials.
pkgload::load_all(".", quiet = TRUE)
library(terra)
url <- "https://archive.podaac.earthdata.nasa.gov/podaac-ops-cumulus-protected/AVHRR_OI-NCEI-L4-GLOB-v2.1/20200115120000-NCEI-L4_GHRSST-SSTblend-AVHRR_OI-GLOB-v02.0-fv02.1.nc"
lp <- lpdacc_example_url()

edl_netrc(cloud_config = TRUE)

# 1. Follow the redirect chain with httr, using the same netrc and cookies
for (i in 1:3) {
  r <- tryCatch(
    httr::GET(url, httr::config(netrc = TRUE, netrc_file = edl_netrc_path(),
                                cookiefile = edl_cookie_path(),
                                cookiejar = edl_cookie_path()),
              httr::add_headers(Range = "bytes=0-99")),
    error = function(e) e)
  if (inherits(r, "error")) { cat("httr", i, "error:", conditionMessage(r), "\n"); next }
  hops <- vapply(r$all_headers, function(h) paste(h$status), "")
  hosts <- vapply(r$all_headers, function(h) {
    loc <- h$headers$location
    if (is.null(loc)) return("-")
    host <- httr::parse_url(loc[[1]])$hostname
    if (is.null(host) || !nzchar(host)) "relative" else host
  }, "")
  cat("httr", i, "status chain:", paste(hops, collapse = " > "),
      "| redirect hosts:", paste(hosts, collapse = " > "),
      "| final type:", httr::headers(r)[["content-type"]],
      "| bytes:", length(httr::content(r, "raw")), "\n")
}

# 2. GDAL reads, repeated, NetCDF and COG
probe <- function(label, expr) {
  t <- system.time(out <- tryCatch({ force(expr); "ok" },
                                   error = function(e) gsub("\n", " ", substr(conditionMessage(e), 1, 120))))
  cat(sprintf("%-22s %-6s %5.1fs\n", label, out, t[["elapsed"]]))
}
for (i in 1:4) {
  probe(paste("netcdf vsi", i), rast(url, vsi = TRUE))
  probe(paste("cog vsi", i), rast(lp, vsi = TRUE))
}
cat("GDAL", gdal(), "| drivers netCDF:", "netCDF" %in% gdal(drivers = TRUE)$name, "\n")
