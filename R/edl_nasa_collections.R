collections_fetch <- function(collections) {
  
  next_url <- get_next_url(collections)
  base_url <- unlist(Filter(function(x) x$rel == "self" & !is.null(x$href), collections$links))["href"]
  
  while (!is.null(next_url)) {
    qry <- httr::parse_url(next_url)

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
    next_url <- get_next_url(collections)
  }
  collections
}

get_next_url <- function(collections) {
  unlist(Filter(function(x) x$rel == "next", collections$links))["href"]
}
