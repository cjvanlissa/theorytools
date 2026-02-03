# most_similar <- function(x, num){
#   UseMethod("most_similar", x)
# }
#
# # @export
# # @method most_similar character
# most_similar.character <- function(x, num = length(x)){
#   emb <- get_vector_embeddings(x)
#   out <- emb[,1]
#   names(out) <- x
#   out <- head(sort(out, decreasing = TRUE), (num+1L))[-1]
#   class(out) <- c("similarity_vector", class(out))
#   out
# }


most_similar <- function(x, to = NULL, num = nrow(x)){
  UseMethod("most_similar", x)
}

#' @export
#' @method most_similar matrix
most_similar.matrix <- function(x, to = NULL, num = nrow(x)){
  if(is.null(to)){
    to <- rownames(x)[1]
  }
  emb <- x
  out <- emb[, to]
  names(out) <- paste0(1:nrow(emb), ". ", rownames(emb))
  out <- sort(out, decreasing = TRUE)[1L:(num+1L)]
  class(out) <- c("similarity_vector", class(out))
  out
}

#' @export
#' @method most_similar code_list
most_similar.code_list <- function(x, to = NULL, num = nrow(x)){
  most_similar(x[["....similarity...."]], to = to, num = num)
}

#' @export
#' @method print similarity_vector
print.similarity_vector <- function(x, ...){
  nams <- names(x)
  for(i in 1:length(x)){
    cat(sub("\\..*", "", nams[i]), ". ", formatC(x[i], digits = 3, format = "f"), " ", sub(".+?\\. ", "", nams[i]), "\n", sep = "")
  }
}
