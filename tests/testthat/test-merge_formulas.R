test_that("formulas merged correctly", {
  expect_equal(merge_formulas("a:b+c:d+e:f", "a:b", "c:d", "e*f"), merge_formulas("a:b+c:d+e:f", "a:b", "c:d", "e+f+e:f"))
  expect_equal(merge_formulas("a*b", "a:b"), merge_formulas("a*b", "a"))
  expect_equal(merge_formulas("a+b+a:b", "a:b"), merge_formulas("a*b", "a"))
})

