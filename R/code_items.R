#' @title Code Text Data
#' @description Create a reproducible script for coding qualitative text data by
#' sequentially assigning elements of `x` to specific labels.
#' @param x An object for which a method exists.
#' @param ... Additional arguments passed to functions.
#' @return A `list` with class `code_list`.
#' @examples
#' x <- c("autonomy [satisfaction] increases",
#' "competence [satisfaction] increases", "relatedness [satisfaction] increases"
#' , "motivation is more internalized", "motivation is more internalized",
#' "motivation is more internalized1", "event is more controlling",
#' "event is more controlling",
#' "event communicates more effectance information")
#' coded <- code(x)
#' coded <- code(coded, "need_satisfaction", 1:3)
#' coded <- code(coded, "internalization", 1:3)
#' coded <- code(coded, "functional_significance", 1:3)
#' coded <- add_level(coded)
#' coded <- code(coded, "random_level1", 1:2)
#' coded <- code(coded, "random_level2", 1)
#' coded
#' @rdname code
#' @export
code <- function(x, ...){
  UseMethod("code", x)
}

#' @method code character
#' @param similarity Which method to use to compute similarity between entries.
#' Defaults to `"stringdist"`, which uses \link[stringdist]{stringdistmatrix}.
#' Option `"embeddings"` additionally requires passing the named argument
#' `"model_path"`, which should point to a LLM downloaded with
#' \link[theorytools]{download_huggingface}.
#' @rdname code
#' @export
code.character <- function(x, similarity = c("stringdist", "embeddings"), ...){
  similarity <- similarity[1]
  if(any(duplicated(x))){
    cli_msg("!" = "Some elements of {.code x} were duplicated. Consider running {.help [{.fun merge_duplicated}](theorytools::merge_duplicated)} on the resulting `code_list`.")
  }
  if(similarity == "embeddings"){
    dots <- list(...)
    if(!"model_path" %in% names(dots)){
      cli_msg("!" = "Argument {.code similarity = 'stringdist'} requires you to pass an argument {.code model_path}, see {.help [{.fun get_embeddings}](theorytools::get_embeddings)}}. Defaulting to {.code similarity = 'stringdist'}.")
      similarity <- "stringdist"
    } else {
      emb <- get_embeddings(x = x, model_path = dots[["model_path"]])
      sim_mat <- similarity_cosine(emb)
    }
  }
  if(similarity == "stringdist"){
    sim_mat <- similarity_stringdist(x)
  }
  names(x) <- seq_along(x)
  out <- list(....input.... = x,
              ....similarity.... = sim_mat,
              ....unassigned.... = x)
  class(out) <- c("code_list", class(out))
  return(out)
}

#' @method code code_list
#' @param label Label to assign to elements identified via numeric indexing,
#' passed via `...`.
#' @rdname code
#' @export
code.code_list <- function(x, label = NULL, ...){
  elements <- unlist(list(...))
  if(is.null(elements)){
    return(x)
  }
  if(is.null(label)){
    label <- paste0("unnamed_", (sum(grepl("unnamed_", names(x)))+1L))
  }
  x[[label]] <- c(x[[label]], x[["....unassigned...."]][elements])
  x[["....unassigned...."]] <- x[["....unassigned...."]][-elements]
  return(x)
}

#' @describeIn code In case of nested coding, use `add_level()` to add a level of
#' coding to a `code_list` object.
#' @export
add_level <- function(x, similarity = NULL, ...){
  cl <- match.call()
  cl[["x"]] <- names(x)[!grepl("^\\.{4}.+?\\.{4}$", names(x))]
  cl[[1L]] <- quote(code)
  out <- eval(cl)
  out <- c(list(....code_list.... = x),
           out)
  class(out) <- c("code_list", class(out))
  return(out)
}


#' @method print code_list
#' @export
print.code_list <- function(x, to = NULL, num = NULL, ...){
  out <- x[["....similarity...."]]
  #unassigned_element <- x[[names(x)[!grepl("^\\.{4}.+?\\.{4}$", names(x))][1]]]

  switch(as.character(length(x[["....unassigned...."]])),
    "0" = cat("No more unassigned items."),
    "1" = cat("One unassigned item:", x[["....unassigned...."]], sep = "\n\n"),
    {
    out <- out[x[["....unassigned...."]], x[["....unassigned...."]]]
    if(is.null(num)) num <- nrow(out)
    print(most_similar(out, to = to, num = num, ...))
    })
}


#' @export
#' @method as.data.frame code_list
as.data.frame.code_list <- function(x, row.names = NULL, optional = FALSE, ...){
  if("....code_list...." %in% names(x)){
    out <- as.data.frame.code_list(x[["....code_list...."]])
    add_column <- as.data.frame.code_list(x[!grepl("^\\.{4}.+\\.{4}$", names(x))])
    out <- cbind(
      add_column[match(out[ , 1, drop = TRUE], add_column[, 2, drop = TRUE]), 1, drop = TRUE],
      out
    )
    colnames(out)[1] <- paste0("label", sum(grepl("label", colnames(out), fixed = TRUE)))
    rownames(out) <- NULL
    return(as.data.frame(out))
  }
  out <- x[!grepl("^\\.{4}.+\\.{4}$", names(x))]
  out <- cbind(label = unlist(lapply(names(out), function(n){rep(n, length(out[[n]]))})),
               input = do.call(c, out))
  rownames(out) <- NULL
  if(!is.null(x[["....input...."]])){
    out <- out[match(x[["....input...."]], out[, "input"]), ]
  }
  return(as.data.frame(out))
}

labels_to_df <- function(x){
  if("....code_list...." %in% names(x)){
    out <- labels_to_df(x[["....code_list...."]])
    add_column <- labels_to_df(x[!grepl("^\\.{4}.+\\.{4}$", names(x))])
    out <- cbind(
      add_column[match(out[ , 1, drop = TRUE], add_column[, 2, drop = TRUE]), 1, drop = TRUE],
      out
    )
    colnames(out)[1] <- paste0("label", sum(grepl("label", colnames(out), fixed = TRUE)))
    return(out)
  }
  out <- x[!grepl("^\\.{4}.+\\.{4}$", names(x))]
  out <- cbind(label = unlist(lapply(names(out), function(n){rep(n, length(out[[n]]))})),
               input = do.call(c, out))
  return(out)
}

