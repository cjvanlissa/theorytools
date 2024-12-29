add_zenodo_json <- function(repo= ".", title, upload_type, keywords){
  to_json <- list(title = title,
                  upload_type = upload_type,
                  keywords = as.list(keywords))
  jsonlite::write_json(to_json, file.path(repo, ".zenodo.json"), pretty = TRUE, auto_unbox = TRUE)
}

add_zenodo_json_theory <- function(repo= ".", title, keywords){
  cl <- match.call()
  cl[["title"]] <- paste0("FAIR theory: ", cl[["title"]])
  cl[["upload_type"]] <- "model"
  cl[["keywords"]] = c("fairtheory", cl[["keywords"]])
  cl[[1L]] <- str2lang("theorytools::add_zenodo_json")
  eval.parent(cl)
}
