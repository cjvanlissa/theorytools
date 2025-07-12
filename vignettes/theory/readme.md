# FAIR theory: Self-Determination Theory

## Description

This is a FAIR theory (Van Lissa et al., 2025) specification of Deci and Ryan's *Self-Determination Theory* (Deci & Ryan, 2012).
The definition of SDT used for the theory specification exercise was taken from this book chapter,
but seems to be fully consistent with the description on <https://selfdeterminationtheory.org/the-theory/>.

The theory was first specified by Van Lissa, Li, and Weber as part of the "Proposition Based Theory Specification" (PBTS) project by Andreas Glöckner, Susann Fiedler, Jennifer Biehl, & Jasper Siol (in preparation).
In this "many-theorists project", groups of scholars were each assigned a chapter of the "Handbook of Theories of Social Psychology" [@vanlangeHandbookTheoriesSocial2012],
and asked to specify it and document the process.

Van Lissa further adapted the theory specification, as documented in [this vignette](https://cjvanlissa.github.io/theorytools/articles/formalizing_sdt.html).

## Interoperability

`sdt.txt`	This file contains the main theory, specified as a DAG. It is interoperable for causal inference and data simulaiton in R, as explained in [this vignette](https://cjvanlissa.github.io/theorytools/articles/causal-inference.html).
`definitions.csv`	This file contains definitions of the constructs in `sdt.txt`, inasfar as we could find them. At present, this file is not very interoperable. We urgently invite domain experts to propose more concrete definitions of the constructs (as our attempt to identify the intended definitions likely fell short), or to propose new and better definitions.

## Contributing

If you want to contribute to this project, please get involved. You can do so in three ways:

1. **To discuss the current implementation and discuss potential changes**, file a 'GitHub' issue [here](https://github.com/cjvanlissa/self_determination_theory/issues)
2. **To directly propose changes**, send a pull request containing the proposed changes [here](https://github.com/cjvanlissa/self_determination_theory/pulls)
3. **To create a derivative theory**, please fork the repository [here](https://github.com/cjvanlissa/self_determination_theory/fork)

If you fork the repository, please cite this repository (see below), and add it as a related work (below and by adding the appropriate metadata on 'Zenodo').

By participating in this project, you agree to abide by the [Contributor Covenant](https://www.contributor-covenant.org/version/2/0/code_of_conduct.html).

## Related works

> Deci, E. L., & Ryan, R. M. (2012). Self-Determination Theory. In P. A. M. V. Lange, A. W.Kruglanski, & E. ToryHiggins (Eds.), Handbook of Theories of Social Psychology: Volume 1 (pp. 416–437). SAGE Publications Ltd. https://doi.org/10.4135/9781446249215

## Citing this work

See this project's 'Zenodo' page for the preferred citation.
