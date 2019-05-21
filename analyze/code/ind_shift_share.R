

#setwd("C:/Users/Rachel S/Dropbox/Research/IdentityFlows/analyze")
setwd("/Users/murpheis/Dropbox/UCB/IdentityFlows/analyze")

################################## TO DO LIST
# correct occupations that are weird
# try by peak-to-peak period
# within education groups
# within autor occupation groups
# as shares of population instead of emp

### Preamble
rm(list=ls())

library(ggplot2)
library(plm)
library(tidyr)
library(dplyr)
library(grattan) # for weighted_ntile
source("./code/shift_share_functions.R")
datapath <- "../../Data/CPSMonthly/data/"
path <- "../../IdentityFlows/analyze/output/"
input <- "./input/"

indoccsexstocks<-read.csv(paste(datapath,"stocks_3state_ind1990_occ2010_sex_codes.csv",sep=""))
p2pyears <- read.csv(paste(datapath,"p2p_years.csv",sep=""))


indoccsexstocks$year<-as.numeric(substring(as.character(indoccsexstocks$ym),1,4))

# industry and state
indsexstatestocks<-read.csv(paste(input,"stocks_3state_ind1990_sex_statefip_NONE1.csv",sep=""))
indsexstatestocks$year<-as.numeric(substring(as.character(indsexstatestocks$ym),1,4))


##########################################################################################
## Calculate employment in each broad sector by year and sex #############################
##########################################################################################

ind_sex_year <- indoccsexstocks %>%
  group_by(sex, ind1990,ind1990code, lfs, ym, year) %>%
  summarize(stock=sum(stock)) %>%
  group_by(sex, ind1990, ind1990code, lfs, year) %>%
  summarize(stock=mean(stock)) %>%
  filter(lfs=="E") %>%
  arrange(ind1990, year, sex) 

ind_sex_state_year <- indsexstatestocks %>%
  group_by(sex, ind1990,ind1990code,statefip,statefipcode, lfs, ym, year) %>%
  summarize(stock=sum(stock)) %>%
  group_by(sex, ind1990, ind1990code, statefip, statefipcode, lfs, year) %>%
  summarize(stock=mean(stock)) %>%
  filter(lfs=="E") %>%
  arrange(statefip, ind1990, year, sex) 


ind_sex_year <- broadIndCodes(ind_sex_year) 

broadInd_sex_year <- ind_sex_year %>%
  group_by(sex,broadInd,year) %>%
  summarize(stock=sum(stock)) 


byvars=list("year","broadInd")

broadInd_shift_share <- shiftShare(broadInd_sex_year,list("year","broadInd"))



ggplot() +
  geom_line(data=broadInd_shift_share, aes(x=year,y=sexShareTrue, color='True'),size=1) +
  geom_line(data=broadInd_shift_share, aes(x=year,y=sexShareFake, color='1976 Sex Shares'),size=1) +
  scale_color_hue()+
  theme(legend.position=c(.1,.9), legend.title=element_blank()) +
  labs(y="Female Share",title="Industry Shift-Share of Female Share")
ggsave("./output/shift_share.png")



broadInd_shift_share <- shiftShare(broadInd_sex_year,list("year","broadInd"))

## do shift share for peak to peak periods by state
startyears=c(1980,1990,2001,2007)
stopyears=c(1989,2000,2006,2017)
for (i in 1:4) {
  name <- paste("b_ss_", startyears[i], sep = "")
  assign(name,shiftShare(broadInd_sex_year,list("year","broadInd"),startyears[i],stopyears[i]))
}

ggplot() +
  geom_line(data=b_ss_1980, aes(x=year,y=sexShareTrue, color='True'),size=1) +
  geom_line(data=b_ss_1980, aes(x=year,y=sexShareFake, color='1980 Sex Shares'),size=1) +
  scale_color_hue()+
  theme(legend.position=c(.1,.9), legend.title=element_blank()) +
  labs(y="Female Share",title="Industry Shift-Share of Female Share")

ggplot() +
  geom_line(data=b_ss_1990, aes(x=year,y=sexShareTrue, color='True'),size=1) +
  geom_line(data=b_ss_1990, aes(x=year,y=sexShareFake, color='1990 Sex Shares'),size=1) +
  scale_color_hue()+
  theme(legend.position=c(.1,.9), legend.title=element_blank()) +
  labs(y="Female Share",title="Industry Shift-Share of Female Share")

ggplot() +
  geom_line(data=b_ss_2001, aes(x=year,y=sexShareTrue, color='True'),size=1) +
  geom_line(data=b_ss_2001, aes(x=year,y=sexShareFake, color='2001 Sex Shares'),size=1) +
  scale_color_hue()+
  theme(legend.position=c(.1,.9), legend.title=element_blank()) +
  labs(y="Female Share",title="Industry Shift-Share of Female Share")

ggplot() +
  geom_line(data=b_ss_2007, aes(x=year,y=sexShareTrue, color='True'),size=1) +
  geom_line(data=b_ss_2007, aes(x=year,y=sexShareFake, color='2007 Sex Shares, Changing Industry Shares'),size=1) +
  scale_color_hue()+
  theme(legend.position=c(.1,.9), legend.title=element_blank()) +
  labs(y="Female Share",title="Industry Shift-Share of Female Share")
ggsave("./output/shift_share_2007.png")





# try eliminating manufacturing
broadInd_sex_year_nomanuf <- broadInd_sex_year %>%
  filter(broadInd!="Manufacturing")
  
broadInd_shift_share_nomanuf <- shiftShare(broadInd_sex_year_nomanuf)


ggplot() +
  geom_line(data=broadInd_shift_share_nomanuf, aes(x=year,y=sexShareTrue, color='True'),size=1) +
  geom_line(data=broadInd_shift_share_nomanuf, aes(x=year,y=sexShareFake, color='1976 Sex Shares'),size=1) +
  scale_color_hue()+
  theme(legend.position=c(.1,.9), legend.title=element_blank()) +
  labs(y="Sex Share",title="Industry Shift-Share of Female Share, Excluding Manufacturing")
ggsave("./output/shift_share_nomanuf.png")




### do this by state
ind_sex_state_year <- broadIndCodes(ind_sex_state_year)

broadInd_sex_state_year <- ind_sex_state_year %>%
  group_by(sex,broadInd,statefip,year) %>%
  summarize(stock=sum(stock))

broadInd_state_shift_share <- shiftShare(broadInd_sex_state_year,list("year","statefip","broadInd"),1977)

broadInd_state_shift_share <- broadInd_state_shift_share %>%
  arrange(statefip,year)

ss_Ca <- broadInd_state_shift_share %>%
  filter(statefip=="California")

ss_Ny <- broadInd_state_shift_share %>%
  filter(statefip=="New York")


ggplot() +
  geom_line(data=ss_Ca, aes(x=year,y=sexShareTrue, color='CA: True'),size=1) +
  geom_line(data=ss_Ca, aes(x=year,y=sexShareFake, color='CA: 1976 Sex Shares'),size=1) +
  geom_line(data=ss_Ny, aes(x=year,y=sexShareTrue, color='NY: True'),size=1) +
  geom_line(data=ss_Ny, aes(x=year,y=sexShareFake, color='NY: 1976 Sex Shares'),size=1) +
  scale_color_hue()+
  theme(legend.position=c(.1,.9), legend.title=element_blank()) +
  labs(y="Female Share",title="Industry Shift-Share of Female Share")



#### Calculate male and female lfpr by state
lfs_sex_state_year <- indsexstatestocks %>%
  group_by(sex,statefip,statefipcode, lfs, ym, year) %>%
  summarize(stock=sum(stock)) %>%
  group_by(sex, statefip, statefipcode, lfs, year) %>%
  summarize(stock=mean(stock)) %>%
  arrange(statefip, sex, lfs , year) %>%
  filter(lfs!="_") %>%
  mutate(en = case_when(lfs=="E" | lfs=="U" ~ "In",
                        lfs=="N" ~ "Out")) %>%
  group_by(sex,statefip,statefipcode,en,year) %>%
  summarize(stock=sum(stock)) 


pop_sex_state_year <- lfs_sex_state_year %>%
  group_by(sex,statefip,statefipcode,year) %>%
  summarize(pop=sum(stock))

lfpr_sex_state_year <- lfs_sex_state_year %>%
  left_join(pop_sex_state_year,by=c("sex","statefip","statefipcode","year")) %>%
  mutate(lfpr=stock/pop) %>%
  filter(en=="In")

## just do some basic regressions in levels (note a bunch of data is missing so this is weird)

state_all <- lfpr_sex_state_year %>%
  left_join(broadInd_state_shift_share,by=c("year","statefip"))


lm1<-lm(lfpr~sexShareFake,data=filter(state_all,sex=="Female"))
summary(lm1)

lm2<-lm(lfpr~sexShareFake,data=filter(state_all,sex=="Male"))

lm2fe<-lm(lfpr~sexShareFake+factor(statefip)+factor(year),data=filter(state_all,sex=="Male"))

lm(lfpr~sexShareTrue,data=filter(state_all,sex=="Male"))


table(indsexstatestocks[indsexstatestocks$year==1976]$statefip)


## do shift share for peak to peak periods by state
startyears=c(1980,1990,2001,2007)
stopyears=c(1989,2000,2006,2017)
for (i in 1:4) {
  name <- paste("bs_ss_", i, sep = "")
  assign(name,shiftShare(broadInd_sex_state_year,list("year","statefip","broadInd"),startyears[i],stopyears[i]))
}


bs_ss_pp<-bind_rows(bs_ss_1,bs_ss_2,bs_ss_3,bs_ss_4)

lfpr_f_state_year <- lfpr_sex_state_year %>%
  filter(sex=="Female") %>%
  group_by(statefip,year) %>%
  select(statefip,year,lfpr_f=lfpr)

lfpr_m_state_year <- lfpr_sex_state_year %>%
  filter(sex=="Male") %>%
  group_by(statefip,year) %>%
  select(statefip,year,lfpr_m=lfpr)

myyears <- c(startyears,stopyears)

bs_ss_pp <- bs_ss_pp %>%
  left_join(p2pyears,by="year") %>%
  left_join(lfpr_f_state_year,by=c("year","statefip")) %>%
  left_join(lfpr_m_state_year,by=c("year","statefip")) %>%
  arrange(statefip,year) %>%
  filter(year %in% myyears)

bs_ss_pp_diffs <- bs_ss_pp %>%
  group_by(statefip) %>%
  mutate(lfpr_f_d=lfpr_f-lag(lfpr_f), lfpr_m_d=lfpr_m-lag(lfpr_m),
         sexShareFake_d = sexShareFake-lag(sexShareFake),
         sexShareTrue_d=sexShareTrue-lag(sexShareTrue))  %>%
  filter(year %in% stopyears)


lmf <- lm(lfpr_f_d ~ sexShareFake_d, data=bs_ss_pp_diffs)

lm(lfpr_m_d ~ sexShareFake_d, data=bs_ss_pp_diffs)


ggplot(bs_ss_pp_diffs, aes(x=lfpr_m_d,y=sexShareFake_d)) +
  geom_point()



ggplot(data=bs_ss_pp_diffs, aes(x=sexShareFake_d,y=lfpr_f_d)) +
  geom_point(size=1, color="orange") +
  geom_smooth(method="lm",color="palevioletred2",linetype="dashed") + 
  labs(y="Change in Female LFPR",title="Changes in LFPR and Predicted Changes in Gender Share")



ggplot(data=bs_ss_pp_diffs, aes(x=sexShareFake_d,y=lfpr_m_d)) +
  geom_point(size=1, color="springgreen3") +
  geom_smooth(method="lm",color="orchid4",line="dash") + 
  labs(y="Change in Male LFPR",title="Changes in LFPR and Predicted Changes in Gender Share")


ggplot() +
  geom_point(data=bs_ss_pp_diffs, aes(x=lfpr_f_d,y=sexShareFake_d),size=1, color="springgreen3") +
  labs(y="Change in Female LFPR",title="Changes in LFPR and Predicted Changes in Gender Share")


ggplot() +
  geom_point(data=bs_ss_pp_diffs, aes(x=lfpr_m_d,y=sexShareFake_d),size=1, color="purple") +
  labs(y="Change in Male LFPR",title="Changes in LFPR and Predicted Changes in Gender Share")



ggplot() +
  geom_point(data=bs_ss_pp_diffs, aes(x=lfpr_m_d,y=sexShareFake_d, color="Male"),size=1)  + 
  geom_smooth(method='lm',formula=sexShareFake_d~lfpr_m_d) +
  scale_color_hue()+
  theme(legend.position=c(.1,.9), legend.title=element_blank()) +
  labs(y="Change in LFPR",title="Changes in LFPR and Predicted Changes in Gender Share")
