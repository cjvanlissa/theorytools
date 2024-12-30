test_that("create_fair_theory() creates github repo", {
  testthat::skip_if_offline()
  ownr <- try(gh::gh_whoami()$login)
  testthat::skip_if_not(condition = isTRUE(ownr == "cjvanlissa"), message = "Skipped test that requires GitHub")
  # Create a theory with no remote repository (for safe testing)
  theory_dir <- file.path(tempdir(), "theory_github")
  out <- create_fair_theory(path = theory_dir,
                     title = "This is My GitHub Theory",
                     theory_file = "theory.txt",
                     remote_repo = "delete_test",
                     add_license = "ccby")
  expect_true(out)
  remote_url <- gert::git_remote_list(repo = theory_dir)$url[1]
  expect_true(startsWith(remote_url, "https://"))
  out <- gert::git_remote_ls(remote_url)
  expect_true(nrow(out) > 0)
  gh::gh("DELETE /repos/{owner}/{repo}", owner = ownr, repo = "delete_test")
  out <- try(gert::git_remote_ls(remote_url), silent = TRUE)
  expect_true(any(grepl("404", out))) # Test to make sure the github repo is cleanly deleted
})


test_that("create_fair_theory() passes license arguments", {
  theory_dir <- file.path(tempdir(), "license")
  out <- create_fair_theory(path = theory_dir,
                            title = NULL,
                            theory_file = NULL,
                            remote_repo = NULL,
                            add_license = "proprietary",
                            copyright_holder = "bla")
  expect_true(out)
})
