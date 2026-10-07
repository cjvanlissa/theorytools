test_that("create_fair_theory() creates github repo", {
  ownr <- try(gh::gh_whoami()$login)
  testthat::skip_if_not(condition = isTRUE(ownr == "cjvanlissa"), message = "Skipped test that requires GitHub")
  # Create a theory with no remote repository (for safe testing)
  the_path <- tempfile(pattern = "file", tmpdir = tempdir(), fileext = "")
  dir.create(the_path)
  on.exit(unlink(the_path, recursive = TRUE), add = TRUE)
  gert::git_init(path = the_path)
  remote_repo <- basename(the_path)
  # Connect remote repo -----------------------------------------------------
  worcs::git_remote_create(remote_repo)
  out <- try(gert::git_remote_ls(repo_url))
  expect_false(inherits(out, "try-error"))
  repo_properties <- worcs::git_remote_connect(the_path, remote_repo)
  repo_url <- repo_properties$repo_url
  expect_true(startsWith(repo_url, "https://"))
  print(repo_url)
  repo_exists <- repo_properties$repo_exists
  print(repo_exists)
  expect_true(repo_exists)
  prior_commits <- repo_properties$prior_commits
  # Push local repo to remote -----------------------------------------------

  writeLines("some text", file.path(the_path, "readme.md"))
  gert::git_add(files = ".", repo = the_path)
  gert::git_commit(message = "Initial commit", repo = the_path)
  gert::git_push(repo = the_path)

  out <- try(gert::git_remote_ls(repo_url))
  expect_true(nrow(out) > 0)
  worcs:::git_remote_delete(remote_repo)
  out <- try(gert::git_remote_ls(repo_url), silent = TRUE)
  expect_true(any(grepl("404", out))) # Test to make sure the github repo is cleanly deleted

})


test_that("create_fair_theory() works", {

  the_path <- fs::file_temp(pattern = "license")
  scoped_temporary_project(dir = the_path)

  theoryfile <- file.path(the_path, "testtheory.txt")
  writeLines("bla", theoryfile)
  out <- create_fair_theory(path = the_path,
                            title = "My Theory",
                            theory_file = theoryfile,
                            remote_repo = NULL,
                            add_license = "ccby")
  expect_true(out)
})

test_that("create_fair_theory() passes license arguments", {
  the_path <- fs::file_temp(pattern = "license_arguments")
  scoped_temporary_project(dir = the_path)

  out <- create_fair_theory(path = the_path,
                            title = NULL,
                            theory_file = NULL,
                            remote_repo = NULL,
                            add_license = "proprietary",
                            copyright_holder = "bla")
  expect_true(out)

})
