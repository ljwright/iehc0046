setwd("E:/Miscellaneous/Courses/IEHC0046")
library(tidyverse)
library(haven)
library(sjlabelled)

# Session 3: Analysis of Categorical Data I
mi483 <- read_dta("mi483.dta") %>%
  mutate(sex = factor(sex, labels = c("Male", "Female")),
         smok = factor(smok, labels = c("No", "Yes")),
         agegroup = ordered(agegroup, labels = c("60-64", "65-69", "70-74", "75+")),
         married = factor(married, labels = c("Unmarried", "Married")),
         mi_death = factor(mi_death, levels = 1:0, labels = c("Died", "Survived"))) %>%
  var_labels(sex = "Sex", smok = "Smoking Status", agegroup = "Age Group",
             married = "Marital Status", mi_death = "Death from MI")
save(mi483, file = "mi483.R")

# Session 4: Analysis of Categorical Data II
mi2570 <- read_dta("mi2570.dta") %>%
  mutate(town = factor(town),
         sex = factor(sex, labels = c("Male", "Female")),
         maritstat = factor(maritstat, labels = c("Married", "Single", "Divorced", "Widowed")),
         smok = factor(smok, levels = 1:0, labels = c("Yes", "No")),
         cig_day = ifelse(cig_day == 888, 0, cig_day),
         agegroup = ordered(agegroup, labels = c("30-39", "40-49", "50-59", "60-69")),
         married = factor(married, labels = c("Unmarried", "Married")),
         mi = factor(mi, levels = 1:0, labels = c("Died", "Survived"))) %>%
  var_labels(town = "Study Town", sex = "Sex", maritstat = "Marital Status",
             smok = "Smoking Status", cig_day = "Cigarettes per day",
             agegroup = "Age Group", married = "Marital Status (Short)",
             mi = "Death from MI")
save(mi2570, file = "mi2570.R")

# Session 5: Analysis of Categorical Data III
russia1 <- read_dta("russia1.dta") %>%
  mutate(physact = factor(physact, labels = c("No", "Yes")),
         car = factor(car, labels = c("Never", "In the past", "Yes, now")),
         bmi = as.numeric(bmi),
         obese = factor(obese, levels = 1:0, labels = c("BMI > 30", "BMI < 30")),
         agecat = factor(agecat),
         smok = factor(smok, levels = 1:0, labels = c("No", "Yes")),
         poor = factor(poor, labels = c("Not Poor", "Poor")),
         marstat = factor(marstat, levels = 1:2, labels = c("Married and Cohabiting", "Otherwise")),
         sex = factor(sex, labels = c("Male", "Female")),
         age = as.numeric(age),
         educ3 = factor(educ3, labels = c("Primary or less", "Secondary", "University")),
         unempl = factor(unempl, labels = c("No", "Yes")),
         srh = factor(srh, labels = c("Very good", "Good", "Average", "Poor", "Very poor"))) %>%
  var_labels(physact = "Does physical activity", car = "Car ownership", bmi = "Body Mass Index",
             obese = "Is obese", agecat = "Age category", smok = "Smoker", poor = "Poor self rated health",
             marstat = "Marital status", sex = "Sex", age = "Age", educ3 = "Education level",
             unempl = "Unemployment experience", srh = "Self-rated health")
save(russia1, file = "russia1.R")

# Session 6: Mean and Analysis of Continuous Variables I
zap_negative_labels <- function(x){
  label <- attr(x, "label")
  
  old_labels <- attr(x, "labels")
  correct_labels <- old_labels[old_labels >= 0]
  
  if (length(correct_labels)>0){
    x <- factor(x, levels = correct_labels, labels = names(correct_labels))
  } else{
    x <- as.numeric(x)
  }
  
  attr(x, "label") <- label
  
  return(x)
}

contin1 <- read_dta("contin1.dta") %>%
  map_dfr(zap_negative_labels) %>%
  mutate(ageg = ordered(ageg))
attr(contin1$ageg, "label") <- "Age Group"
save(contin1, file = "contin1.R")

# Session 6: Analysis of Continuous Variables II
zap_stata <- function(x){
  attr(x, "format.stata") <- NULL
  return(x)
}

contin2 <- read_dta("contin2.dta") %>%
  haven::as_factor() %>%
  map_dfc(zap_stata)
save(contin2, file = "contin2.R")

# Session 7: Analysis of Continuous Variables III
contin3 <- read_dta("contin3.dta") %>%
  map_dfc(zap_negative_labels) %>%
  mutate(chew = ordered(chew))
attr(contin3$chew, "label") <- "Chewing difficulty"
save(contin3, file = "New/Session 8/contin3.R")
