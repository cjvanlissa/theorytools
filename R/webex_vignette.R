webex_vignette <- function (...){
  Args <- list(
    css = system.file("rmarkdown", "templates", "html_vignette",
                      "resources", "vignette.css", package = "rmarkdown")
  )
  if(requireNamespace("webexercises", quietly = TRUE)){
    Args$css <- c(Args$css, system.file("reports/default/webex.css", package = "webexercises"))
    Args$includes <- rmarkdown::includes(after_body = system.file("reports/default/webex.js", package = "webexercises"))
    Args$md_extensions <- "-smart"
  }
  do.call(rmarkdown::html_vignette, Args)
}
