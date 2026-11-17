#' Default Earthdata Login credentials
#'
#' Users must supply their own Earthdata Login credentials. They are read,
#' in order, from the `EARTHDATA_USER` and `EARTHDATA_PASSWORD` environment
#' variables and then from the `urs.earthdata.nasa.gov` entry of the user's
#' `.netrc` file in the user's home directory (also `_netrc` and
#' `%USERPROFILE%` on Windows, as curl does). If neither holds credentials,
#' an error explains how to register and store them.
#' @noRd
default <- function(what = c("user", "password")) {
  what <- match.arg(what)
  creds <- edl_default_credentials()
  if (is.null(creds)) {
    stop("No Earthdata Login credentials found. ",
         "Register for a free account at https://urs.earthdata.nasa.gov, ",
         "then call edl_netrc(username, password), or set the ",
         "EARTHDATA_USER and EARTHDATA_PASSWORD environment variables ",
         "(e.g. in ~/.Renviron).", call. = FALSE)
  }
  creds[[what]]
}

#' Look up the user's Earthdata Login credentials
#' @return list(user, password), or NULL if none are found
#' @noRd
edl_default_credentials <- function() {
  user <- Sys.getenv("EARTHDATA_USER")
  password <- Sys.getenv("EARTHDATA_PASSWORD")
  if (nzchar(user) && nzchar(password)) {
    return(list(user = user, password = password))
  }
  for (path in home_netrc_paths()) {
    creds <- read_netrc_credentials(path)
    if (!is.null(creds)) return(creds)
  }
  NULL
}

#' Netrc files curl reads by default: $HOME/.netrc, and on Windows also
#' %USERPROFILE% and _netrc. R's "~" is not used because on Windows it
#' points at the Documents folder rather than the user's home.
#' @noRd
home_netrc_paths <- function() {
  if (.Platform$OS.type == "windows") {
    homes <- Sys.getenv(c("HOME", "USERPROFILE"))
    names <- c(".netrc", "_netrc")
  } else {
    homes <- Sys.getenv("HOME")
    names <- ".netrc"
  }
  homes <- unique(homes[nzchar(homes)])
  if (length(homes) == 0) return(character(0))
  as.vector(outer(homes, names, file.path))
}

#' Read the login and password for a machine from a netrc file
#' @return list(user, password), or NULL if the file has no such entry
#' @noRd
read_netrc_credentials <- function(path,
                                   machine = "urs.earthdata.nasa.gov") {
  if (!file.exists(path)) return(NULL)
  tokens <- scan(path, what = "character", quiet = TRUE,
                 comment.char = "#", quote = "\"")
  starts <- which(tokens %in% c("machine", "default"))
  for (i in starts) {
    if (tokens[i] != "machine" || i == length(tokens) ||
        tokens[i + 1] != machine) {
      next
    }
    end <- c(starts[starts > i], length(tokens) + 1)[1] - 1
    entry <- tokens[seq.int(i + 2, length.out = max(end - i - 1, 0))]
    value <- function(key) {
      j <- which(entry == key)[1]
      if (is.na(j) || j == length(entry)) "" else entry[j + 1]
    }
    user <- value("login")
    password <- value("password")
    if (nzchar(user) && nzchar(password)) {
      return(list(user = user, password = password))
    }
  }
  NULL
}
