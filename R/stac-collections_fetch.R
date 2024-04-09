#' Fetch all collections from an [rstac::collections()] query
#' 
#' By default, NASA STAC catalogue collections queries only return
#' 10 collections at a time. This function will page through 
#' the collections and return them all.
#' 
#' @param collections an object of class `doc_collections` as returned
#'   by calling [rstac::get_request()] on an [rstac::collections()] query
#' @param ... Optional arguments passed on to [httr::GET()]
#' 
#' @return A `doc_collections` object with all of the collections from the catalogue
#'   specified in the [rstac::collections()] query.
#' 
#' @examplesIf interactive()
#' 
#'  rstac::stac("https://cmr.earthdata.nasa.gov/stac/LPCLOUD") |> 
#'    rstac::collections() |> 
#'    rstac::get_request() |> 
#'    collections_fetch()
#' 
#' @export
collections_fetch <- function(collections, ...) {
  
  if (!inherits(collections, "doc_collections")) {
    stop("'collections' must be a `doc_collections` object from the `rstac` package", 
    call. = FALSE)
  }
  
  if (!requireNamespace("rstac", quietly = TRUE)) {
    stop("The rstac package is required to use this function. Please install it", 
    call. = FALSE)
  }
  
  next_url <- get_next_url(collections)
  
  # If that's all there is, return it
  if (is.null(next_url)) return(collections)
  
  base_url <- get_base_url(collections)
  
  qry <- httr::parse_url(next_url)
  
  # Manually recreate the collections query object. This will be fragile
  # if the structure of this changes in future versions of rstac.
  colls <- list(
    version = NULL,
    base_url = base_url,
    endpoint = NULL,
    params = qry$query,
    verb = "GET",
    encode = NULL
  )
  class(colls) <- c("collections", "rstac_query")
  
  prev_collections <- collections$collections
  
  collections <- rstac::get_request(colls)
  
  collections$collections <- c(prev_collections, collections$collections)
  
  collections_fetch(collections)
}

get_next_url <- function(collections) {
  unlist(Filter(function(x) x$rel == "next", collections$links))["href"]
}

get_base_url <- function(collections) {
  unlist(
    Filter(
      function(x) x$rel == "self" & !is.null(x$href), 
      collections$links
    )
  )["href"]
}
