#' @title Derive Formulae From Augmented DAG
#' @description Uses the `form` attribute of edges in an augmented DAG to
#' construct formulae for the relationship between `exposure` and `outcome`.
#' @param x An object of class `dagitty`.
#' @param exposure Atomic character, indicating the exposure node in `x`.
#' @param outcome Atomic character, indicating the outcome node in `x`.
#' @param data Optional, a `data.frame` to be used as environment for the
#' formulae. Default: `NULL`
#' @param ... Additional arguments, passed to
#' \code{\link[dagitty]{adjustmentSets}}
#' @return A `list` of objects with class `formula`.
#' @details The `form` attribute of an augmented DAG of class `dagitty` should
#' contain information about the functional form for the relationships specified
#' in the DAG. For this function, the `form` attribute must be an additive
#' function as also accepted by \code{\link[stats]{formula}}.
#' @examples
#' x <- dagitty('dag {
#' C
#' O
#' X
#' O <- X [form="X^2"]
#' C -> X
#' Y -> O
#' }')
#' derive_formula(x, outcome = "O", exposure = "X")
#' @seealso
#'  \code{\link[methods]{hasArg}}
#'  \code{\link[tidySEM]{get_edges}}
#'  \code{\link[dagitty]{adjustmentSets}}
#' @rdname derive_formula
#' @export
#' @importFrom methods hasArg
#' @importFrom tidySEM get_edges
#' @importFrom dagitty adjustmentSets
derive_formula <- function (x, exposure, outcome, data = NULL, ...){
  if(!(methods::hasArg(exposure) & methods::hasArg(outcome))){
    stop("Function derive_formula() requires a single explicit exposure and outcome argument.")
  }
  functional_form <- tidySEM::get_edges(x)

  adj_sets <- unclass(dagitty::adjustmentSets(x, exposure = exposure, outcome = outcome, ...)  )
  out <- lapply(adj_sets, function(cvars){
    all_x <- exposure
    if(length(cvars) > 0) all_x <- c(all_x, cvars)
    fforms <- functional_form[functional_form$from %in% all_x & functional_form$to == outcome & functional_form$e == "->", , drop = FALSE]
    if(nrow(fforms) > 0){
      x_form <- fforms$form
      x_form <- unlist(lapply(x_form, function(i)trimws(strsplit(i, split = "+", fixed = TRUE)[[1]])))
      all_x <- unique(c(all_x, x_form))
    }
    forml <- stats::as.formula(paste0(outcome, "~", paste(all_x, collapse = "+")), env = data)
    forml
  })
  return(out)
}



derive_sim_formula <- function(edg, outcome, beta_default = runif(1, min = -0.6, max = 0.6), ...){
  browser()
  beta_default <- substitute(beta_default)

  edg <- edg[edg$to == outcome, , drop = FALSE]
  # if(any(is.na(edg_thisn$form))){
  #   edg_thisn$form[is.na(edg_thisn$form)] <- sapply(edg_thisn$from[is.na(edg_thisn$form)], function(fromthis){ paste0(eval(beta_default), "*", fromthis)})
  # }
  out <- lapply(adj_sets, function(cvars){
    all_x <- exposure
    if(length(cvars) > 0) all_x <- c(all_x, cvars)
    fforms <- edg[edg$from %in% all_x & edg$to == outcome & edg$e == "->", , drop = FALSE]
    if(nrow(fforms) > 0){
      x_form <- fforms$form
      x_form <- unlist(lapply(x_form, function(i)trimws(strsplit(i, split = "+", fixed = TRUE)[[1]])))
      all_x <- unique(c(all_x, x_form))
    }
    forml <- stats::as.formula(paste0(outcome, "~", paste(all_x, collapse = "+")), env = data)
    forml
  })
  return(out)
}


merge_formulas <- function(edg, beta_default)
{
  if(any(is.na(edg$form))){
      edg$form[is.na(edg$form)] <- sapply(edg$from[is.na(edg$form)], function(fromthis){ paste0(eval(beta_default), "*", fromthis)})
  }
  rhs <- as.list(edg$form)
  rhs <- rhs[sapply(rhs, `!=`, "0")] # drop "0"
  rhs <- do.call(paste, c(rhs, sep = " + "))
  if(length(rhs) < 1) # use "0" if rhs is empty
    rhs <- "0"
  return(rhs)
}
