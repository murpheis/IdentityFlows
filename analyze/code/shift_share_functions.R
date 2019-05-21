

################################## TO DO LIST
# correct occupations that are weird
# try by peak-to-peak period
# within education groups
# within autor occupation groups
# as shares of population instead of emp

### Preamble

library(ggplot2)
library(plm)
library(tidyr)
library(dplyr)
library(grattan)

# make data getting a function
shiftShare <- function(data,byvars,startyear,endyear=2017) {
  # start from first desired year
  data <- data %>%
    filter(year>=startyear,year<=endyear)
  
  # stocks by sector and year
  broadInd_year <- data %>%
    group_by_(.dots=byvars) %>%
    summarize(indStock=sum(stock))
  
  # merge to get shares by sector and year
  broadInd_sex_shares_year <- data %>%
    left_join(broadInd_year, by=unlist(byvars)) %>%
    mutate(sexShareInd=stock/indStock) %>%
    filter(sex=="Female")
  
  # total employment by year
  emp_year <- broadInd_year %>%
    group_by_(.dots=byvars[1:length(byvars)-1]) %>%
    summarize(totemp=sum(indStock))
  
  # calculate each industry's share of total employment, merge with sex shares
  broadInd_share_year <- broadInd_year %>%
    left_join(emp_year, by=unlist(byvars[1:length(byvars)-1])) %>%
    mutate(indfrac=indStock/totemp) %>%
    left_join(broadInd_sex_shares_year,by=unlist(byvars))
  
  # calculate total sex share
  sex_share_year <- data %>%
    group_by_(.dots=append("sex",byvars[1:length(byvars)-1])) %>%
    summarize(sexStock=sum(stock)) %>%
    left_join(emp_year, by=unlist(byvars[1:length(byvars)-1])) %>%
    mutate(sexShare=sexStock/totemp) %>%
    filter(sex=="Female")
  
  
  # get sex shares in 1976 for each industry
  broadInd_sex_shares_initial <- broadInd_sex_shares_year %>%
    filter(year==startyear) %>%
    rename(sexShareInd1976=sexShareInd)
  
  
  broadInd_sex_shares_initial_fill <- 
    broadInd_share_year %>%
    group_by_(.dots=byvars) %>%
    select_(.dots=c(byvars,"indfrac","sexShareInd")) %>%
    left_join(broadInd_sex_shares_initial,by=unlist(byvars)) %>%
    group_by_(.dots=byvars[2:length(byvars)]) %>%
    fill(sexShareInd1976) %>%
    left_join(sex_share_year,by=unlist(byvars[1:length(byvars)-1])) %>%
    mutate(sexShareTest=indfrac*sexShareInd,sexShareFake=indfrac*sexShareInd1976)


  broadInd_shift_share <- broadInd_sex_shares_initial_fill %>%
    group_by_(.dots=byvars[1:length(byvars)-1]) %>%
    summarize(sexShareTrue=mean(sexShare),sexShareTest=sum(sexShareTest),sexShareFake=sum(sexShareFake))

  return(broadInd_shift_share)
}

broadIndCodes <- function(data) {
  out <- data %>% 
    mutate(broadInd = case_when(ind1990code > 0 & ind1990code < 40 ~ "Farm",
                                ind1990code >= 40 & ind1990code < 60 ~ "Mining",
                                ind1990code == 60 ~ "Construction",
                                ind1990code >= 100 & ind1990code < 400 ~ "Manufacturing",
                                ind1990code >= 400 & ind1990code < 500 ~ "Public Utilities",
                                ind1990code >=500 & ind1990code < 580 ~ "Wholesale Trade",
                                ind1990code >= 580 & ind1990code < 700 ~ "Retail Trade",
                                ind1990code >=700 & ind1990code < 721  ~ "Finance",
                                ind1990code >=721 & ind1990code < 761  ~ "Business",
                                ind1990code >=761 & ind1990code < 800  ~ "Personal Services",
                                ind1990code >=800 & ind1990code < 812  ~ "Entertainment",
                                ind1990code >=812 & ind1990code < 841  ~ "Health",
                                ind1990code == 841  ~ "Legal",
                                ind1990code >=842 & ind1990code <= 863 ~ "Education",
                                ind1990code >=870 & ind1990code < 900  ~ "Other Professional",
                                ind1990code >=900 & ind1990code < 940  ~ "Public Administration",
                                ind1990code >=940  ~ "Military",
                                ind1990code ==0 | ind1990code==NA  ~ "None"))
  return(out)
  
}
  
