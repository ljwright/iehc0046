library(tidyverse)
library(haven)
library(labelled)

setwd("D:/Miscellaneous/Courses/IEHC0046")

# ELSA  
remove_na <- function(var){
  lbls <- attr(var, "labels")
  
  lbls <- lbls[lbls >= 0]
  if (length(lbls)==0){
    attr(var, "labels") <- NULL
    class(var) <- typeof(var)
  } else attr(var, "labels") <- lbls
  
  if (is.numeric(var)){
    atrb <- attributes(var)
    var <- ifelse(var < 0, NA, var)
    attributes(var) <- atrb
  } 
  
  var
}

elsa <- read_dta("teaching_1009new.dta") %>%
  mutate(age = zap_labels(age)) %>%
  map_dfc(remove_na) %>%
  as_factor() %>%
  zap_formats() %>%
  mutate(gor = factor(gor),
         sex = fct_recode(sex, male = "Men", female = "Women"))
attr(elsa$gor, "label") <- "Government Office Region"
attr(elsa$sex, "label") <- "Sex"

save(elsa, file = "elsa.Rdata")
look_for(elsa)


# contin2
contin2 <- read_dta("contin2.dta") %>%
  as_factor() %>%
  zap_formats()
save(contin2, file = "contin2.Rdata")
