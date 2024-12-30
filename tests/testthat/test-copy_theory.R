test_that("add_theory_file() creates new file", {

  theorytools::add_theory_file(path = tempdir())
  expect_true(file.exists(file.path(tempdir(), "theory.txt")))

  file.remove(file.path(tempdir(), "theory.txt"))
})

test_that("add_theory_file() copies file", {
  flpth <- file.path(tempdir(), "copyme.txt")
  file.create(flpth)
  dirnm <- file.path(tempdir(), "theory")
  dir.create(dirnm)

  on.exit(file.remove(flpth))
  on.exit(unlink(dirnm, recursive = TRUE))

  theorytools::add_theory_file(path = dirnm, theory_file = flpth)
  expect_true(file.exists(file.path(dirnm, "copyme.txt")))

})
