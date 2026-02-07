#' @title Get Vector Embeddings (uses Python)
#' @description This function wraps the 'transformers' library in 'Python',
#' to obtain vector embeddings (a numerical representation of meaning) for
#' a character vector based on a pretrained model.
#' @param x Character vector of text to be embedded.
#' @param model_path Atomic character vector referring to a folder with a
#' pretrained model. Default: NULL
#' @return Matrix
#' @examples
#' \dontrun{
#' if(requireNamespace("reticulate", quietly = TRUE)){
#'  tmp <- get_embeddings(c("cat", "my cat", "dog"),
#'  model_path = "scibert_scivocab_uncased")
#'  }
#' }
#' @rdname get_embeddings
#' @export
get_embeddings <- function(x, model_path = NULL) {
  if(!check_python(pkgs = c("transformers", "numpy", "torch"))){
    return(invisible())
  }
  if (!is.character(x)) stop("'x' must be a character vector")
  if (is.null(model_path)) stop("'model_path' must refer to a directory containing a model")
  reticulate::source_python(system.file("python", "embedding.py", package = "theorytools"), convert = TRUE)
  sim_py <- reticulate::py$get_embeddings(x, model_path)
  rownames(sim_py) <- x
  return(sim_py)
}

#' @title Download 'Hugging Face' Model
#' @description Download a model from 'Hugging Face' to a local folder, to be
#' used in e.g. \link[theorytools]{get_embeddings}.
#' @param model Atomic character, referencing a model - typically of the form
#' `"user/model"`.
#' @param path Atomic character, referencing a local folder where the model is
#' installed.
#' @param ... Arguments passed to and from functions.
#' @return On success: Atomic character, with the path to the local model.
#' On failure: `NULL`.
#' @rdname download_huggingface
#' @export
download_huggingface <- function(model, path, ...){
  if(!check_python(pkgs = c("transformers"))){
    return(invisible())
  }
  reticulate::source_python(system.file("python", "download_model.py", package = "theorytools"), convert = TRUE)
  reticulate::py$download_model(model, path)
}

check_python <- function(pkgs){
  if (!requireNamespace("reticulate", quietly = TRUE)) {
    cli_msg("!" = "Package 'reticulate' is required. Install it using {.run install.packages('reticulate')}.")
    return(FALSE)
  }
  has_pkgs <- sapply(pkgs, function(p){
    isTRUE(reticulate::py_module_available(p))
  })
  if(any(!has_pkgs)){
    cli_msg("!" = "Python package(s) {.val {pkgs[!has_pkgs]}} are not available.")
    return(FALSE)
  }
  return(TRUE)
}
