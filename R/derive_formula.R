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
#' function as also accepted by \code{\link[stats]{formula}}. The `form`
#' attribute may contain a leading intercept and constant slopes, which will be
#' parsed out. If the `form` attribute does not meet these requirements, the
#' resulting `formula` may be invalid. For example:
#'
#' * `form=".5+x1"` would return `~x1`.
#' * `form="2*x1*x2"` would return `~x1+x2+x1:x2`.
#' * `form="-.2-.2*I(x3^2)"` would return `~I(x3^2)`.
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

edges_to_analysisfun <- function(edg){
  out <- try({
    if(any(is.na(edg$form))){
      edg$form[is.na(edg$form)] <- edg$from[is.na(edg$form)]
    }
    frmls <- sapply(edg$form, remove_intercept_beta)
    frmls <- unname(unlist(lapply(frmls, expand_formula)))
    frm <- do.call(merge_formulas, as.list(frmls))
    as.formula(paste0("~", frm))
  })
  if(inherits(out, "try-error")){
    cli_msg("!" = "Could not convert the form attribute to a valid formula; used linear effects of incoming nodes instead.")
    out <- as.formula(paste0("~", paste0(edg$from, collapse = "+")))
  }
  return(out)
}

#' @importFrom utils getFromNamespace
bind_list <- getFromNamespace("bind_list", "tidySEM")

merge_functional_form <- function(x, duplicates = "unique"){
  #x <- c(".5+.3*x", "-1+.3*x+5*y")
  f <- formula_clean(x)
  if(duplicates == "add"){
    return(Deriv::Simplify(paste0(x, collapse = "+")))
  }
  parts <- lapply(f, function(thisf){ gsub("^\\+", "", strsplit(thisf, split = "(?<!^|[\\s+-])(?=[+-])", perl = TRUE)[[1]]) })
  is_const <- lapply(parts, function(thisp){ !grepl("(`[^`]+`|(?:[A-Za-z]|\\.(?!\\d))[A-Za-z0-9._]*)", thisp, perl = TRUE) })
  const <- paste0(unlist(parts)[unlist(is_const)], collapse = "+")
  intrcpt <- eval(parse(text = const))
  trms <- mapply(FUN = function(x, y){x[!y]}, x = parts, y = is_const)
  trms <- lapply(trms, function(thist){
    has_beta <- grepl("^[+-]?([0-9]*[.])?[0-9]+\\*", thist)
    betas <- rep(1, length(thist))
    names(betas) <- thist
    if(any(has_beta)){
      find_betas <- regexpr("([+-]?(?:\\d+(?:\\.\\d+)?|\\.\\d+))(?=\\s*\\*\\s*[A-Za-z(])", thist[has_beta], perl=TRUE)
      betas[which(attr(find_betas, "match.length") > 0)] <- regmatches(thist[has_beta], find_betas)
      names(betas)[has_beta] <- gsub(
        "([+-]?(?:\\d+(?:\\.\\d+)?|\\.\\d+))\\s*\\*\\s*",
        "",
        thist[has_beta],
        perl = TRUE
      )
    }
    out <- sapply(unique(names(betas)), function(thisb){
      eval(parse(text = paste0(betas[names(betas) == thisb], collapse = "+")))
    })
    names(out) <- unique(names(betas))
    out
  })

  trms_nodups <- unlist(lapply(unique(names(unlist(trms))), function(thist){
    out <- na.omit(unlist(lapply(trms, `[`, thist)))
    if(length(unique(out)) > 1){
      out[1] <- sum(out)
    }
    out[1]
  }))

  frml <- paste0(trms_nodups, "*", names(trms_nodups), collapse = "+")
  if(inherits(intrcpt, c("numeric", "integer"))){
    frml <- paste0(intrcpt, "+", frml)
  }
  frml <- Deriv::Simplify(frml)
  return(frml)
}

form_to_chunks <- function(f){
  f <- formula_clean(f)
  parts <- strsplit(f, split = "(?<!^|[\\s+-])(?=[+-])", perl = TRUE)[[1]]
  parts <- gsub("^\\+", "", parts)
  is_const <- !grepl("(`[^`]+`|(?:[A-Za-z]|\\.(?!\\d))[A-Za-z0-9._]*)", parts, perl = TRUE)
  const <- paste0(parts[is_const], collapse = "+")
  intrcpt <- eval(parse(text = const))
  trms <- parts[!is_const]
  has_beta <- grepl("^[+-]?([0-9]*[.])?[0-9]+\\*", trms)
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
  names(betas) <- trms
  out <- list(
    intercept = intrcpt,
    betas = betas
  )
  class(out) <- c("functional_form_chunks", class(out))
  return(out)
}

chunks_to_form <- function(chunks){
  out <- names(chunks$betas)
  if(any(!is.na(chunks$betas))){
    out[!is.na(chunks$betas)] <- paste0(chunks$betas[!is.na(chunks$betas)], "*", names(chunks$betas[!is.na(chunks$betas)]))
  }
  out <- paste0(out, collapse = "+")
  if(!is.null(chunks$intercept)){
    out <- paste0(chunks$intercept, "+", out)
  }
  return(out)
}

#' @importFrom Deriv Simplify
edges_to_simfun <- function(edg, beta_default, duplicated = "unique"){
  if(is.null(edg[["form"]])){
    edg$form <- NA
  }
  if(any(is.na(edg$form))){
    edg$form[which(is.na(edg$form))] <- edg$from[which(is.na(edg$form))]
  }
  frmls <- lapply(edg$form, form_to_chunks)
  frmls[["duplicated"]] <- duplicated
  frmls <- do.call(merge_chunks, frmls)
  frmls <- chunks_add_default_beta(frmls, beta_default = beta_default)
  out <- chunks_to_form(frmls)
  out <- gsub(":", "*", out, fixed = TRUE)
  Deriv::Simplify(out)
}

# merge_formulas <- function(...){
#   rhs <- list(...)
#   rhs <- paste0(rhs, collapse = "+")
#   return(Deriv::Simplify(rhs))
# }

#' @importFrom stats formula terms reformulate
merge_formulas <- function(...){
  rhs <- list(...)
  rhs <- rhs[sapply(rhs, `!=`, "0")] # drop "0"
  rhs <- do.call(paste, c(rhs, sep = " + "))
  # use "0" if rhs is empty
  if(length(rhs) < 1) rhs <- "0"
  # Remove redundant terms
  trms <- terms(formula(paste0("~", rhs)))
  frml <- reformulate(labels(trms), intercept = as.logical(attr(trms, "intercept")))
  return(as.character(frml[2]))
}

expand_formula <- function(f){
  as.character(reformulate(labels(terms(as.formula(paste0("~", f)))))[2])
}

formula_clean <- function(f){
  gsub("[ \\s\\t\\n]", "", f, perl = TRUE)
}

remove_intercept_beta <- function(f){
  f <- formula_clean(f)
  parts <- strsplit(f, split = "(?<!^|[\\s+-])(?=[+-])", perl = TRUE)[[1]]
  parts <- gsub("^\\+", "", parts)
  is_const <- !grepl("(`[^`]+`|(?:[A-Za-z]|\\.(?!\\d))[A-Za-z0-9._]*)", parts, perl = TRUE)
  if(any(is_const)){
    const <- paste0(parts[is_const], collapse = "+")
    intrcpt <- eval(parse(text = const))
    parts <- parts[!is_const]
  } else {
    intrcpt = 0
  }
  has_beta <- grepl("^[+-]?([0-9]*[.])?[0-9]+\\*", parts)
  if(any(has_beta)){
    parts[has_beta] <- gsub(
      "([+-]?(?:\\d+(?:\\.\\d+)?|\\.\\d+))\\*",
      "",
      parts[has_beta],
      perl = TRUE
    )
  }
  if(isTRUE(intrcpt == -1)) parts <- c("-1", parts)
  frml <- paste0(parts, collapse = "+")
  return(frml)
}

add_default_beta <- function(f, beta_default){
  f <- formula_clean(f)
  parts <- strsplit(f, split = "(?<!^|[\\s+-])(?=[+-])", perl = TRUE)[[1]]
  parts <- gsub("^\\+", "", parts)
  is_const <- !grepl("(`[^`]+`|(?:[A-Za-z]|\\.(?!\\d))[A-Za-z0-9._]*)", parts, perl = TRUE)
  const <- paste0(parts[is_const], collapse = "+")
  intrcpt <- eval(parse(text = const))
  trms <- parts[!is_const]
  has_beta <- grepl("^[+-]?([0-9]*[.])?[0-9]+\\*", trms)
  if(any(!has_beta)){
    trms[!has_beta] <- paste0(replicate(sum(!has_beta), {eval(beta_default)}), "*", trms[!has_beta])
  }
  frml <- paste0(trms, collapse = "+")
  if(inherits(intrcpt, c("numeric", "integer"))){
    frml <- paste0(intrcpt, "+", frml)
  }
  return(frml)
}

chunks_add_default_beta <- function(chunks, beta_default){
  if(any(is.na(chunks$betas))){
    chunks$betas[is.na(chunks$betas)] <- replicate(sum(is.na(chunks$betas)), {eval(beta_default)})
  }
  return(chunks)
}

#' @importFrom stats na.omit
merge_chunks <- function(..., duplicated = "unique"){
  dots <- list(...)
  if(duplicated == "add"){
    out <- sapply(dots, chunks_to_form)
    out <- Deriv::Simplify(paste0(out, collapse = "+"))
    return(form_to_chunks(out))

  }
  intrcpt <- tryCatch({sum(unlist(lapply(dots, `[[`, "intercept")))}, error = function(e){0})
  all_betas <- lapply(dots, `[[`, "betas")
  betas_nodups <- unlist(lapply(unique(names(unlist(all_betas))), function(thist){
      out <- na.omit(unlist(lapply(all_betas, `[`, thist)))
      if(length(out) == 0){
        out <- NA
        names(out) <- thist
        return(out)
      }
      if(length(unique(out)) > 1){
        out[1] <- sum(out)
      }
      out[1]
    }))
  out <- list(
    intercept = intrcpt,
    betas = betas_nodups
  )
  if(intrcpt == 0) out["intercept"] <- list(NULL)
  return(out)
}

expand_formula <- function(f){
  f <- as.formula(paste0("~", f))
  trms <- terms(f)
  f_out <- reformulate(labels(trms), intercept = as.logical(attr(trms, "intercept")))
  as.character(f_out[2])
}

char_to_form <- function(f){
  as.formula(paste0("~", f), env = NULL)
}
