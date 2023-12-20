# edl_search() is an alternative to STAC search for NASA EarthData
# It is less general but can return additional metadata and is often
# much faster than STAC search.  We encourage users to rely on
# the standard STAC, for now this is included only as an example of
# of the NASA CMR API and not an officially supported mechanism
# within the earthdatalogin package.

#' Search for data products using the EarthData API
#'
#' **NOTE**: Use as a fallback method only! Users are strongly encouraged
#'  to rely on the STAC endpoints for NASA EarthData, as shown in the
#'  package vignettes.  STAC is a widely used metadata standard by both
#'  NASA and many other providers, and can be searched using the feature-rich
#'  `rstac` package.  STAC return items can be more easily parsed as well.
#'
#' @param short_name dataset short name e.g. ATL08
#' @param version dataset version
#' @param doi DOI for a dataset
#' @param daac NSIDC or PODAAC
#' @param provider particular to each DAAC, e.g. POCLOUD, LPDAAC etc.
#' @param temporal c("yyyy-mm-dd", "yyyy-mm-dd")
#' @param bounding_box c(lower_left_lon, lower_left_lat, upper_right_lon, upper_right_lat)
#' @param page_size maximum number of results to return
#' @param ... additional query parameters
#' @export
#' @return A response object of the returned search information
#' @examplesIf interactive()
#'
#' items <- edl_search(short_name = "MUR-JPL-L4-GLOB-v4.1",
#'                    temporal = c("2002-01-01", "2021-12-31"))
#'
#' urls <- edl_extract_urls(items)
#'
edl_search <- function(short_name = NULL,
                       version = NULL,
                       doi = NULL,
                       daac = NULL,
                       provider = NULL,
                       temporal = NULL,
                       bounding_box = NULL,
                       page_size = 2000,
                       ...) {

  token <- earthdatalogin::edl_set_token(set_env_var = FALSE,
                                         prompt_for_netrc = FALSE)

  query <- list(short_name = short_name,
                temporal = paste(temporal, collapse=","),
                version = version,
                doi = doi,
                daac = daac,
                provider = provider,
                bounding_box = bounding_box,
                page_size = page_size,
                ...)
  query <- purrr::compact(query)

  url <- "https://cmr.earthdata.nasa.gov/search/granules"
  resp <- httr::GET(url,
                    query = query,
                    httr::add_headers("Authorization"=paste("Bearer", token)))
  httr::stop_for_status(resp)

  entry <- httr::content(resp, "parsed")$feed$entry
  resp_header <- httr::headers(resp)
  continue <- resp_header[["cmr-search-after"]]
  #i <- 1

  while(!is.null(continue)) {
    #dir <- tempfile("earthdata_cache")
    #dir.create(dir)
    #jsonlite::write_json(entry, file.path(dir, paste0("entry_",i, ".json")))

    resp <- httr::GET(url,
              query = query,
              httr::add_headers("Authorization"=paste("Bearer", token),
                                "CMR-Search-After" = continue))

    httr::stop_for_status(resp)

    more_entries <- httr::content(resp, "parsed")$feed$entry
    entry <- c(entry, more_entries)
    #entry <- more_entries

    resp_header <- httr::headers(resp)
    continue <- resp_header[["cmr-search-after"]]

   # i <- i + 1
  }

  #if(i >1) {
  #  files <- list.files(dir, full.names = TRUE)
  #  entry <- lapply(files,  jsonlite::read_json)
  #  entry <- do.call(c, entry)

  #  unlink(dir)
  #}
  structure(entry, class = "cmr_items")
}

#' @export
print.cmr_items <- function(x, ...) {
  print(paste("A CMR search results object with", length(x), "items"))
}

#' Extract data URLs from edl_search
#'
#' **NOTE** this function uses heuristic rules to extract data
#' from edl_search(). Users are strongly encouraged to rely on
#' STAC searches instead.
#'
#' @param items the content object from edl_search
#' @return a character vector of URLs
#' @export
#' @examplesIf interactive()
#'
#' items <- edl_search(short_name = "MUR-JPL-L4-GLOB-v4.1",
#'                    temporal = c("2020-01-01", "2021-12-31"))
#'
#' urls <- edl_extract_urls(items)
#'
edl_extract_urls <- function(items) {
  all_links <- purrr::map(items, "links")
  urls <- purrr::map_chr(all_links, function(links) {
    is_data <-
      grepl("Download", purrr::map_chr(links, "title", .default="")) &
      grepl("\\/data#", purrr::map_chr(links, "rel", .default=""))

    purrr::map_chr(links[is_data], "href")
  })
  urls
}

