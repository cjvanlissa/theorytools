# Does not work because cli does not see variables in calling environment:
with_cli_try <- function(msg, code){
  tryCatch({
      if(!is_quiet()) cli::cli_process_start(msg)
      eval.parent(code)
      cli::cli_process_done() },
      error = function(err) {
        cli::cli_process_failed()
      }
    )
}

cli_msg <- function(...){
  if(!is_quiet()) do.call(cli::cli_bullets, list(text = as.vector(list(...))), envir = parent.frame(n = 2))
}
