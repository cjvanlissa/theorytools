test_that("similarity works", {
  skip_if_not(requireNamespace("reticulate", quietly = TRUE))

  skip_on_cran()
  #skip_on_ci()

  skip_if_not(theorytools:::check_python(c("transformers", "numpy", "torch")))
  if(dir.exists("../../dev/minilm")){
    res <- get_embeddings(c("a", "b"), "../../dev/minilm")
  } else {
    theorytools:::scoped_tempdir({
      theorytools::download_huggingface("sentence-transformers/all-MiniLM-L6-v2", "minilm")
      res <- get_embeddings(c("a", "b"), "minilm")
    })
  }
  expect_true(is.matrix(res))
  expect_equal(dim(res), c(2,384), ignore_attr = TRUE)
})
