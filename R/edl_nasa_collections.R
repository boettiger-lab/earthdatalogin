edl_nasa_collections <- function(q) {
  colls <- rstac::collections(q, collection_id = NULL)
  colls_resp <- rstac::get_request(colls)
  
  next_url <- get_next_url(colls_resp)
  
  while (!is.null(next_url)) {
    qry <- httr::parse_url(next_url)
  
    colls$endpoint <- basename(qry$path)
    colls$params <- qry$query

    prev_collections <- colls_resp$collections
  
    colls_resp <- rstac::get_request(colls)

    colls_resp$collections <- c(prev_collections, colls_resp$collections)
    next_url <- get_next_url(colls_resp)
  }
  colls_resp
}

get_next_url <- function(collections) {
  unlist(Filter(function(x) x$rel == "next", collections$links))["href"]
}