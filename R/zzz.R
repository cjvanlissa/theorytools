.onLoad <- function(libname, pkgname) {
  if(requireNamespace("reticulate", quietly = TRUE)){
    reticulate::py_require("transformers")
    reticulate::py_require("numpy")
    reticulate::py_require("torch")
  }
}
