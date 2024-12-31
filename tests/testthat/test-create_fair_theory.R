test_that("create_fair_theory() creates github repo", {
  testthat::skip()
  ownr <- try(gh::gh_whoami()$login)
  testthat::skip_if_not(condition = isTRUE(ownr == "cjvanlissa"), message = "Skipped test that requires GitHub")
  # Create a theory with no remote repository (for safe testing)
  path <- file.path(tempdir(), "theory_github")
  dir.create(path)
    # 2. Initialize Git repo
  theorytools:::with_cli_try("Initialize Git repository", {
    gert::git_init(path = path)
  })
  remote_repo <- "test_delete"
  # Connect remote repo -----------------------------------------------------
  repo_properties <- worcs:::git_connect_or_create(path, remote_repo)
  repo_url <- repo_properties$repo_url
  repo_exists <- repo_properties$repo_exists
  prior_commits <- repo_properties$prior_commits
  # Push local repo to remote -----------------------------------------------

  if(repo_exists & isFALSE(prior_commits)){
    worcs::git_update(message = "Initial commit", repo = path, files = ".")
  }

  expect_true(repo_exists)
  expect_true(startsWith(remote_url, "https://"))
  out <- gert::git_remote_ls(remote_url)
  expect_true(nrow(out) > 0)
  gh::gh("DELETE /repos/{owner}/{repo}", owner = ownr, repo = remote_repo)
  out <- try(gert::git_remote_ls(remote_url), silent = TRUE)
  expect_true(any(grepl("404", out))) # Test to make sure the github repo is cleanly deleted
})


test_that("create_fair_theory() works", {
  theory_dir <- file.path(tempdir(), "license")
  theoryfile <- file.path(tempdir(), "testtheory.txt")
  writeLines("bla", theoryfile)
  out <- create_fair_theory(path = theory_dir,
                            title = "My Theory",
                            theory_file = theoryfile,
                            remote_repo = NULL,
                            add_license = "ccby")
  expect_true(out)
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
