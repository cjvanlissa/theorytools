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
#' x <- dagitty::dagitty('dag {
#' C
#' O
#' X
#' Y
#' O <- X [form="I(X^2)"]
#' C -> X
#' Y -> O [form="Y*X"]
#' }')
#' f1 <- derive_formula(x, outcome = "O", exposure = "X")
#' f2 <- derive_formula(x, outcome = "O", exposure = "Y")
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
  edg <- tidySEM::get_edges(x)

  adj_sets <- unclass(dagitty::adjustmentSets(x, exposure = exposure, outcome = outcome, ...)  )
  out <- lapply(adj_sets, function(cvars){
    all_x <- exposure
    if(length(cvars) > 0) all_x <- c(all_x, cvars)
    fforms <- edg[edg$from %in% all_x & edg$to == outcome & edg$e == "->", , drop = FALSE]
    edges_to_analysisfun(fforms)
  })
  return(out)
}



formula_to_simfunction <- function(x, beta_default){
  trms <- terms(formula(paste0("~", x)))
  trms <- attr(trms, "term.labels")
  is_mult <- grepl(":", trms, fixed = TRUE)
  if(any(is_mult)){
    trms[is_mult] <- gsub(":", "*", trms[is_mult], fixed = TRUE)
  }
  trms <- sapply(trms, function(i){ paste0(eval(beta_default), "*", i) })
  simfunction <- paste0(trms, collapse = " + ")
  return(simfunction)
}

formula_to_simfunction <- function(x, beta_default){
  trms <- terms(formula(paste0("~", x)))
  trms <- attr(trms, "term.labels")
  is_mult <- grepl(":", trms, fixed = TRUE)
  if(any(is_mult)){
    trms[is_mult] <- gsub(":", "*", trms[is_mult], fixed = TRUE)
  }
  trms <- sapply(trms, function(i){ paste0(eval(beta_default), "*", i) })
  simfunction <- paste0(trms, collapse = " + ")
  return(simfunction)
}

merge_formulas <- function(...){
  rhs <- list(...)
  rhs <- rhs[sapply(rhs, `!=`, "0")] # drop "0"
  rhs <- do.call(paste, c(rhs, sep = " + "))
  # use "0" if rhs is empty
  if(length(rhs) < 1) rhs <- "0"
  # Remove redundant terms
  trms <- terms(formula(paste0("~", rhs)))
  rhs <- paste0(attr(trms, "term.labels"), collapse = "+")
  return(rhs)
}

expand_formula <- function(f){
  as.character(reformulate(labels(terms(as.formula(paste0("~", f)))))[2])
}

edges_to_formulas <- function(edg){
  frmls <- edg$form
  if(any(is.na(frmls))){
    frmls[is.na(frmls)] <- edg$from[is.na(edg$form)]
  }
  frmls <- unname(unlist(lapply(frmls, expand_formula)))
  return(frmls)
}

edges_to_simfun <- function(edg, beta_default){
  #frmls <- sapply(edg$form, theorytools:::form_to_formula)
  frmls <- edges_to_formulas(edg)
  frm <- do.call(merge_formulas, as.list(frmls))
  frm <- as.formula(paste0("~", frm))
  frm <- formula_to_simfunction(frm, beta_default = beta_default)
  return(frm)
}

edges_to_analysisfun <- function(edg){
  #edg$form <- sapply(edg$form, form_to_formula)
  frmls <- edges_to_formulas(edg)
  frm <- do.call(merge_formulas, as.list(frmls))
  return(as.formula(paste0("~", frm)))
}

formula_clean <- function(f){
  gsub("[ \\s\\t\\n]", "", f, perl = TRUE)
}

form_to_formula <- function(f){
  f <- formula_clean(f)
  parts <- strsplit(f, split = "+", fixed = TRUE)[[1]]

  is_const <- !grepl("(`[^`]+`|(?:[A-Za-z]|\\.(?!\\d))[A-Za-z0-9._]*)", parts, perl = TRUE)
  const <- paste0(parts[is_const], collapse = "+")
  intrcpt <- eval(parse(text = const))

  trms <- parts[!is_const]
  has_beta <- grepl("\\d\\*", trms)
  betas <- rep(NA, length(trms))
  if(any(has_beta)){

    find_betas <- regexpr("([+-]?(?:\\d+(?:\\.\\d+)?|\\.\\d+))(?=\\s*\\*\\s*[A-Za-z(])", trms, perl=TRUE)
    betas[which(attr(find_betas, "match.length") > 0)] <- regmatches(trms, find_betas)
    trms <- gsub(
      "([+-]?(?:\\d+(?:\\.\\d+)?|\\.\\d+))\\s*\\*\\s*",
      "",
      trms,
      perl = TRUE
    )
  }
  if(intrcpt == -1) trms <- c("-1", trms)
  frml <- paste0(trms, collapse = "+")
  attr(frml, "intercept") <- intrcpt
  attr(frml, "betas") <- betas
  class(frml) <- c("functional_form", class(frml))
  return(frml)
}
