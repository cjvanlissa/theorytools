## R CMD check results

0 errors | 0 warnings | 1 note

* Initial CRAN submission.

Dear dr. Konstanze Lauseker,

thank you for your manual review of the package!
I tried to address all of your comments (below).

* \dontrun{} should only be used if the example really cannot be executed (e.g.
  because of missing additional software, missing API keys, ...) by the user.
    + As you mention that missing API keys is a reason to use \dontrun{}, I
      believe that the use of \dontrun{} is justified here. The function
      create_fair_theory() has two examples: One is for the CRAN check, and the
      other is wrapped in \dontrun{} because it uses the 'GitHub' API to create
      a new repository.
* Please ensure that your functions do not write by default or in your
  examples/vignettes/tests in the user's home filespace (including the package
  directory and getwd()).
    + I have checked every individual example, vignette, and test, and I'm
      pretty sure all use tempdir().
* Please always write package names, software names and API (application
  programming interface) names in single quotes in title and description.
    + Done
* If there are references describing the methods in your package, please add
  these in the description field of your DESCRIPTION file
    + Not yet, will update when the paper is published!
* Please omit the redudant "Toolkit" and "in R" from the title and description.
    + Done
* Please omit any default path in writing functions.
    + Done!

## Test environments

* local Windows 11, R 4.4.2
* win-builder: R version 4.4.2 (2024-10-31 ucrt)
* win-builder: R Under development (unstable) (2024-12-30 r87496 ucrt)
* win-builder: R version 4.3.3 (2024-02-29 ucrt)
* Rhub: linux (R-devel)
* Rhub: macos (R-devel)
* Rhub: macos-arm64 (R-devel)
* Rhub: windows (R-devel)
* GitHub Actions: macos-latest (release)
* GitHub Actions: windows-latest (release)
* GitHub Actions: ubuntu-latest (devel)
* GitHub Actions: ubuntu-latest (release)
* GitHub Actions: ubuntu-latest (oldrel-1)
