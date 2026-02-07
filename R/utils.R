#' @title Add Significance Asterisks
#' @description Given a `data.frame` with a column containing p-values or two columns
#' containing the lower- and upper bounds of a confidence interval, adds a
#' column of significance asterisks.
#' @param x A `data.frame`
#' @param p_column Atomic character, referring to the name of the column of
#' p-values. If this is provided, the confidence interval is ignored. Default:
#' `NULL`
#' @param ci_lb Atomic character, referring to the name of the column of
#' the lower bound of a confidence interval. Default: `NULL`
#' @param ci_up Atomic character, referring to the name of the column of
#' the upper bound of a confidence interval. Default: `NULL`
#' @param alpha Significance level, default: `.05`
#' @return A `data.frame`
#' @examples
#' tmp <- add_significance(head(iris))
#' @rdname add_significance
#' @export
add_significance <- function(x, p_column = NULL, ci_lb = NULL, ci_up = NULL, alpha = .05){
  if(all(is.null(c(p_column, ci_lb, ci_up)))){
    nams <- names(x)
    if(sum(grepl("%", nams, fixed = TRUE)) == 2){
      ci_lb <- grep("%", nams, fixed = TRUE, value = TRUE)[1]
      ci_ub <- grep("%", nams, fixed = TRUE, value = TRUE)[2]
    } else {
      return(x)
    }
  }
  if(!is.null(p_column)){
    issig <- x[[p_column]] < alpha
  } else {
    issig <- !(rowSums(sign(x[, c(ci_lb, ci_ub)])) == 0)
  }
  x$significant <- c("", "*")[as.integer(issig)+1]
  return(x)
}


path_rel <- function(fn, dn){
  unname(sapply(fn, function(the_fn){
    the_fn <- normalizePath(the_fn, winslash = .Platform$file.sep, mustWork = FALSE)
    dn <- normalizePath(dn, winslash = .Platform$file.sep)
    # Check for OS
    on_windows <- isTRUE(grepl("mingw", R.Version()$os, fixed = TRUE))
    if (on_windows) {
      dn <- tolower(dn)
      the_fn <- tolower(the_fn)
    }
    # Split pathnames into components
    dn <- unlist(strsplit(dn, split = .Platform$file.sep, fixed = TRUE))
    the_fn <- unlist(strsplit(the_fn, split = .Platform$file.sep, fixed = TRUE))
    if(length(dn) > length(the_fn)){
      stop("File path must be inside of the worcs project file.", call. = FALSE)
    }

    if(!all(dn == the_fn[seq_along(dn)])){
      stop("File path must be inside of the worcs project file.", call. = FALSE)
    }
    do.call(file.path, as.list(the_fn[-seq_along(dn)]))
  }))
}

copy_create_dir <- function(from, to, ...) {
  for(i in seq_along(from)){
    if (!dir.exists(dirname(to[i])))  dir.create(dirname(to[i]), recursive = TRUE)
    file.copy(from = from[i],  to = to[i], ...)
  }
}

scoped_tempdir <- function (code){

  new <- tempfile(pattern = "file", tmpdir = tempdir(), fileext = "")
  dir.create(new)
  on.exit(unlink(new, recursive = TRUE), add = TRUE)
  old <- setwd(dir = new)
  on.exit(setwd(old))
  force(code)
}

