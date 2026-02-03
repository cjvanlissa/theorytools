#' Download FAIR Theory
#'
#' Downloads a FAIR theory archive from a 'Git' remote repository or 'Zenodo'.
#' @inheritParams create_fair_theory
#' @param id URL of the 'Git' repository or DOI of the 'Zenodo' archive.
#' @importFrom curl curl_fetch_memory curl_download
#' @importFrom gert git_clone
#' @importFrom jsonlite fromJSON
#' @importFrom tools md5sum
#' @export
#' @examples
#' \dontrun{
#' # These examples require internet access and may fail if resources are unavailable
#' download_theory(id = "https://github.com/cjvanlissa/tripartite_model.git",
#' path = file.path(tempdir(), "tripartite_git"))
#' download_theory(id = "10.5281/zenodo.14921521",
#' path = file.path(tempdir(), "tripartite_zenodo"))
#' }
download_theory <- function(id,
                            path = ".") {

  # check for existence of the folder
  if(!dir.exists(path)){
    with_cli_try("Creating theory repository at {.val {path}}", {
      dir.create(path)
    })
  }

  record_type <- git_or_zenodo(id)

  switch(record_type,
         "git" = {
           with_cli_try("Cloning repository from 'Git' remote", {
             git_remote_exists(id)
             tmp <- gert::git_clone(url = id, path = path, verbose = FALSE)
             if(!dir.exists(path)) stop()
           })
         },
         "zenodo" = {
           with_cli_try("Accessing record on 'Zenodo'", {
             record <- jsonlite::fromJSON(rawToChar(curl::curl_fetch_memory(paste0("https://zenodo.org/api/records/", gsub("^.{0,}10.5281/zenodo\\.", "", id)))$content))
             url_zip <- record$files$links$self
             if(!grepl(".zip", url_zip, fixed = TRUE)){
               stop()
             }
             filename <- basename(record$files$key)
             file_temp <- file.path(tempdir(), filename)
             zenodo_checksum <- record$files$checksum
           })

           with_cli_try("Download ZIP archive", {
             tmp <- curl::curl_download(url_zip, file_temp)
             if(!file.exists(tmp)) stop()
             download_checksum <- unname(tools::md5sum(tmp))
             grepl(download_checksum, zenodo_checksum, fixed = TRUE)
           })

           with_cli_try("Create local FAIR theory repository", {
             dir_unzip <- file.path(tempdir(), "temp_unzip")
             dir.create(dir_unzip)
             on.exit(unlink(dir_unzip, recursive = TRUE))
             utils::unzip(zipfile = file_temp, exdir = dir_unzip)
             dir_parent <- list.dirs(dir_unzip, recursive = FALSE)[1]
             files <- list.files(dir_parent, recursive = TRUE, full.names = TRUE)
             files_rel <- path_rel(files, dn = dir_parent)
             files_dest <- file.path(path, files_rel)
             copy_create_dir(from = files, to = files_dest)
           })
         },
         return(NULL)
         )
}

#' @importFrom gert git_remote_ls
git_or_zenodo <- function(x){
  if(grepl("10.5281/zenodo.", x, fixed = TRUE)){
    return("zenodo")
  }
  if(grepl("git", x, fixed = TRUE)){
      return("git")
  }
  stop("Not a valid 'Git' or 'Zenodo' archive.")
}

git_remote_exists <- function(x){
  out <- try({
    # Because git_remote_ls needs to be called from an active git repo
    f <- getwd()
    in_repo <- tryCatch({
      gert::git_open(f)
      TRUE
    }, error = function(e){FALSE})
    if(!in_repo){
      f <- file.path(tempdir(), "deleteme")
      dir.create(f)
      on.exit(unlink(f, recursive = TRUE))
      gert::git_init(path = f, bare = TRUE)
    }
    gert::git_remote_ls(x, verbose = FALSE, repo = f)
  }, silent = TRUE)
  return(isFALSE(inherits(out, "try-error")))
}
