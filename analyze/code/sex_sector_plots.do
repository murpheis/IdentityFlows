*****************************************************************************
* program: sex_sector_plots.do
* author: rachel schuh
* purpose: create stock files from monthly data.
* date: 12/7/2018
*****************************************************************************

gl server = 0 //set to 1 if on server, 0 if not

if ${server}==1 {
  gl home = "/home/users/schuhr/cps"
  gl data = "${home}/data"
  gl temp = "/scratch/users/schuhr/temp"
  gl rawdata = "/scratch/users/schuhr"
}
else {
  gl home =  "C:\Users\Rachel S\Dropbox\Research\IdentityFlows\analyze"
  gl data = "${home}/input"
  gl temp = "${home}/temp"
  gl out = "${home}/output"
}

cd "${home}"


set scheme s2color
grstyle init
grstyle set plain
grstyle set color mono, n(6)
grstyle set lpattern
grstyle set legend 6, nobox



use "${data}/f_shares_sector", clear


keep if sex==2
drop if sector==14 | sector==0 //active duty military or sector unnknown



separate f_share_sec, by(sector)
{
label variable f_share_sec1 "Agriculture, forest, fish"
label variable f_share_sec2 "Mining"
label variable f_share_sec3 "Construction"
label variable f_share_sec4 "Manufacturing"
label variable f_share_sec5 "Transp, comm, oth public utilities"
label variable f_share_sec6 "Wholesale trade"

label variable f_share_sec7 "Retail trade"
label variable f_share_sec8 "Finance, insurance, and real estate"
label variable f_share_sec9 "Business and repair services"
label variable f_share_sec10 "Personal services"
label variable f_share_sec11 "Entertainment and recreation services"
label variable f_share_sec12 "Professional and related services"
label variable f_share_sec13 "Public administration"
}
*PLOT these by sector
sort sector year


********************************************************************************
* TOTAL SHARE OF EMPLOYMENT THAT IS FEMALE
********************************************************************************
line f_share_tot year if sector==1, /// not actually sector 1, aggregate
	ytitle("share female")
graph export output/f_share_tot.pdf, replace

********************************************************************************
* SHARE OF EMPLOYMENT THAT IS FEMALE BY SECTOR
********************************************************************************

twoway (line f_share_sec1 f_share_sec2 f_share_sec3 ///
	f_share_sec5 year)
graph export output/f_shares_1.pdf, replace
	
twoway (line f_share_sec6 f_share_sec4 f_share_sec9 year), ///
	ylabel(.2(.05).45)
graph export output/f_shares_2.pdf, replace
	
twoway (line f_share_sec7 f_share_sec11 ///
	f_share_sec13  year), ///
	ylabel(.3(.05).55)
graph export output/f_shares_3.pdf, replace

twoway (line f_share_sec8 f_share_sec10 ///
	f_share_sec12  year)
graph export output/f_shares_4.pdf, replace
	


********************************************************************************
* SHARE OF EMPLOYMENT THAT IS FEMALE RELATIVE TO AGGREGATE BY SECTOR
********************************************************************************

separate f_share_diff, by(sector)
{ //label each variable for graphing
label variable f_share_diff1 "Agriculture, forest, fish"
label variable f_share_diff2 "Mining"
label variable f_share_diff3 "Construction"
label variable f_share_diff4 "Manufacturing"
label variable f_share_diff5 "Transp, comm, oth public utilities"
label variable f_share_diff6 "Wholesale trade"

label variable f_share_diff7 "Retail trade"
label variable f_share_diff8 "Finance, insurance, and real estate"
label variable f_share_diff9 "Business and repair services"
label variable f_share_diff10 "Personal services"
label variable f_share_diff11 "Entertainment and recreation services"
label variable f_share_diff12 "Professional and related services"
label variable f_share_diff13 "Public administration"
}

* first quartile
twoway (line f_share_diff1 f_share_diff2 f_share_diff3 ///
	f_share_diff5  year)
graph export output/f_shares_rel_1.pdf, replace
	
	
twoway (line f_share_diff6 f_share_diff4 f_share_diff9 ///
	 year)
graph export output/f_shares_rel_2.pdf, replace
	
twoway (line f_share_diff11 ///
	f_share_diff13  f_share_diff7 year)
graph export output/f_shares_rel_3.pdf, replace
	
twoway (line  f_share_diff8 f_share_diff10 ///
	f_share_diff12  year)
graph export output/f_shares_rel_4.pdf, replace
	


********************************************************************************
* EMPLOYMENT GROWTH IN EACH RECOVERY ORGANIZED BY FEMALE SHARES
********************************************************************************
use "${temp}/sectors_recoveries", clear
keep if sex==2 //no need for employment by sex at this point
* sort by female share at beginning of sample
xtile initial_xtile=f_share_sec if year==1976, nq(4)
bysort sector (year): carryforward initial_xtile, replace

separate emp_sec_change_s, by(sector)
{ //label each variable for graphing
label variable emp_sec_change_s1 "Agriculture, forest, fish"
label variable emp_sec_change_s2 "Mining"
label variable emp_sec_change_s3 "Construction"
label variable emp_sec_change_s4 "Manufacturing"
label variable emp_sec_change_s5 "Transp, comm, oth public utilities"
label variable emp_sec_change_s6 "Wholesale trade"

label variable emp_sec_change_s7 "Retail trade"
label variable emp_sec_change_s8 "Finance, insurance, and real estate"
label variable emp_sec_change_s9 "Business and repair services"
label variable emp_sec_change_s10 "Personal services"
label variable emp_sec_change_s11 "Entertainment and recreation services"
label variable emp_sec_change_s12 "Professional and related services"
label variable emp_sec_change_s13 "Public administration"
}
	
	


********************************************************************************
* PCT EMPLOYMENT GROWTH IN EACH RECOVERY ORGANIZED BY FEMALE SHARES
********************************************************************************
use "${temp}/sectors_recoveries", clear
keep if sex==2 //no need for employment by sex at this point
* sort by female share at beginning of sample
xtile initial_xtile=f_share_sec if year==1976, nq(4)
bysort sector (year): carryforward initial_xtile, replace

separate emp_sec_change_pct_s, by(sector)
{ //label each variable for graphing
label variable emp_sec_change_pct_s1 "Agriculture, forest, fish"
label variable emp_sec_change_pct_s2 "Mining"
label variable emp_sec_change_pct_s3 "Construction"
label variable emp_sec_change_pct_s4 "Manufacturing"
label variable emp_sec_change_pct_s5 "Transp, comm, oth public utilities"
label variable emp_sec_change_pct_s6 "Wholesale trade"

label variable emp_sec_change_pct_s7 "Retail trade"
label variable emp_sec_change_pct_s8 "Finance, insurance, and real estate"
label variable emp_sec_change_pct_s9 "Business and repair services"
label variable emp_sec_change_pct_s10 "Personal services"
label variable emp_sec_change_pct_s11 "Entertainment and recreation services"
label variable emp_sec_change_pct_s12 "Professional and related services"
label variable emp_sec_change_pct_s13 "Public administration"
}
	
	
* Recovery 1
twoway (line emp_sec_change_pct_s1 emp_sec_change_pct_s2 emp_sec_change_pct_s3 ///
	emp_sec_change_pct_s5  year if recovery==1)
	
	
twoway (line emp_sec_change_pct_s6 emp_sec_change_pct_s4 emp_sec_change_pct_s9 ///
	emp_sec_change_pct_s13  year if recovery==1)
	
twoway (line emp_sec_change_pct_s11 ///
	emp_sec_change_pct_s13  emp_sec_change_pct_s7 year if recovery==1)
	
twoway (line  emp_sec_change_pct_s8 emp_sec_change_pct_s10 ///
	emp_sec_change_pct_s12  year if recovery==1)
	
* Recovery 2	
twoway (line emp_sec_change_pct_s1 emp_sec_change_pct_s2 emp_sec_change_pct_s3 ///
	emp_sec_change_pct_s5  year if recovery==2)
	
	
twoway (line emp_sec_change_pct_s6 emp_sec_change_pct_s4 emp_sec_change_pct_s9 ///
	emp_sec_change_pct_s13  year if recovery==2)
	
twoway (line emp_sec_change_pct_s11 ///
	emp_sec_change_pct_s13  emp_sec_change_pct_s7 year if recovery==2)
	
twoway (line  emp_sec_change_pct_s8 emp_sec_change_pct_s10 ///
	emp_sec_change_pct_s12  year if recovery==2)
	
* Recovery 3	
twoway (line emp_sec_change_pct_s1 emp_sec_change_pct_s2 emp_sec_change_pct_s3 ///
	emp_sec_change_pct_s5  year if recovery==3)
	
	
twoway (line emp_sec_change_pct_s6 emp_sec_change_pct_s4 emp_sec_change_pct_s9 ///
	emp_sec_change_pct_s13  year if recovery==3)
	
twoway (line emp_sec_change_pct_s11 ///
	emp_sec_change_pct_s13  emp_sec_change_pct_s7 year if recovery==3)
	
twoway (line  emp_sec_change_pct_s8 emp_sec_change_pct_s10 ///
	emp_sec_change_pct_s12  year if recovery==3)
	

* Recovery 4	
twoway (line emp_sec_change_pct_s1 emp_sec_change_pct_s2 emp_sec_change_pct_s3 ///
	emp_sec_change_pct_s5  year if recovery==4)
	
	
twoway (line emp_sec_change_pct_s6 emp_sec_change_pct_s4 emp_sec_change_pct_s9 ///
	emp_sec_change_pct_s13  year if recovery==4)
	
twoway (line emp_sec_change_pct_s11 ///
	emp_sec_change_pct_s13  emp_sec_change_pct_s7 year if recovery==4)
	
twoway (line  emp_sec_change_pct_s8 emp_sec_change_pct_s10 ///
	emp_sec_change_pct_s12  year if recovery==4)
	
* Recovery 5	
twoway (line emp_sec_change_pct_s1 emp_sec_change_pct_s2 emp_sec_change_pct_s3 ///
	emp_sec_change_pct_s5  year if recovery==5)
	
	
twoway (line emp_sec_change_pct_s6 emp_sec_change_pct_s4 emp_sec_change_pct_s9 ///
	emp_sec_change_pct_s13  year if recovery==5)
	
twoway (line emp_sec_change_pct_s11 ///
	emp_sec_change_pct_s13  emp_sec_change_pct_s7 year if recovery==5)
	
twoway (line  emp_sec_change_pct_s8 emp_sec_change_pct_s10 ///
	emp_sec_change_pct_s12  year if recovery==5)
	
	
********************************************************************************
* PCT EMPLOYMENT GROWTH OVER ENTIRE SAMPLE ORGANIZED BY FEMALE SHARES
********************************************************************************
use "${temp}/sectors_growth", clear
keep if sex==2 //no need for employment by sex at this point
* sort by female share at beginning of sample
*xtile initial_xtile=f_share_sec if year==1976, nq(4)
*gen f_share_sec0=f_share_sec if year==1976
bysort sector (year): carryforward initial_xtile f_share_sec0, replace

separate emp_share_sec_change, by(sector)
{ //label each variable for graphing
label variable emp_share_sec_change1 "Agriculture, forest, fish"
label variable emp_share_sec_change2 "Mining"
label variable emp_share_sec_change3 "Construction"
label variable emp_share_sec_change4 "Manufacturing"
label variable emp_share_sec_change5 "Transp, comm, oth public utilities"
label variable emp_share_sec_change6 "Wholesale trade"

label variable emp_share_sec_change7 "Retail trade"
label variable emp_share_sec_change8 "Finance, insurance, and real estate"
label variable emp_share_sec_change9 "Business and repair services"
label variable emp_share_sec_change10 "Personal services"
label variable emp_share_sec_change11 "Entertainment and recreation services"
label variable emp_share_sec_change12 "Professional and related services"
label variable emp_share_sec_change13 "Public administration"
}
	
	
* Recovery 1
twoway (line emp_share_sec_change1 emp_share_sec_change2 emp_share_sec_change3 ///
	emp_share_sec_change5  year)
	
	
twoway (line emp_share_sec_change6 emp_share_sec_change4 emp_share_sec_change9 ///
	emp_share_sec_change13  year)
	
twoway (line emp_share_sec_change11 ///
	emp_share_sec_change13  emp_share_sec_change7 year)
	
twoway (line  emp_share_sec_change8 emp_share_sec_change10 ///
	emp_share_sec_change12  year)
	
	
	
twoway (line emp_share_sec_change1 emp_share_sec_change2 emp_share_sec_change3 ///
	emp_share_sec_change5  year, lcolor(blue ..)) ///
	(line emp_share_sec_change6 emp_share_sec_change4 emp_share_sec_change9 ///
	emp_share_sec_change13  year, lc(purple..)) ///
	(line emp_share_sec_change11 ///
	emp_share_sec_change13  emp_share_sec_change7 year) ///
	(line  emp_share_sec_change8 emp_share_sec_change10 ///
	emp_share_sec_change12  year)
	
	

********************************************************************************
* WHICH SECTORS ARE GROWING VS. SHRINKING
********************************************************************************
use "${temp}/sectors_growth", clear
keep if sex==2 //no need for employment by sex at this point
* sort by female share at beginning of sample
bysort sector (year): carryforward initial_xtile f_share_sec0 emp_sec0, replace

gen grow=emp_share_sec_change>0

* mean initial female share by grew or shrink for each year (from beg of sample)
collapse (mean) f_share_sec0 [aw=emp_sec], by(grow year)


* mean growth by initial female shares (below/above average)
use "${temp}/sectors_growth", clear
keep if sex==2 //no need for employment by sex at this point
* sort by female share at beginning of sample
bysort sector (year): carryforward initial_xtile f_share_sec0 moref0 emp_sec0 emp_share_sec0, replace

* mean growth each year by initial female share more or less than aggregate 
collapse (mean) emp_share_sec_change (sum) emp_share_sec, by(year moref0)


twoway (line emp_share_sec year if moref0==1), ///
	ytitle("share of employment") 
graph export output/emp_share_femdom.pdf, replace


* do same but split up male and female employment
use "${temp}/sectors_growth", clear

* get share of male and female employment in each sector
gen emp_share_sex=emp/emp_sex


* sort by female share at beginning of sample
bysort sector (year): carryforward initial_xtile f_share_sec0 moref0 emp_sec0 emp_share_sec0, replace

* share of employment of each sex by sector
collapse (mean) emp_share_sec_change (sum) emp_share_sex emp, by(year sex moref0)


twoway (line emp_share_sex year if moref0==1 & sex==1, yaxis(1)) ///
	(line emp_share_sex year if moref0==1 & sex==2, yaxis(2)) , ///
	ytitle("share of employment") ///
	legend(order(1 "Male (left axis)" 2 "Female (right axis)")) ///
	ytitle("share of male employment", axis(1)) ///
	ytitle("share of female employment", axis(2))
graph export output/emp_share_sex_femdom.pdf, replace


twoway (line emp year if moref0==1 & sex==1, yaxis(1)) ///
	(line emp year if moref0==1 & sex==2, yaxis(2)) , ///
	ytitle("share of employment") ///
	legend(order(1 "Men" 2 "Women")) ///
	ytitle("share of male employment", axis(1)) ///
	ytitle("share of female employment", axis(2))

