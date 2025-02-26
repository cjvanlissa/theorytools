## code to prepare `motti-stefanidi2012` dataset goes here
# txt <- readClipboard()
c("Variable\t(Score Range) Age n M SD ADV1 INV1 SEF1 GPA1 GPA2 GPA3 CON1 CON2 CON3 EMO1 EMO2 EMO3 POP1 POP2 POP3",
  "Immigrant (0 = no, 1 = yes)\t13 IMM1 1057 0.50 0.50 .27\t2.40\t2.15\t2.42\t2.41\t2.39\t2.14\t2.17\t2.02\t2.01\t2.01\t2.07\t2.13\t2.11\t2.04",
  "Adversity (0–4) 13 ADV1 1017 0.83 0.80\t2.21\t2.15\t2.29\t2.24\t2.24\t2.07\t2.04 .04 .02 .01 .04\t2.08\t2.03\t2.01",
  "Involvement (1–5) 13 INV1 889 3.38 1.15 .17 .54 .48 .47 .27 .13 .03 .05\t2.01 .00 .16 .12 .07",
  "Self-efficacy (1–7) 13 SEF1 967 5.43 0.87 .33 .26 .22 .16 .15\t2.01 .19 .18 .19 .13 .08 .09",
  "Academic (1–20) 13 GPA1 843 13.7 3.02 .89 .84 .39 .29 .19 .09 .06 .03 .34 .21 .15",
  "Academic (1–20) 14 GPA2 748 13.3 2.97 .89 .34 .35 .18 .09 .00\t2.01 .26 .18 .11",
  "Academic (1–20) 15 GPA3 620 13.4 3.02 .31 .38 .22 .09 .00\t2.02 .22 .12 .08",
  "Conduct (1–5) 13 CON1 1026 4.59 0.72 .43 .32\t2.01 .00\t2.06 .13 .06\t2.01",
  "Conduct (1–5) 14 CON2 546 4.45 0.76 .44 .01 .00\t2.06\t2.05\t2.02\t2.04",
  "Conduct (1–5) 15 CON3 522 4.37 0.76\t2.07\t2.08\t2.06 .00\t2.01\t2.03",
  "Emotional (0–2) 13 EMO1 965 1.45 0.46 .49 .37 .06 .06 .06",
  "Emotional (0–2) 14 EMO2 730 1.54 0.44 .59 .10 .11 .12", "Emotional (0–2) 15 EMO3 589 1.46 0.51 .05 .08 .04",
  "Peer popularity\t(z score within\tclassroom) 13 POP1 1045 0.00 0.98 .46 .37\t",
  "Peer popularity\t(z score within\tclassroom) 14 POP2 719 0.03 0.99 .43",
  "Peer popularity\t(z score within\tclassroom) 15 POP3 571 0.04 0.98"
) -> txt

header <- txt[1]
nams <- strsplit(header, "\\s")[[1]][-2]
nams[2] <- "Range"
x <- txt[2]

out <- lapply(txt[-1], function(x){
  v <- gsub("^(.+?)\\(.*", "\\1", x)
  meas <- gsub("^.+?\\((.+?)\\).*", "\\1", x)
  rest <- gsub("^.+?\\)(.*)", "\\1", x)
  res <- strsplit(rest, "\\s")[[1]]
  res <- res[!res==""]
  trimws(c(v, meas, res))
})

tab <- data.frame(do.call(rbind, lapply(out, `[`, j = 1:7)))
tab$measurement <- c("ordered", "numeric")[startsWith(tab$X2, "z")+1L]
tab$min <- sapply(regmatches(tab$X2, gregexpr("[0-9]+", tab$X2)), `[`, i = 1)
tab$max <- sapply(regmatches(tab$X2, gregexpr("[0-9]+", tab$X2)), `[`, i = 2)
names(tab) <- c("Construct", "Range", "Age", "Variable", "n", "M", "SD", "type", "min", "max")
tab[c("Age", "n", "min", "max")] <- lapply(tab[c("Age", "n", "min", "max")], as.integer)

tab <- rbind(tab[tab$Variable == "GPA1", ], tab)
tab[1, c(1, 2, 4)] <- c("Greek", "1-10", "GRK1")
tab[1, c(5)] <- max(tab$n)
tab[1, c(6,7)] <- c(4.4, 1.5)
tab[1, c(9,10)] <- c(1, 10)

cvals <- (lapply(1:15, function(i){
  # i = 1
  vals <- out[[i]][8:length(out[[i]])]
  vals <- gsub("2.", "-0.", vals, fixed = TRUE)
  vals

}))

cvals <- as.numeric(unlist(cvals))
cors <- matrix(nrow = 16, ncol = 16)
cors[t(upper.tri(cors))] <- cvals
cors[upper.tri(cors)] <- t(cors)[upper.tri(cors)]
diag(cors) <- 1
rownames(cors) <- colnames(cors) <- tab$Variable[-1]

# dput(cors["GPA1", ], "clipboard")
add_grk <- c(GRK1 = 1, IMM1 = -0.4, ADV1 = -0.1, INV1 = 0.1, SEF1 = 0.23, GPA1 = 1,
             GPA2 = 0.89, GPA3 = 0.84, CON1 = 0.19, CON2 = 0.9, CON3 = 0.9,
             EMO1 = 0.03, EMO2 = 0.03, EMO3 = 0.03, POP1 = 0.1, POP2 = 0.11,
             POP3 = 0.1)
cors <- cbind(GRK1 = add_grk, rbind(GRK1 = add_grk[-1], cors))

# seeds with confounding c(3L, 5L, 6L, 7L, 8L, 9L, 10L, 15L, 18L, 19L)

set.seed(3)
df <- mvtnorm::rmvnorm(n = max(as.integer(tab$n)),
                       mean = as.numeric(tab$M),
                       sigma = as.matrix(Matrix::nearPD(cors)$mat))
df <- data.frame(df)
names(df) <- tab$Variable
df[tab$type == "ordered"] <- lapply(tab$Variable[tab$type == "ordered"], function(nam){
  x = df[[nam]]
  vals <- as.integer(tab$min[tab$Variable == nam]):as.integer(tab$max[tab$Variable == nam])
  out <- cut(x, length(vals))
  levels(out) <- vals
  out <- as.integer(as.character(out))
  mis <- sample.int(length(out), size = max(as.integer(tab$n))-as.integer(tab$n[tab$Variable == nam]))
  if(length(mis) > 0) out[mis] <- NA
  out
})

#summary(lm(SEF1~IMM1, df))$coefficients[2,4] < .05 & !(summary(lm(SEF1~IMM1+GRK1, df))$coefficients[2,4] < .05)
# summary(lm(SEF1~IMM1, df))
# summary(lm(SEF1~IMM1+GRK1, df))
#
# cor.test(df$IMM1, df$SEF1)
# paste0("#'   \\strong{", tab$Variable, "} \\tab \\code{", tab$type, "} \\tab ", tab$Construct, " at age ", tab$Age, "\\cr")
# write.csv(tab, "descriptives.csv")
# saveRDS(df, "Motti.RData")
mottistefanidi2012 <- df
usethis::use_data(mottistefanidi2012, overwrite = TRUE)
