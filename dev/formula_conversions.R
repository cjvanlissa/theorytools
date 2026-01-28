library(dagitty)
library(tidySEM)
library(testthat)


g <- dagitty::dagitty('dag{
x1 -> y [form = ".5+x1"]
x2 -> y [form = "x1*x2"]
x3 -> x2 [form = "-.2-.2*I(x3^2)"]
}')
f <- "0.5+2*X+Y"
theorytools:::edges_to_analysisfun(get_edges(g))
theorytools:::edges_to_simfun(get_edges(g), beta_default = round(runif(1, -.6, .6), 2))
theorytools:::remove_intercept_beta(f)
expect_error(terms(theorytools:::char_to_form(f)))
expect_error(terms(theorytools:::char_to_form(theorytools:::form_to_formula(f))), NA)


f <- "-1+2*X+Y"
expect_error(terms(theorytools:::char_to_form(f)))
expect_error(terms(theorytools:::char_to_form(theorytools:::form_to_formula(f))), NA)
expect_true(attr(terms(theorytools:::char_to_form(theorytools:::form_to_formula(f))), "intercept") == 0)

f <- ".5 * I(A^2)"
expect_error(terms(theorytools:::char_to_form(f)))
expect_error(terms(theorytools:::char_to_form(theorytools:::form_to_formula(f))), NA)

tripartite <- dagitty('dag {
O
PP
EC
PC
CC
ER
A

PC -> CC
PC -> EC
PC -> PP
PC -> O

O -> ER [form="I(O^2)+CC:O"];
PP -> ER [form="CC:PP"];
EC -> ER [form="CC:EC"];

ER -> A

CC -> ER [form="CC:O+CC:PP+CC:EC"];

PP -> O
EC -> O
PP -> EC
}')

g <- dagitty::dagitty('dag{
a -> b [form = "I(a^2)", distribution=0]
c -> b [form = "a*c", distribution=0]
}')

g <- dagitty::dagitty('dag{
a -> b [form = ".5+2*I(a^2)", distribution=0]
c -> b [form = "3*a*c", distribution=0]
}')
edg <- tidySEM::get_edges(g)
df <- simulate_data(g, n = 1000)

derive_formula(x = g, outcome = "b", "c")
x = g; outcome = "b"; exposure = "c"
cat(simulate_data(g, run = FALSE), sep = "\n")
cat(simulate_data(tripartite, run = FALSE), sep = "\n")
df <- simulate_data(tripartite, run = TRUE)

tmp = derive_formula(tripartite, exposure = "O", outcome = "ER")
class(tmp[[1]])
# Set random seed
set.seed(123551506)
# Set simulation parameters
n <- 500
# Simulate exogenous nodes
a <- rnorm(n = n)
c <- rnorm(n = n)
# Simulate endogenous nodes
b <- .5+0.3*I(a^2) + 0.17*a + 0.52*c + -0.35*a*c + rnorm(n = n)
plot(a, b)
df <- data.frame(
  a = a,
  b = b,
  c = c
)


expect_equal(merge_formulas("a*b", "a:b"), merge_formulas("a*b", "a"))
expect_equal(merge_formulas("a+b+a:b", "a:b"), merge_formulas("a*b", "a"))


f <- "I(O^2)+CC*O"
rhs <- list("O^2+CC:O", "CC:PP")
reformulate(rhs[[1]])
rhs <- list("I(O^2)+CC:O", "CC:PP")
merge_formulas <- function(...){
  rhs <- list(...)
  rhs <- rhs[sapply(rhs, `!=`, "0")] # drop "0"
  rhs <- do.call(paste, c(rhs, sep = " + "))
  # use "0" if rhs is empty
  if(length(rhs) < 1) rhs <- "0"
  # Remove redundant terms
  trms <- terms(formula(paste0("~", rhs)))
  rhs <- paste0(attr(trms, "term.labels"), collapse = "+")
  return(rhs)
}

simulate_data(tripartite, run = FALSE)

edg <- get_edges(tripartite)
edg <- edg[edg$to == "ER", ]


# Set random seed
set.seed(2132695139)
# Set simulation parameters
n <- 500
# Simulate exogenous nodes
PC <- rnorm(n = n)
# Simulate endogenous nodes
CC <- 0.3*PC + rnorm(n = n)
PP <- -0.58*PC + rnorm(n = n)
EC <- -0.026*PC + -0.217*PP + rnorm(n = n)
O <- 0.251*EC + -0.049*PC + -0.165*PP + rnorm(n = n)
set.seed(1)
head(model.matrix(~CC:O+CC:PP+CC:EC + CC:EC + CC:O + CC:PP, data = environment()))

set.seed(1)
head(model.matrix(~CC*O+CC*PP+CC*EC, data = environment()))

set.seed(1)
head(model.matrix(~I(CC*O)+I(CC*PP)+I(CC*EC), data = environment()))

set.seed(1)
head(model.matrix(~I(CC:O)+I(CC:PP)+I(CC:EC), data = environment()))

set.seed(1)
head(model.matrix(~-1+ CC:O+CC:PP+CC:EC , data = environment()))

ER <- CC:O+CC:PP+CC:EC + CC:EC + CC:O + CC:PP + rnorm(n = n)
A <- -0.019*ER + rnorm(n = n)
df <- data.frame(
  A = A,
  CC = CC,
  EC = EC,
  ER = ER,
  O = O,
  PC = PC,
  PP = PP
)
