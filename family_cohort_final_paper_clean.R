#====================================
# Final Research Project Analysis 
#====================================

#-----------------------------------
# Setting up workspace
#-----------------------------------

# This snippet of code is a little loop that makes my code work on your computer
root <- getwd()
while(basename(root) != "family-cohort") {
  root <- dirname(root)
}

# This line runs the script in your data.R file so that each person can have
# their data in a different place because everyone's file structure will be 
# a little different
source(file.path(root, "data.R"))

# Loading the packages we want
library(tidyverse)
library(haven) # for reading stata data
library(lfe) # for fixed effect regression
library(stargazer) # for pretty regression tables
library(bda)

library(xtable)
library(Hmisc)

library(ggplot2)

#-----------------------------------
# Loading In the Data
#-----------------------------------

#df <- read_dta(file.path(ddir, "Joneses", "ipums.dta.gz"))

#save(small_df, file = file.path(ddir, "Joneses", "small_df.Rda"))

load(file.path(ddir, "df.Rda"))

df_regression <- df %>% 
  filter(PWMETRO == 5080 | PWMETRO == 7240 | PWMETRO == 1520 | PWMETRO == 520 | PWMETRO == 3360 | PWMETRO == 1600) %>%
  mutate(race_non_white = if_else(RACE != 1, 1, 0, missing = NULL)) 

prop_non_white = df_regression %>% 
  group_by(PWMETRO, YEAR) %>%
  summarise(diversity_prop = mean(race_non_white))

df_regression <- left_join(df_regression, prop_non_white, by = c("PWMETRO", "YEAR"))

#adding dummy variable for married or not 
df_regression <- df_regression %>%
  filter(MARST == 1) %>%
  mutate(interracial_marriage = if_else(RACE != RACE_SP, 1, 0, missing = NULL))

#making age groupings
df_regression$AgeGroup <- cut(df_regression$AGE, breaks = c(seq(0, 100, by = 20), Inf), right = FALSE)

#making income groupings
df_regression$inc <- cut(df_regression$HHINCOME, breaks = c(0, 25000, 50000, 10000, 200000, 9999999),
                         labels = c("low", "med low", "med", "med high", "high"))

#education codebook 
educ_codebook <- tibble(EDUC = c(0,1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11),
                        educ = c("NA", "Grade School", "Grade School",
                                 "High School", "High School", "High School",
                                 "High School", "College", "College", "College", "College", "College"))
df_regression <- df_regression %>% left_join(educ_codebook)

#filter based on city size 
df_small_city <- df_regression %>%
  filter(PWMETRO == 5080 | PWMETRO == 7240 | PWMETRO == 1520)

df_big_city <- df_regression %>%
  filter(PWMETRO == 520 | PWMETRO == 3360 | PWMETRO == 1600)


#running the regressions
fe1 <- felm(interracial_marriage ~ diversity_prop | PWMETRO, data = df_small_city)
fe2 <- felm(interracial_marriage ~ diversity_prop | PWMETRO + educ, data = df_small_city)
fe3 <- felm(interracial_marriage ~ diversity_prop | PWMETRO + inc, data = df_small_city)
fe4 <- felm(interracial_marriage ~ diversity_prop | PWMETRO + educ + inc, data = df_small_city)

fe01 <- felm(interracial_marriage ~ diversity_prop | PWMETRO, data = df_big_city)
fe02 <- felm(interracial_marriage ~ diversity_prop | PWMETRO + educ, data = df_big_city)
fe03 <- felm(interracial_marriage ~ diversity_prop | PWMETRO + inc, data = df_big_city)
fe04 <- felm(interracial_marriage ~ diversity_prop | PWMETRO + educ + inc, data = df_big_city)


stargazer(fe1, fe2, fe3, fe4)
stargazer(fe01, fe02, fe03, fe04)

#fe5 <- felm(interracial_marriage ~ diversity_prop | YEAR + AgeGroup, data = df_regression)
#fe6 <- felm(interracial_marriage ~ diversity_prop | YEAR + AgeGroup + educ, data = df_regression)
#fe7 <- felm(interracial_marriage ~ diversity_prop | YEAR + AgeGroup + inc, data = df_regression)
#fe8 <- felm(interracial_marriage ~ diversity_prop | YEAR + AgeGroup + educ + inc, data = df_regression)

#fe9 <- felm(interracial_marriage ~ diversity_prop | YEAR, data = df_regression)
#fe10 <- felm(interracial_marriage ~ diversity_prop | YEAR + educ, data = df_regression)
#fe11 <- felm(interracial_marriage ~ diversity_prop | YEAR + inc, data = df_regression)
#fe12 <- felm(interracial_marriage ~ diversity_prop | YEAR + educ + inc, data = df_regression)

#fe13 <- felm(interracial_marriage ~ diversity_prop | PWMETRO, data = df_regression)
#fe14 <- felm(interracial_marriage ~ diversity_prop | PWMETRO + educ, data = df_regression)
#fe15 <- felm(interracial_marriage ~ diversity_prop | PWMETRO + inc, data = df_regression)
#fe16 <- felm(interracial_marriage ~ diversity_prop | PWMETRO + educ + inc, data = df_regression)

#stargazer(fe9, fe10, fe11, fe12)
#stargazer(fe13, fe14, fe15, fe16)


