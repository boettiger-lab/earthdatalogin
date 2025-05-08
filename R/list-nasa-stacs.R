#' List NASA STAC Catalogs
#'
#' Retrieves available STAC catalogs from NASA's Common Metadata Repository (CMR)
#'
#' @param cloud_only Logical; if TRUE (default), returns only cloud-hosted STAC catalogs
#'
#' @return A data frame of STAC catalog urls for all STAC providers in the CMR
#'
#' @seealso [get_nasa_stac_url()]
#'
#' @examples
#' \dontrun{
#' list_nasa_stacs()
#' list_nasa_stacs(cloud_only = FALSE)
#' }
#'
#' @export
list_nasa_stacs <- function(cloud_only = TRUE) {
  cmr_stac_url <- cmr_stac_url(cloud_only)

  cmr_catalogue <- httr::GET(cmr_stac_url)
  httr::stop_for_status(cmr_catalogue)

  content <- httr::content(cmr_catalogue, as = "parsed", simplifyVector = TRUE)

  url_df <- content$links

  url_df[url_df$rel == "child", c("title", "href"), drop = FALSE]
}

#' Get NASA STAC URL for a Provider
#'
#' Retrieves the STAC catalog URL for a specific NASA provider
#'
#' @param provider Character; the name of the NASA STAC provider
#' @param cloud_only Logical; if TRUE (default), returns only cloud-hosted STAC
#'    catalogs
#'
#' @return A character string containing the STAC catalog URL for the specified
#'    provider
#'
#' @seealso [list_nasa_stacs()]
#'
#' @examples
#' \dontrun{
#' get_nasa_stac_url("LPDAAC", cloud_only = FALSE)
#' get_nasa_stac_url("LPCLOUD")
#' }
#'
#' @export
get_nasa_stac_url <- function(provider, cloud_only = TRUE) {
  stacs <- list_nasa_stacs(cloud_only = cloud_only)

  if (!provider %in% stacs$title) {
    stop(
      provider,
      " not found in stacs. Valid providers are: \n  ",
      paste0("'", stacs$title, "'", collapse = ", "),
      call. = FALSE
    )
  }

  stacs$href[stacs$title == provider]
}

cmr_stac_url <- function(cloud_only = TRUE) {
  stopifnot(is.logical(cloud_only))

  base_url <- "https://cmr.earthdata.nasa.gov/"
  endpoint <- if (cloud_only) "cloudstac" else "stac"
  paste0(base_url, endpoint)
}
