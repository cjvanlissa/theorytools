#' @title Create a Quiz
#' @description Convenience function for creating a basic quiz in HTML format
#' from the arguments captured by `...`, where the type of each question
#' is determined automatically from the class of the arguments.
#' @param ... Each argument should be a named vector, see Details.
#' @param render_if Logical, whether or not to render the output. By default,
#' this argument uses `knitr::is_html_output()`.
#' @param title Atomic character, default: 'Quiz'
#' @param show_box Logical, whether or not to draw a box around the quiz.
#' Default: `TRUE`
#' @param show_check Logical, whether or not to show a button to check answers.
#' Default: `TRUE`
#' @return `NULL`, this function is called for its side effect of printing HTML
#' code using `cat()`.
#' @details The function renders questions captured by the arguments in `...`.
#' The name of each argument is the text of the question. The value of each
#' argument determined the question type and its correct answer. The following
#' types of questions are supported:
#'
#' \describe{
#'  \item{"`torf()`"}{The argument should be a single value of type `logical`,
#'  e.g.: `"The answer to this question is true." = TRUE`}
#'  \item{"`mcq()`"}{The argument should be a vector of type `character`. The
#'  first element is taken as the correct answer; the order of answers is
#'  randomized. E.g.: `"This multiple choice question has three answers." =
#'  c("Correct", "Incorrect", "Not sure")`}
#'  \item{"`fitb()`"}{The argument should be of type `numeric`. If the vector is
#'  atomic, the first element is taken as the correct answer, e.g.:
#'  `"Provide an exact floating point answer of 0.81" = 0.81`. If the vector has
#'  two elements, the second element is taken as the tolerance `tol`,
#'  e.g.: `"Here, 0.8 will be correct." = c(0.81, 0.01)`. If the
#'  vector is of type `integer`, the tolerance is set to zero, e.g.:
#'  `"The answer is 4." = 4L`}
#' }
#'
#' Alternatively, `...` may contain a single atomic character referring to a
#' text file that contains the questions, see examples.
#' @examples
#' # Quiz from arguments:
#' invisible(capture.output(theorytools:::quizz(
#' "The answer to this question is true." = TRUE,
#' "This multiple choice question has three answers." =
#'  c(answer = "Correct", "Incorrect", "Not sure"),
#' "Provide an exact floating point answer of 0.81" = 0.81,
#' render_if = TRUE
#' )))
#' # From a file:
#' quizz_file <- tempfile()
#' writeLines(
#' c("The answer is true. = TRUE",
#' "The answer is correct = c(answer = \"Correct\", \"Incorrect\", \"Not sure\")",
#' "The answer is exactly .81 = 0.81",
#' "But here, .8 is also fine = c(0.81, .01)",
#' "Write the word 'true' = c('true', 'TRUE')",
#' "Here, answer exactly 4. = 4L")
#' , quizz_file)
#' invisible(capture.output(theorytools:::quizz(quizz_file, render_if = TRUE)))
#' @seealso
#'  \code{\link[knitr]{is_latex_output}}
#'  \code{\link[webexercises]{mcq}}, \code{\link[webexercises]{torf}}, \code{\link[webexercises]{fitb}}
#' @rdname quizz
# @export
#' @importFrom knitr is_html_output
quizz <- function(..., render_if = knitr::is_html_output(), title = "Quiz", show_box = TRUE, show_check = TRUE){
  if(render_if){
    if(knitr::is_html_output()){
      if(requireNamespace("webexercises", quietly = TRUE)){
        dots <- list(...)
        # Check if a file is provided instead of multiple questions
        if(length(dots) == 1){
          if(file.exists(dots[[1]])){
            txt <- readLines(dots[[1]])
            questionz <- lapply(txt, function(q){
              spl <- regexpr("=", q)
              trimws(substring(q, c(1, spl+1), c(spl-1, nchar(q))))
            })
            dots <- lapply(questionz, function(q){
              eval(parse(text = q[2]))
            })
            names(dots) <- trimws(sapply(questionz, `[`, 1))
          }
        }
        # Now, prepare the HTML code
        if(show_box | show_check){
          classes <- paste0(' class = "',
                            trimws(paste0(c(c("", "webex-check")[show_check+1L],
                                            c("", "webex-box")[show_box+1L]), collapse = " ")), '"')
        }
        intro <- paste0('<div class="webex-check webex-box">\n<span>\n<p style="margin-top:1em; text-align:center">\n<b>', title, '</b></p>\n<p style="margin-left:1em;">\n')
        outro <- '\n</p>\n</span>\n</div>'

        questions <- sapply(dots, function(q){
          switch(class(q)[1],
                 "character" = {
                   opts <- q
                   if(any(names(opts) == "answer")){
                     webexercises::mcq(sample(opts))
                   } else {
                     webexercises::fitb(answer = opts, num = FALSE)
                   }
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

}
