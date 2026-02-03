#' @title Cosine Similarity
#' @description Compute cosine similarity between rows of matrix.
#' @param x Numeric matrix, where rows are cases and columns are
#' features.
#' @return `matrix`
#' @examples
#' set.seed(1)
#' similarity_cosine(matrix(runif(30), nrow = 3))
#' @rdname similarity_cosine
#' @export
similarity_cosine <- function(x){
  ss_x <- rowSums(x^2)
  x%*%t(x)/(sqrt(ss_x %*% t(ss_x)))
}

#' @title String Similarity
#' @description Wraps \link[stringdist]{stringdistmatrix} to return a string
#' similarity matrix (e.g., for use with \link[theorytools]{code}).
#' @param x Character vector.
#' @param ... Arguments passed to \link[stringdist]{stringdistmatrix}.
#' @return `matrix`
#' @examples
#' similarity_stringdist(c("cat", "a cat", "dog"))
#' @rdname similarity_stringdist
#' @importFrom stringdist stringdistmatrix
#' @export
similarity_stringdist <- function(x, ...){
  out <- stringdist::stringdistmatrix(a = x, ...)
  out <- as.matrix(out)
  out <- out/max(out)
  out <- 1-out
  rownames(out) <- colnames(out) <- x
  return(out)
}
