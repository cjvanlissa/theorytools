#' @title Select Covariate Adjustment Sets from Data
#' @description Wraps \link[dagitty]{adjustmentSets} to construct a dataset with
#' covariates that (asymptotically) allow unbiased estimation of causal effects
#' from observational data.
#' @param x An input graph of class `dagitty`.
#' @param data A `data.frame` or object coercible by `as.data.frame()`.
#' @param exposure Atomic character, name of the exposure variable.
#' @param outcome Atomic character, name of the outcome variable.
#' @param which_set Atomic character, indicating which set of covariates to
#' select in case there are multiple. Valid choices are in
#' `c("first", "sample", "all")`, see Value.
#' @param ... Other arguments passed to \link[dagitty]{adjustmentSets}
#' @return If `which_set = "all"`, returns a list of `data.frames` to allow for
#' sensitivity analyses. Otherwise, returns a `data.frame`.
#' @examples
#' dag <- dagitty::dagitty('dag {x -> y}')
#' df <- data.frame(x = rnorm(10), y = rnorm(10))
#' df1 <- select_controls(dag, df, exposure = "x", outcome = "y")
#' class(df1) == "data.frame"
#' df2 <- select_controls(dag, df, exposure = "x", outcome = "y", which_set = "sample")
#' class(df2) == "data.frame"
#' lst1 <- select_controls(dag, df, exposure = "x", outcome = "y", which_set = "all")
#' class(lst1) == "list"
#' @seealso
#'  \code{\link[dagitty]{adjustmentSets}}
#' @rdname select_controls
#' @export
#' @importFrom dagitty adjustmentSets
#' @importFrom stats as.formula model.frame
select_controls <- function(x, data, exposure = NULL, outcome = NULL, which_set = c("first", "sample", "all"), ...){
  which_set <- which_set[1]
  control_sets <- dagitty::adjustmentSets(x, exposure = exposure, outcome = outcome) #, ...)
  if(length(control_sets) > 0){
    if(which_set == "first") control_sets <- control_sets[1]
    if(which_set == "sample") control_sets <- control_sets[sample.int(length(control_sets))]
    out <- lapply(control_sets, function(cvs){
      stats::model.frame(as.formula(
        paste0(exposure, "~", paste0(c(outcome, cvs), collapse = "+"))), data)
    })
  } else {
    out <- list(
      stats::model.frame(stats::as.formula(paste0(exposure, "~", outcome)), data)
    )
  }
  if(!which_set == "all"){
    out <- out[[1]]
  }
  return(out)
}

#' @title Filter Conditional Independencies
#' @description Removes all conditional independencies, obtained using
#' \link[dagitty]{impliedConditionalIndependencies}, based on the variables
#' available in `data`.
#' @param x An object of class `dagitty.cis`.
#' @param data A `data.frame`.
#' @return An object of class `dagitty.cis`, or `NULL` if no conditional
#' independencies remain.
#' @examples
#' dag <- dagitty::dagitty('dag {
#' x1 -> y
#' x2 -> y}')
#' df <- data.frame(x1 = rnorm(10), y = rnorm(10))
#' cis <- dagitty::impliedConditionalIndependencies(dag)
#' cis <- filter_conditional_independencies(cis, df)
#' is.null(cis)
#' @seealso
#'  \code{\link[dagitty]{impliedConditionalIndependencies}}
#' @rdname filter_conditional_independencies
#' @export
filter_conditional_independencies <- function(x, data){
  vars <- names(data)
  out <- lapply(seq_along(x), function(i){
    if(all(unlist(x[[i]]) %in% vars)){
      x[[i]]
    }
  })
  out <- out[!sapply(out, is.null)]
  class(out) <- class(x)
  if(isTRUE(length(out) > 0)){
    return(out)
  } else {
    return(NULL)
  }
}


#' @title Prune DAG Based on Adjustment Sets
#' @description Wraps \link[dagitty]{adjustmentSets} to construct a pruned DAG
#' which only includes covariates that (asymptotically) allow unbiased
#' estimation of the causal effects of interest.
#' @param x An input graph of class `dagitty`.
#' @param exposure Atomic character, name of the exposure variable.
#' @param outcome Atomic character, name of the outcome variable.
#' @param which_set Atomic character, indicating which set of covariates to
#' select in case there are multiple. Valid choices are in
#' `c("first", "sample", "all")`, see Value.
#' @param ... Other arguments passed to \link[dagitty]{adjustmentSets}
#' @return If `which_set = "all"`, returns a list of `data.frames` to allow for
#' sensitivity analyses. Otherwise, returns a `data.frame`.
#' @examples
#' dag <- dagitty::dagitty('dag {x -> y}')
#' prune_dag(dag, exposure = "x", outcome = "y")
#' @seealso
#'  \code{\link[dagitty]{adjustmentSets}}
#' @rdname prune_dag
#' @export
#' @importFrom dagitty adjustmentSets dagitty
prune_dag <- function(x, exposure = NULL, outcome = NULL, which_set = c("first", "sample", "all"), ...){
  which_set <- which_set[1]
  control_sets <- dagitty::adjustmentSets(x, exposure = exposure, outcome = outcome)
  parsed_dag <- strsplit(as.character(x), "\\n")[[1]]
  keep_these <- parsed_dag %in% c("dag {", "}")
  named_vars <- lapply(parsed_dag, function(i){
    i <- gsub("\\[.+?\\]", "", i)
    i <- strsplit(i, "(->|<->|<- U ->|--|@-@|@->|@--)")[[1]]
    trimws(i)
  })
  if(length(control_sets) == 0) control_sets <- "xxxxxyyyyytotallynonsensicalyyyyyyxxxx"
  if(which_set == "first") control_sets <- control_sets[1]
  if(which_set == "sample") control_sets <- control_sets[sample.int(length(control_sets))]
  out <- lapply(control_sets, function(cvs){
    keep_vars <- unlist(c(exposure, outcome, cvs))
    keep_element <- keep_these | sapply(named_vars, function(i){all(i %in% keep_vars)})
    dagitty::dagitty(paste0(parsed_dag[keep_element], collapse = "\n"))
  })
  if(!which_set == "all"){
    out <- out[[1]]
  }
  return(out)
}
