library(tidyverse)
library(haven)

setwd("D:/Miscellaneous/Courses/IEHC0046")
  
remove_na <- function(var){
  lbls <- attr(var, "labels")
  
  lbls <- lbls[lbls >= 0]
  if (length(lbls)==0){
    attr(var, "labels") <- NULL
    class(var) <- typeof(var)
  } else attr(var, "labels") <- lbls
  
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
