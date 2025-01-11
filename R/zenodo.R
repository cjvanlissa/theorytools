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
