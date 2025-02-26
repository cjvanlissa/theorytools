# Directed cyclical graphs (DAGs) are a powerful tool to understand and deal with causal inference. The book “Causal inference in statistics: a primer” is a useful reference to start, authored from Pearl, Glymour, and Jewell. Directed cyclical graphs (DAGs) are a powerful tool to understand and deal with causal inference. Causal inference in statistics: a primer” is a good resource from
#
# A DAG is a directed acyclic graph, a visual encoding of a joint distribution of a set of variables. In a DAG all the variables are depicted as vertices and connected by arrows or directed paths, sequences of arrows in which every arrow points to some direction. DAGs are acyclic because no directed path can form a closed loop.
#
# The dagitty package is an effective tool for drawing and analyzing DAGs. Available functions include identification of minimal sufficient adjustment sets for estimating causal effects.
#
# Let’s now focus on the following example. We are interesting in draw causal inference of the treatment (T) effect on a certain outcome (Y). The analysis can be biased due to the presence of several confounders (X1, X2, X3).
#
# Let’s presume some relationships and code them with dagitty functions.

library(dagitty)
dag <- dagitty("dag {
  X1 -> X2
  X1 -> Y
  X3 -> X2
  X2 -> Y
  X2 -> T -> Y
  X3 -> T
               }")

dagitty('dag {
  ImmigrantStatus -> GreekLanguageSkills [form="test"];
  SelfEfficacy -> GreekLanguageSkills
  ImmigrantStatus -> SelfEfficacy
}') -> dag
plot(dag)
dagitty::children(dag, "ImmigrantStatus")
dagitty("dag {
Observation
ParentingPractices
EmotionalClimate
ParentCharacteristics
ChildCharacteristics
EmotionRegulation
Adjustment

ParentCharacteristics -> ChildCharacteristics
ParentCharacteristics -> EmotionalClimate
ParentCharacteristics -> ParentingPractices
ParentCharacteristics -> Observation

Observation <-> ParentingPractices
Observation <-> EmotionalClimate
Observation <-> EmotionRegulation
Observation <-> Adjustment
ParentingPractices <-> EmotionalClimate
ParentingPractices <-> EmotionRegulation
EmotionalClimate <-> EmotionRegulation
EmotionalClimate <-> Adjustment
EmotionRegulation <-> Adjustment
}") -> dag


dagitty("dag {
Observation
ParentingPractices
EmotionalClimate
ParentCharacteristics
ChildCharacteristics
EmotionRegulation
Adjustment

ParentCharacteristics -> ChildCharacteristics
ParentCharacteristics -> EmotionalClimate
ParentCharacteristics -> ParentingPractices
ParentCharacteristics -> Observation

Observation <- ParentingPractices
Observation <- EmotionalClimate
Observation -> EmotionRegulation

ParentingPractices -> EmotionalClimate
ParentingPractices -> EmotionRegulation
EmotionalClimate -> EmotionRegulation
EmotionalClimate -> Adjustment
EmotionRegulation -> Adjustment
}") -> dag

library(tidySEM)
graph_sem(dag)

lo <- get_layout(
"",                      "Observation",        "",                     "EmotionRegulation",                  "",
"",                      "ParentingPractices", "",                     "", "Adjustment",
"",                      "EmotionalClimate",   "",                     "",                  "",
"ParentCharacteristics", "",                   "",                     "",                  "",
"",                      "",                   "ChildCharacteristics", "",                  "",
rows = 5
)
graph_sem(dag, layout = lo, angle = 179)


# HIER
lo <- get_layout(
  "",   "O",    "ER", "",
  "PP",   "",   "",   "A",
  "",   "EC",   "",   "",
  "PC", "",     "",   "",
  "",   "CC", "",   "",
  rows = 5
)

lo <- get_layout(
  "",   "O",  "",   "", "",
  "",   "PP", "",   "ER",   "A",
  "",   "EC", "",   "",   "",
  "PC", "",   "CC", "",   "",
  rows = 4
)
edg <- data.frame(
  from = c("EC", "EC", "EC", "ER", "O", "PC", "PC", "PC", "PC", "PP", "PP", "PP", "O"),
  to =   c("A", "ER", "O", "A", "ER", "CC", "EC", "O", "PP", "EC", "ER", "O", "A"),
  curvature = c(NA, NA, 60, NA, NA, NA, NA, NA, NA, -60, NA, 60, NA))
p <- prepare_graph(edges = edg, layout = lo)
p$edges$connect_from = c("right", "right", "left", "right", "right", "right", "top", "top", "top", "left", "right", "left", "right")
p$edges$connect_to = c("left", "left", "left", "left", "left", "left", "left", "left", "left", "left", "left", "left", "left")
p$edges$arrow <- "both"
p$edges$arrow[which(p$edges$from == "PC")] <- "last"
plot(p) + geom_segment(aes(x = p$nodes$x[p$nodes$name == "CC"], y = p$nodes$node_ymax[p$nodes$name == "CC"]+.2), yend = (p$nodes$node_ymax[p$nodes$name == "CC"]+2), linewidth = 4,
                       arrow = arrow(length = unit(0.03, "npc"), ends = "both"))

p <- prepare_graph(layout = lo, angle = 179, text_size = 3, rect_width = 1.1, rect_height = 1, spacing_x = 1.5, spacing_y = 1.5)
p$edges$connect_from <- c("right", "right", "top", "bottom", "right", "right", "right", "right", "right", "right", "right", "right")
p$nodes$label <- c("Adjustment", "Child\nCharacteristics", "Emotional\nClimate", "Emotion\nRegulation", "Observation", "Parent\nCharacteristics", "Parenting\nPractices")
p$nodes$shape <- "rect"
#p$nodes$fill <- "black"

plot(p)

plot( graphLayout( dag ) )
# X3 is a parent of X2 and T, X2 is an ancestor of Y, Y is a child of X2 and Y is a descendant of X2.
#
#
# Let’s now make things clearer providing relative coordinates.

coordinates( dag ) <-  list(
  x=c(X1=3, X2=3, X3=1, T=2, Y=4),
  y=c(X1=1, X2=2, X3=2, T=3, Y=3) )
plot( dag )


# We can now ask with a function if we are adjusting with the correct set of variables.
exposures(dag) <- c("ParentingPractices")
outcomes(dag) <- c("EmotionRegulation", "Adjustment")
outcomes(dag) <- c("EmotionRegulation")
isAdjustmentSet( dag, c("ParentCharacteristics") )
dagitty::adjustmentSets(dag, exposure = "ParentingPractices", outcome = "Adjustment")

tmp <- dagitty::adjustmentSets(dag, exposure = "Observation", outcome = "EmotionRegulation")

dagitty::simulateSEM(dag)

dagitty::
exposures(dag) <- c("ImmigrantStatus")
outcomes(dag) <- c("SelfEfficacy")
isAdjustmentSet( dag, c("GreekLanguageSkills") )

isAdjustmentSet( dag, c("X1") )

isAdjustmentSet( dag, c("X2", "X1") )

# In order to draw unbiased causal inference we could adjust or match on both X1 and X2. Adjusting only for X1 or X2 will not remove the potential source of bias. Adjusting for X1, X2 and X3 is not required.

# We can do the same with ggdag.

library(ggdag)
library(ggplot2)
tidy_dag <- tidy_dagitty(dag)
ggdag(tidy_dag) +
  theme_dag()

# We can now ask for the children or parents of some variables.

ggdag_parents(tidy_dag, "T", text_col = "black")
ggdag_children(tidy_dag, "T", text_col = "black")
# But most importantly we can ask what are the minmal adjustment sets

ggdag_adjustment_set(tidy_dag, node_size = 14, text_col = "black") +
  theme(legend.position = "bottom")
# And we have two suggestions from ggdag: X1 and X2 or X2 and X3.


