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
