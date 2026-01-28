#' @title Simulate Data from DAG
#' @description Simulates data from an (augmented) DAG, respecting the optional
#' metadata fields `form`, for functional form of relationships, and
#' `distribution`, for the distributions of exogenous nodes and
#' residuals.
#' @details Data is simulated sequentially, first from exogenous nodes and then
#' from their descendants. If `x` is an augmented DAG with metadata indicating
#' the functional `form` of relationships and `distribution` of exogenous nodes
#' and residuals, this information is used. If this information is absent, nodes
#' and residuals are assumed to be normally distributed, and edges are assumed
#' to be linear, with coefficients samples based on `beta_default`.
#'
#' The argument `duplicated` controls how multiplicative terms are merged across
#' edges pointing to the same outcome node. The default `duplicated = "unique"`
#' removes terms that are duplicated across edges (i.e.,
#' if two edges point to node `"O"`, and both edges specify `.5*E`, the resulting
#' function will say `.5*E`. However, if one edge specifies `.2*E` and the other
#' specifies `.3*E`, they are not duplicated and will be added.
#' Alternatively, `duplicated = "add"` just sums terms across all edges pointing
#' into the same outcome node.
#' @param x An object of class `dagitty`.
#' @param beta_default Function used to specify missing edge coefficients.
#' Default: `runif(1, min = -0.6, max = 0.6)`
#' @param n Atomic integer defining the sample size, default: `500`
#' @param run Logical, indicating whether or not to run the simulation. Default:
#' `TRUE`.
#' @param duplicated Atomic character, indicating how to resolve duplicate terms
#' from multiple edges pointing to the same node. Default: `"unique"`. See
#' Details.
#' @return If `run` is `TRUE`, this function returns a `data.frame` with
#' an additional attribute called `attr( , which = "script")` that contains the
#' script for simulating data. If `run` is `FALSE`, this function returns the
#' script as `character` vector.
#' @examples
#' x <- dagitty::dagitty('
#' dag {
#'   X [distribution="rbinom(size = 2, prob = .5)"]
#'   Z [distribution="rexp()"]
#'   Y [distribution="rnorm()"]
#'
#'   X -> Y [form="0.5+X"]
#'   Z -> Y [form="2*Z"]
#'   A -> X
#' }
#' ')
#' txt <- simulate_data(x, n = 5, run = FALSE)
#' df <- simulate_data(x, n = 5, run = TRUE)
#' df_from_txt <- eval(parse(text = txt))
#' @seealso
#'  \code{\link[tidySEM]{get_nodes}}, \code{\link[tidySEM]{get_edges}}
#'  \code{\link[dagitty]{exogenousVariables}}
#' @rdname simulate_data
#' @export
#' @importFrom tidySEM get_nodes get_edges
#' @importFrom dagitty exogenousVariables
#' @importFrom stats runif
simulate_data <- function (x,
                           beta_default = round(runif(1, min = -0.6, max = 0.6), 2),
                           n = 500,
                           run = TRUE,
                           duplicated = "unique"){
  beta_default <- substitute(beta_default)
  duplicated <- duplicated[1]
  if(!isTRUE(duplicated %in% c("unique", "add"))){
    stop("Argument `duplicated` must be one of 'unique' or 'add'.")
  }
  nod <- tidySEM::get_nodes(x)
  edg <- tidySEM::get_edges(x)
  nodes_exo <- dagitty::exogenousVariables(x)

  # Create empty script
  script <- c("# Set random seed",
              paste0("set.seed(", sample.int(.Machine$integer.max, size = 1), ")"),
              "# Set simulation parameters",
              paste0("n <- ", n),
              "# Simulate exogenous nodes")
  # Add exogenous nodes
  for(thisn in nodes_exo){
    simfn <- nod$distribution[which(nod$name == thisn)]
    simfn <- try(sim_fun_txt(simfn), silent = TRUE)
    if(inherits(simfn, "try-error")){
      cli_msg("!" = "No valid distribution for {.val {thisn}}, used `rnorm()` instead.")
      simfn <- "rnorm(n)"
    }
    script <- c(script, paste0(thisn, " <- ", simfn))
  }
  # For each endogenous node, simulate data
  nodes_endo <- setdiff(nod$name, nodes_exo)
  nodes_existing <- nodes_exo
  endo_deps_exist <- sapply(nodes_endo, function(thisn){
    all(edg$from[edg$to == thisn] %in% nodes_existing)
  })
  script <- c(script, "# Simulate endogenous nodes")
  countr <- 1L
  while((length(endo_deps_exist) > 0 & countr < 2*nrow(nod))){
    if(all(!endo_deps_exist)){
      stop(paste0("Could not synthesize data; the dependencies for ", paste0(names(endo_deps_exist[!endo_deps_exist]), collapse = ", "), " do not exist."))
    }
    thisn <- names(endo_deps_exist)[endo_deps_exist][1]
    edg_thisn <- edg[edg$to == thisn, , drop = FALSE]

    frm <- edges_to_simfun(edg_thisn, beta_default = beta_default, duplicated = duplicated)

    resid <- try(sim_fun_txt(nod$distribution[which(nod$name == thisn)]), silent = TRUE)
    if(inherits(resid, "try-error")){
      cli_msg("!" = "No valid distribution for {.val {thisn}}, used `rnorm()` instead.")
      simfn <- "rnorm(n = n)"
    }
    script <- c(script, paste0(thisn, " <- ", frm, " + ", resid))
    nodes_existing <- c(nodes_existing, thisn)
    endo_deps_exist <- sapply(setdiff(nod$name, nodes_existing), function(thisn){
      all(edg$from[edg$to == thisn] %in% nodes_existing)
    })
    countr <- countr + 1L
  }
  script <- c(script, "df <- data.frame(", paste0(nod$name, " = ", nod$name, c(rep(",", nrow(nod)-1L), "")), ")")
  if(run){
    eval(parse(text = script))
    attr(df, "script") <- script
    return(df)
  } else {
    return(script)
  }
}

#' @importFrom methods formalArgs
sim_fun_txt <- function(simfn){
  tryCatch({
    if(!inherits(simfn, "character")) simfn <- "rnorm()"
    simfn <- str2lang(s = simfn)
    if(is.null(simfn[["n"]])){
      Args <- formalArgs(eval(simfn[[1]]))
      if("n" %in% Args){
        simfn[["n"]] <- quote(n)
      }
    }
    return(deparse(substitute(simfn)))
  }, error = function(e){
    cli_msg("!" = "No valid distribution for data, used rnorm() instead.")
    return("rnorm(n = n)")
  })
}

# simulate_data <- function (x, beta_default = runif(1, min = -0.6, max = 0.6),
#                            n = 500){
#   beta_default <- substitute(beta_default)
#   nod <- tidySEM::get_nodes(x)
#   edg <- tidySEM::get_edges(x)
#   nodes_exo <- dagitty::exogenousVariables(x)
#
#   # Create empty environment
#   eval_env <- new.env()
#   # Add exogenous nodes
#   for(thisn in nodes_exo){
#     simfn <- nod$distribution[which(nod$name == thisn)]
#     assign(thisn, sim_fun(simfn, n = n), envir = eval_env)
#   }
#   # For each endogenous node, simulate data
#   nodes_endo <- setdiff(nod$name, nodes_exo)
#   endo_deps_exist <- sapply(nodes_endo, function(thisn){
#     all(edg$from[edg$to == thisn] %in% names(eval_env))
#   })
#
#   while(length(endo_deps_exist) > 0){
#     if(all(!endo_deps_exist)){
#       stop(paste0("Could not synthesize data; the dependencies for ", paste0(names(endo_deps_exist[!endo_deps_exist]), collapse = ", "), " do not exist."))
#     }
#     thisn <- sample(names(endo_deps_exist)[endo_deps_exist], 1)
#     edg_thisn <- edg[edg$to == thisn, , drop = FALSE]
#     frm <- merge_formulas(edg_thisn, beta_default = beta_default)
#
#     trueval <- eval(parse(text = frm), envir = eval_env)
#     resid <- eval(sim_fun(nod$distribution[which(nod$name == thisn)], n = n), envir = eval_env)
#     assign(thisn, trueval + resid, envir = eval_env)
#     endo_deps_exist <- sapply(setdiff(nodes_endo, names(eval_env)), function(thisn){
#       all(edg$from[edg$to == thisn] %in% names(eval_env))
#     })
#   }
#
#   as.data.frame(as.list(eval_env))
#
# }
#
# sim_fun <- function(simfn, n){
#   tryCatch({
#     if(is.na(simfn)) simfn <- "rnorm()"
#     simfn <- str2lang(s = simfn)
#     if(is.null(simfn[["n"]])){
#       Args <- formalArgs(eval(simfn[[1]]))
#       if("n" %in% Args){
#         simfn[["n"]] <- n
#       }
#     }
#     return(eval(simfn))
#   }, error = function(e){
#     cli_msg("!" = "No valid distribution for data, used rnorm() instead.")
#     return(rnorm(n))
#   })
# }

