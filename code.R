library(tidyverse)
library(summarytools)

# 1. ----
load("elsa.Rdata")
descr(elsa$age)
descr(elsa$sbp)

ggplot(elsa) +
  aes(x = sbp) +
  geom_histogram(aes(y = ..density..)) +
  stat_function(fun = dnorm, args = list(mean = mean(elsa$sbp, na.rm = TRUE),
                                         sd = sd(elsa$sbp, na.rm = TRUE)))

ggplot(elsa) +
  aes(x = sbp) +
  geom_density(color = "red") +
  stat_function(fun = dnorm, args = list(mean = mean(elsa$sbp, na.rm = TRUE),
                                         sd = sd(elsa$sbp, na.rm = TRUE)))

ggplot(elsa) +
  aes(x = age, y = sbp) +
  geom_point()


ggplot(elsa) +
  aes(x = age, y = sbp) +
  geom_jitter(alpha = 0.2)


cor(elsa[c("age", "sbp")], use = "complete.obs")


mod <- lm(sbp ~ age, elsa)
summary(mod)

coef(mod)
coefs <- coef(mod)
coefs[1] + coefs[2]*55

library(multcomp)
glht(mod, "`(Intercept)` + 55*`age` = 0") %>%
  confint()


library(broom)
tidy(mod)
tidy(mod, conf.int = TRUE)

mod_fit <- augment(mod, se_fit = TRUE)

ggplot(elsa) +
  aes(x = age, y = sbp) +
  geom_jitter(alpha = 0.2) +
  geom_smooth(method = lm)

ggplot(mod_fit) +
  aes(x = .fitted, y = .resid) +
  geom_hline(yintercept = 0) +
  geom_jitter(alpha = 0.2)


ggplot(mod_fit) +
  aes(x = .resid) +
  geom_density(color = "red") +
  stat_function(fun = dnorm, args = list(mean = mean(mod_fit$`.resid`, na.rm = TRUE),
                                         sd = sd(mod_fit$`.resid`, na.rm = TRUE)))

ggplot(mod_fit) +
  aes(x = .std.resid) +
  geom_density(color = "red") +
  stat_function(fun = dnorm)


ggplot(mod_fit) +
  aes(x = .std.resid) +
  geom_vline(xintercept = c(-1.96, 1.96), linetype = "dashed") +
  geom_density()

# 2.  ----
freq(elsa$sex)
stby(elsa$sbp, elsa$sex, descr)

ggplot(elsa[elsa$sex == "female", ]) +
  aes(x = sbp) +
  geom_histogram(aes(y = ..density..)) +
  stat_function(fun = dnorm, args = list(mean = mean(elsa$sbp[elsa$sex == "female"], na.rm = TRUE),
                                         sd = sd(elsa$sbp[elsa$sex == "female"], na.rm = TRUE)))

ggplot(elsa[elsa$sex == "male", ]) +
  aes(x = sbp) +
  geom_histogram(aes(y = ..density..)) +
  stat_function(fun = dnorm, args = list(mean = mean(elsa$sbp[elsa$sex == "male"], na.rm = TRUE),
                                         sd = sd(elsa$sbp[elsa$sex == "male"], na.rm = TRUE)))


mod_1 <- lm(sbp ~ sex, elsa)
summary(mod_1)
coef(mod_1)[1]
coef(mod_1)[1] + coef(mod_1)[2]
t.test(sbp ~ sex, elsa)

freq(elsa$sclass)

elsa <- elsa %>%
  mutate(sclass_n = as.numeric(sclass),
         sclass_3 = case_when(sclass_n %in% 1:2 ~ "Prof/Managerial",
                              sclass_n == 3  ~ "Skilled Non-Manual",
                              sclass_n %in% 4:6 ~ "Manual/Routine") %>%
           factor(c("Prof/Managerial", "Skilled Non-Manual", 
                    "Manual/Routine")))
table(elsa$sclass, elsa$sclass_3, useNA = "ifany")


stby(elsa$sbp, elsa$sclass_3, descr)

mod_2 <- lm(sbp ~ sclass_3, elsa)
summary(mod_2)


glht(mod_2, c("`sclass_3Skilled Non-Manual` = 0",
              "`sclass_3Manual/Routine` = 0")) %>%
  summary()

glht(mod_2, c("`sclass_3Skilled Non-Manual` = 0")) %>%
  summary()

library(car)
linearHypothesis(mod_2, c("sclass_3Skilled Non-Manual = 0",
                          "sclass_3Manual/Routine = 0"))

descr(elsa[c("age", "sbp")])
freq(elsa[c("sex", "sclass_3", "wealth5", "smok_bin")])

elsa_2 <- elsa %>%
  dplyr::select(age, sbp, sex, sclass_3, wealth5, smok_bin) %>%
  mutate(n_miss = rowSums(is.na(.)),
         wealth5 = factor(wealth5))

table(elsa_2$n_miss)

mod_3 <- lm(sbp ~ sex + sclass_3 + age, elsa_2, n_miss == 0)
summary(mod_3)
glht(mod_3, "`(Intercept)` + 55*`age` + `sexfemale` + `sclass_3Manual/Routine` = 0")

mod_4 <- lm(sbp ~ sex + sclass_3 + age + wealth5, elsa_2, n_miss == 0)
summary(mod_4)
lincoms <- paste0("wealth5", 2:5, " = 0")
linearHypothesis(mod_4, lincoms)

mod_4 <- lm(sbp ~ sex + sclass_3 + age + wealth5 + smok_bin, elsa_2, n_miss == 0)
summary(mod_4)
lincoms <- paste0("wealth5", 2:5, " = 0")
linearHypothesis(mod_4, lincoms)

# Practical 3 ----
mod_1 <- lm(sbp ~ age + sex, elsa)
summary(mod_1)

mod_2 <- lm(sbp ~ age*sex, elsa)
mod_2 <- lm(sbp ~ age + sex + age:sex, elsa)
summary(mod_2)

glht(mod_2, "`(Intercept)` + `sexfemale` = 0") %>%
  confint()
glht(mod_2, "`age` + `age:sexfemale` = 0") %>%
  confint()


elsa <- elsa %>%
  mutate(wealth5 = factor(wealth5))

mod_3 <- lm(sbp ~ age + sex*wealth5, elsa)
summary(mod_3)
lincoms <- paste0("sexfemale:wealth5", 2:5, " = 0")
linearHypothesis(mod_3, lincoms)

descr(elsa[c("chol", "bmi")])

ggplot(elsa) +
  aes(x = chol) +
  geom_histogram(aes(y = ..density..)) +
  geom_density(color = "red") +
  stat_function(fun = dnorm, args = list(mean = mean(elsa$chol, na.rm = TRUE),
                                         sd = sd(elsa$chol, na.rm = TRUE)))

ggplot(elsa) +
  aes(x = age, y = chol) +
  geom_jitter(alpha = 0.2)

ggplot(elsa) +
  aes(x = bmi, y = chol) +
  geom_jitter(alpha = 0.2)

mod_4 <- lm(chol ~ age + sex + bmi, elsa)
summary(mod_4)

mod_5 <- lm(chol ~ age + sex + bmi + I(bmi^2), elsa)
summary(mod_5)

elsa <- elsa %>%
  mutate(bmi3 = fct_recode(bmi4, "Under 25" = "Under 20",
                           "Under 25" = "Over 20-25"))
table(elsa$bmi3, elsa$bmi4)

mod_6 <- lm(chol ~ age + sex + bmi3, elsa)
summary(mod_6)

install.packages("describedata")
library(describedata)
gladder(elsa$bmi)
ladder(elsa$bmi)


# 4. Confounding and effect modification ----
rm(list = ls())
load("elsa.Rdata")

freq(elsa$physact)
freq(elsa$heart_attack)
ctable(elsa$physact, elsa$heart_attack, useNA = "no", chisq = TRUE)

library(mStats)
tabOdds(elsa, physact, by = heart_attack, plot = FALSE, na.rm = TRUE)
mhor(elsa, physact, by = heart_attack, na.rm = TRUE)

events <-table(elsa$physact[elsa$heart_attack == "Mentioned"])
trials <-table(elsa$physact)
prop.trend.test(x = events, n = trials)

str(elsa$srh)
freq(elsa$srh)
elsa <- elsa %>%
  mutate(srh_2 = ifelse(srh %in% levels(srh)[1:2],
                        "Very good or good", "Fair or bad"),
         srh_2 = ifelse(is.na(srh), NA, srh_2),
         srh_2 = factor(srh_2))
table(elsa$srh, elsa$srh_2, useNA = "ifany")

ctable(elsa$srh_2, elsa$heart_attack, useNA = "no", chisq = TRUE)
ctable(elsa$physact, elsa$srh_2, useNA = "no", chisq = TRUE)

tab_3 <- table(elsa$heart_attack, elsa$physact, elsa$srh_2)
mantelhaen.test(tab_3)
mantelhaen.test(elsa$physact, elsa$heart_attack, elsa$srh_2)
library(magrittr)
elsa %>%
  dplyr::select(physact, heart_attack, srh_2) %>%
  drop_na() %$%
  epiDisplay::mhor(physact, heart_attack, srh_2, graph = F)
