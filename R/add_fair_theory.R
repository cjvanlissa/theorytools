add_fair_theory <- function(path = ".",
                            title = NULL,
                            theory_file = NULL,
                            remote_repo = NULL,
                            add_license = c(
                              "cc0",
                              "ccby",
                              "gpl",
                              "gpl3",
                              "agpl",
                              "agpl3",
                              "apache",
                              "apl2",
                              "lgpl",
                              "mit",
                              "proprietary",
                              "none"
                            )) {
  # Select first license
  if (is.null(add_license))
    add_license = "none"
  add_license <- tryCatch(
    add_license[1],
    error = function(e) {
      "none"
    }
  )

  # 1. Create project folder
  tryCatch({
    if(!is_quiet()) cli::cli_process_start("Create project folder")
    if (!dir.exists(path)) {
      dir.create(path)
    }
    cli::cli_process_done() },
    error = function(err) {
      cli::cli_process_failed()
    }
  )

  # 2. Initialize Git repo
  tryCatch({
    if(!is_quiet()) cli::cli_process_start("Initialize Git repository")
    gert::git_init(path = path)
    cli::cli_process_done() },
    error = function(err) {
      cli::cli_process_failed()
    }
  )

  # Connect to remote repo if possible
  if (is.null(remote_repo)) {
    cli_msg("i" = "Argument {.val remote_repo} is {.val NULL}; you are working with a local repository only.")
  } else {
    ownr <- gh::gh_whoami()$login
    repo_name <- paste0(ownr, "/", remote_repo)
    repo_url <- paste0("https://github.com/", repo_name)
    test_repo <- try(gert::git_remote_ls(remote = repo_url), silent = TRUE)
    repo_exists <- isFALSE(inherits(test_repo, "try-error"))
    if (repo_exists) {
      tryCatch({
        if (!is_quiet())
          cli::cli_process_start("Connecting to existing remote repository {.val {repo_url}}")
        if (nrow(test_repo) > 0) {
          cli_msg("i" = "Repository {.val {repo_url}} already exists and has previous commits. If this is intentional, please add it manually and resolve merge conflicts. You are now working with a local repository only.")
          stop()
        } else {
          Args_gert <- list(name = "origin",
                            url = repo_url,
                            repo = path)
          do.call(gert::git_remote_add, Args_gert)
        }
        cli::cli_process_done()
      }, error = function(err) {
        cli::cli_process_failed()
      })
    } else {
      tryCatch({
        if (!is_quiet())
          cli::cli_process_start("Creating new remote repository at {.val {repo_url}}")
        worcs::git_remote_create(remote_repo, private = FALSE)
        Args_gert <- list(name = "origin",
                          url = repo_url,
                          repo = path)
        do.call(gert::git_remote_add, Args_gert)
        cli::cli_process_done()
      }, error = function(err) {
        cli::cli_process_failed()
      })

    }
  }
  test_repo <- try(gert::git_remote_list(repo = path), silent = TRUE)
  repo_exists <- isFALSE(inherits(test_repo, "try-error"))


# Add theory file ---------------------------------------------------------
  has_theory_file <- !is.null(theory_file)
  if (has_theory_file) {
    existing_theory_file <- file.exists(theory_file)
    if (existing_theory_file) {
      tryCatch({
        if (!is_quiet())
          cli::cli_process_start("Copying theory file {.val {theory_file}}")
        out <- file.copy(normalizePath(theory_file), file.path(path, basename(theory_file)))
        if (!out)
          stop()
        cli::cli_process_done()
      }, error = function(err) {
        cli::cli_process_failed()
      })
    } else {
      tryCatch({
        if (!is_quiet())
          cli::cli_process_start("Creating new theory file {.val {theory_file}}")
        file.create(file.path(path, theory_file))
        cli::cli_process_done()
      }, error = function(err) {
        cli::cli_process_failed()
      })

    }
  }

  # 1. Add LICENSE file
  if (!add_license == "none") {
    worcs::add_license_file(repo = path, license = add_license)
  }

  # 1. Add readme.md
  tryCatch({
    if (!is_quiet())
      cli::cli_process_start("Creating README.md")
    lines_readme <- c(
      "# FAIR theory: Theory Title Goes Here",
      "",
      "# Description",
      "",
      "This is a FAIR theory, see Van Lissa et al., in preparation.",
      "",
      "# Interoperability",
      "",
      "Explain what the theory can be reused for, and how.",
      "",
      "# Contributing",
      "",
      "If you want to contribute to this project, please get involved. You can do so in three ways:",
      "",
      "1. **To discuss the current implementation and discuss potential changes**, file a ‘GitHub’ issue",
      "2. **To directly propose changes**, send a pull request containing the proposed changes",
      "3. **To create a derivative theory**, please fork the repository",
      "",
      "If you fork the repository, please cite this repository (see below), and add it as a related work (below and by adding the appropriate metadata on Zenodo).",
      "",
      "By participating in this project, you agree to abide by the [Contributor Covenant](https://www.contributor-covenant.org/version/2/0/code_of_conduct.html).",
      "",
      "## Related works",
      "",
      "Optionally, cite the canonical reference for the theory implemented in this repository here. This is redundant with adding the cross-reference in Zenodo, but may be useful nonetheless.",
      "",
      "## Citing this work",
      "",
      "See this project's Zenodo page for the preferred citation."
    )
    if(!is.null(title)) lines_readme[1] <- gsub("Theory Title Goes Here", title, lines_readme[1], fixed = TRUE)
    if (repo_exists) {
      lines_readme[15:17] <- paste0(lines_readme[15:17],
                                    " [here](",
                                    gsub(".git", "", test_repo$url[1], fixed = TRUE),
                                    c("/issues)", "/pulls)", "/fork)"))
    }
    writeLines(lines_readme, file.path(path, "README.md"))

    cli::cli_process_done()
  }, error = function(err) {
    cli::cli_process_failed()
  })

# Add Zenodo metadata -----------------------------------------------------
  tryCatch({
    if (!is_quiet())
      cli::cli_process_start("Add Zenodo metadata")
    add_zenodo_json_theory(path, title = title)
    cli::cli_process_done()
  }, error = function(err) {
    cli::cli_process_failed()
  })


# Push local repo to remote -----------------------------------------------
  if(repo_exists){
    usethis::with_project(path, {
      worcs::git_update(message = "Initial commit", repo = path, files = ".")
    }, quiet = TRUE)
  }

# Output ------------------------------------------------------------------
  invisible()
}
#
# options("usethis.quiet" = FALSE)
thepath = file.path(tempdir(), "test5")
add_fair_theory(
  path = thepath,
  title = "This is a test",
  theory_file = "c:/git_repositories/empirical_cycle/empirical_cycle.dot",
  remote_repo = "theory_test5",
  add_license = "ccby"
)
unlink(thepath, recursive = TRUE)
#
# utils::browseURL(dirname(thepath))
