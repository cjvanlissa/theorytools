#' @importFrom webexercises torf mcq fitb
#' @importFrom knitr is_html_output
quizz <- function(..., render_if = knitr::is_html_output(), title = "Quiz", show_box = TRUE, show_check = TRUE){
  if(render_if){
    if(requireNamespace("webexercises", quietly = TRUE)){
      if(show_box | show_check){
        classes <- paste0(' class = "',
                          trimws(paste0(c(c("", "webex-check")[show_check+1L],
                                               c("", "webex-box")[show_box+1L]), collapse = " ")), '"')
      }
      intro <- paste0('<div class="webex-check webex-box">\n<span>\n<p style="margin-top:1em; text-align:center">\n<b>', title, '</b></p>\n<p style="margin-left:1em;">\n')
      outro <- '\n</p>\n</span>\n</div>'
      dots <- list(...)
      questions <- sapply(dots, function(q){
        switch(class(q)[1],
               "character" = {
                 opts <- q
                 names(opts)[1] <- "answer"
                 webexercises::mcq(sample(opts))
               },
               "logical" = {
                 webexercises::torf(q)
               },
               "numeric" = {

                 if(length(q) == 1){
                   webexercises::fitb(answer = q)
                 } else {
                   webexercises::fitb(answer = q[1], tol = q[2])
                 }

               },
               "integer" = {
                 webexercises::fitb(answer = q[1], tol = 0)
               })})

      txt <- paste0(
        intro,
        paste(paste(names(dots), questions), collapse = "\n\n"),
        outro
      )
    } else {
      txt = ""
    }
    cat(txt)
  }
}
