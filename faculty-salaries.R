library(here) # for working directory
library(tidyverse) # for dplyr, readr, stringr, tidyr, tibble, and purrr
library(lubridate) # supposedly in tidyverse but maybe not
library(readxl) # to read in xlsx files
library(lettercase)
library(ggplot2)
library(knitr)

d <- read_xlsx("anthro-salary-for-R.xlsx", guess_max = 10000) # guess max set close to length of file
d <- d %>% rename(`Base Salary (2017)`=`Base Salary`)

output <- d %>% group_by(`Rank (2017)`, `Gender`) %>% summarize(`Salary` = sum(`Base Salary (2017)`, na.rm = T), `Salary SD` = sd(`Base Salary (2017)`, na.rm = T))

p <- ggplot(data=d, aes(x=`Rank (2017)`, y=`Base Salary (2017)`, fill = `Gender`)) + geom_boxplot(outlier.alpha = 0) + geom_dotplot(binaxis='y', stackdir='center', dotsize=0.5, position=position_dodge(0.75)) + stat_summary(fun.y=mean, geom="point", shape=23, size=4)
p
