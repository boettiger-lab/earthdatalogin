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
#' @param doi DOI for a dataset, e.g. "10.5067/HLS/HLSL30.002" 
#' @param daac NSIDC or PODAAC
#' @param provider particular to each DAAC, e.g. POCLOUD, LPDAAC etc.
#' @param temporal c(start, end), e.g. c("yyyy-mm-dd", "yyyy-mm-dd"). Each
#'  element may be a "Date", a "POSIXct", or a character string. Strings with
#'  a time are passed to CMR unchanged. Use "NA" or "" for an open-ended range.
#' @param bounding_box c(lower_left_lon, lower_left_lat, upper_right_lon, upper_right_lat)
#' @param page_size maximum number of results to return per query.
#' @param ... additional query parameters
#' @param recurse If a query returns more than page_size results, should
#'   we make recursive calls to return all results?
#' @param parse_results logical, default TRUE. Calls [edl_extract_urls()]
#'  to determine url links to data objects.  Set to FALSE to return
#'  the full API response object, but be wary of large object sizes
#'  when search returns many results.
#' @inheritParams edl_netrc
#' @export
#' @return A character vector of data URLs matching the search criteria,
#' if `parse_results = TRUE` (default).  Otherwise, returns a response object
#'  of the returned search information if `parse_results = FALSE`.
#' @examplesIf interactive()
#'
#' items <- edl_search(short_name = "MUR-JPL-L4-GLOB-v4.1",
#'                    temporal = c("2002-01-01", "2021-12-31"),
#'                    recurse = TRUE,
#'                    parse_urls = TRUE)
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
                       recurse = TRUE,
                       parse_results = TRUE,
                       username = default("user"),
                       password = default("password"),
                       netrc_path = edl_netrc_path(),
                       cookie_path = edl_cookie_path(),
                       ...) {

  #token <- earthdatalogin::edl_set_token(set_env_var = FALSE,
  #                                       prompt_for_netrc = FALSE)


  # Only (re)write the netrc when the caller explicitly supplies
  # credentials, or when no earthdata netrc exists yet, so searching never
  # clobbers credentials a user already stored with edl_netrc() (#27).
  # CMR search is public, so search anonymously if the user has no
  # credentials at all.
  if (!missing(username) || !missing(password) ||
      (!has_edl_netrc(netrc_path) && !is.null(edl_default_credentials()))) {
    edl_netrc(username = username,
              password = password,
              netrc_path = netrc_path,
              cookie_path = cookie_path,
              cloud_config = FALSE)
  }
  netrc_config <- NULL
  if (has_edl_netrc(netrc_path)) {
    netrc_config <-
      httr::config(netrc = TRUE,
                   netrc_file = netrc_path,
                   cookiefile = cookie_path,
                   cookiejar = cookie_path)
  }

  query <- list(short_name = short_name,
                temporal = cmr_temporal(temporal),
                version = version,
                daac = daac,
                provider = provider,
                bounding_box = paste(as.character(bounding_box), collapse = ","),
                page_size = page_size,
                ...)
  query <- purrr::compact(query)

  # CMR granule search rejects `doi`. When `doi` is provided, retrieve
  # the collection concept id and search granules using that instead.
  if (!is.null(doi)) {
    query$collection_concept_id <-
      doi_concept_id(doi, provider = provider, config = netrc_config)
  }

  url <- "https://cmr.earthdata.nasa.gov/search/granules"
  resp <- httr::GET(url,  query = query, netrc_config)
  httr::stop_for_status(resp)

  entry <- httr::content(resp, "parsed")$feed$entry
  resp_header <- httr::headers(resp)
  continue <- resp_header[["cmr-search-after"]]
  #i <- 1


  if(recurse){
    while(!is.null(continue)) {

      resp <- httr::GET(url,
                query = query,
                netrc_config,
                httr::add_headers("CMR-Search-After" = continue))

      more_entries <- httr::content(resp, "parsed")$feed$entry
      entry <- c(entry, more_entries)

      resp_header <- httr::headers(resp)
      continue <- resp_header[["cmr-search-after"]]

    }
  }

  if (!parse_results) {
    return(  structure(entry, class = "cmr_items") )
  }

  edl_extract_urls(entry)
}

#' Retrieve the CMR collection concept id for a DOI
#'
#' @return the concept id (e.g. "C2021957657-LPCLOUD") of the first matching
#'   collection, with a warning if several collections match, or errors if
#'   no collections match.
#' @noRd
doi_concept_id <- function(doi, provider = NULL, config = NULL) {
  stopifnot(is.character(doi), length(doi) == 1)

  entries <- cmr_collection_search(
    purrr::compact(list(doi = doi, provider = provider)),
    config = config
  )
  if (length(entries) == 0) {
    stop("No CMR collection found for DOI '", doi, "'",
         if (!is.null(provider)) paste0(" and provider '", provider, "'"),
         ".", call. = FALSE)
  }
  if (length(entries) > 1) {
    found <- vapply(entries, function(e) {
      paste0(e$id, " (", e$short_name %||% "?", " v", e$version_id %||% "?",
             ", provider ", e$data_center %||% "?", ")")
    }, character(1))
    warning("Multiple CMR collections found for DOI '", doi, "':\n  ",
            paste(found, collapse = "\n  "),
            "\nUsing the first: ", entries[[1]]$id,
            ". Use `collection_concept_id` instead of `doi` to choose a different one.",
            call. = FALSE)
  }
  entries[[1]]$id
}

#' Search the CMR collection endpoint
#' @return list of collection entries
#' @noRd
cmr_collection_search <- function(query, config = NULL) {
  resp <- httr::GET("https://cmr.earthdata.nasa.gov/search/collections.json",
                    query = c(query, page_size = 2000), config)
  httr::stop_for_status(resp)
  httr::content(resp, "parsed")$feed$entry
}

#' Format a temporal range for CMR
#'
#' CMR reads a date with no time as midnight, so `temporal = c("2025-07-01", "2025-07-01")`
#' will become zero length, with both start and end at midnight. This extends a 
#' date-only end to the end of the day 23:59:59.
#' @return "start,end" string, or NULL if `temporal` is NULL
#' @noRd
cmr_temporal <- function(temporal) {
  if (is.null(temporal)) return(NULL)
  if (length(temporal) < 1 || length(temporal) > 2) {
    stop("`temporal` must be c(start, end) or a single start date.",
         call. = FALSE)
  }
  as_cmr_time <- function(x, end) {
    if (is.null(x) || is.na(x)) return("")
    if (inherits(x, "POSIXt")) {
      return(format(x, "%Y-%m-%dT%H:%M:%SZ", tz = "UTC"))
    }
    x <- trimws(as.character(x))
    # treat "NA" as empty string
    if (identical(toupper(x), "NA")) return("")
    if (grepl("^\\d{4}-\\d{2}-\\d{2}$", x)) {
      x <- paste0(x, if (end) "T23:59:59Z" else "T00:00:00Z")
    }
    x
  }
  start <- as_cmr_time(temporal[1], end = FALSE)
  end <- if (length(temporal) == 2) as_cmr_time(temporal[2], end = TRUE) else ""
  paste0(start, ",", end)
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
#'                    temporal = c("2020-01-01", "2021-12-31"),
#'                    parse_urls = FALSE)
#'
#' urls <- edl_extract_urls(items)
#'
edl_extract_urls <- function(items) {
  all_links <- purrr::map(items, "links")
  # A granule may carry multiple data assets (e.g. one tif per band), so map
  # over granules and flatten -- map_chr would error on the >1 case (#15).
  urls <- purrr::map(all_links, function(links) {
    is_data <-
      grepl("Download", purrr::map_chr(links, "title", .default="")) &
      grepl("\\/data#", purrr::map_chr(links, "rel", .default=""))

    purrr::map_chr(links[is_data], "href")
  })
  unlist(urls, use.names = FALSE)
}
