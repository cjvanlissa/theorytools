#' @title Add 'Zenodo' JSON File
#' @description Writes a '.zenodo.json' file to the specified path.
#' @inheritParams create_fair_theory
#' @param upload_type Character, indicating the upload type.
#' @param keywords Character vector of keywords.
#' @inherit create_fair_theory return
#' @examples
#' add_zenodo_json(path = tempdir(), title = "Theory Title",
#'                 upload_type = "software", keywords = "R")
#' @seealso
#'  \code{\link[jsonlite]{read_json}}
#' @rdname add_zenodo_json
#' @export
#' @importFrom jsonlite write_json
add_zenodo_json <- function(path, title, upload_type, keywords){
  if(!dir.exists(path)) stop("Path does not exist.")
  json_data <- list(title = title,
                  upload_type = upload_type,
                  keywords = as.list(keywords))
  out <- jsonlite::toJSON(x = json_data, path = , pretty = TRUE, auto_unbox = TRUE)
  writeLines(out, con = file.path(path, ".zenodo.json"), useBytes = TRUE)
  return(invisible(file.exists(file.path(path, ".zenodo.json"))))
}

#' @title Add Readme File
#' @description Writes a README file to a specific path.
#' @inheritParams create_fair_theory
#' @inheritParams add_zenodo_json
#' @inherit create_fair_theory return
#' @examples
#' add_zenodo_json_theory(path = tempdir(), title = "My Theory",
#'                        keywords = "secondkeyword")
#' add_zenodo_json_theory(path = tempdir(), title = "My Theory",
#'                        keywords = c("secondkeyword", "thirdkeyword"))
#' @rdname add_zenodo_json
#' @export
add_zenodo_json_theory <- function(path, title, keywords){
  worcs:::with_cli_try("Add 'Zenodo' metadata", {
  cl <- match.call()
  cl[["title"]] <- paste0("FAIR theory: ", cl[["title"]])
  cl[["upload_type"]] <- "model"
  cl[["keywords"]] = c("fairtheory", keywords)
  cl[[1L]] <- str2lang("theorytools::add_zenodo_json")
  eval.parent(cl)
  })
}


## Download 'Zenodo' Archive
##
## Downloads an archive from ['Zenodo'](https://zenodo.org).
## @inheritParams create_fair_theory
## @param doi DOI of the 'Zenodo' archive.
## @importFrom curl curl_fetch_memory curl_download
## @importFrom jsonlite fromJSON
## @importFrom tools md5sum
## @export
## @examples
## download_zenodo(doi = "10.5281/zenodo.14921521",
## path = file.path(tempdir(), "tripartite"))
# download_zenodo <- function(doi,
#                             path = ".") {
#
#   # check for existence of the folder
#   if(!dir.exists(path)){
#     with_cli_try("Creating theory repository at {.val {path}}", {
#       dir.create(path)
#     })
#   }
#   if(!grepl("10.5281/zenodo.", doi)){
#     stop("No valid DOI.")
#   }
#   with_cli_try("Accessing record on Zenodo", {
#     record <- jsonlite::fromJSON(rawToChar(curl::curl_fetch_memory(paste0("https://zenodo.org/api/records/", gsub("^.{0,}10.5281/zenodo\\.", "", doi)))$content))
#
#     # extract individual file names and urls
#
#     if(!grepl(".zip", url_zip, fixed = TRUE)){
#       stop()
#     }
#     url_zip <- record$files$links$self
#     filename <- basename(record$files$key)
#     file_temp <- file.path(tempdir(), filename)
#     zenodo_checksum <- record$files$checksum
#   })
#
#   with_cli_try("Download ZIP archive", {
#     tmp <- curl::curl_download(url_zip, file_temp)
#     if(!file.exists(tmp)) stop()
#     download_checksum <- unname(tools::md5sum(tmp))
#     grepl(download_checksum, zenodo_checksum, fixed = TRUE)
#   })
#
#   with_cli_try("Create local FAIR theory repository", {
#     dir_unzip <- file.path(tempdir(), "temp_unzip")
#     dir.create(dir_unzip)
#     on.exit(unlink(dir_unzip, recursive = TRUE))
#     utils::unzip(zipfile = file_temp, exdir = dir_unzip)
#     dir_parent <- list.dirs(dir_unzip, recursive = FALSE)[1]
#     files <- list.files(dir_parent, recursive = TRUE, full.names = TRUE)
#     files_rel <- path_rel(files, dn = dir_parent)
#     files_dest <- file.path(path, files_rel)
#     copy_create_dir(from = files, to = files_dest)
#   })
#
# }
