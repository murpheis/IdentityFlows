*****************************************************************************
* program: sex_sector_shares.do
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


use "${data}/stocks_3state_sector_sex", clear

sort ym type sector sex
ren type lfs
duplicates drop
drop if sector==0 | sector==14

* collapse everything to annual to get rid of seasonality
gen date=dofm(ym)
gen year=year(date)
collapse (mean) stock, by(year sex sector lfs)
reshape wide stock, i(year sex sector) j(lfs) s

* get total sector employment each month
drop stockN stockU stock_
ren stockE emp
bysort sector year: egen emp_sec=total(emp)


* get total employment each month
bysort year: egen emp_tot=total(emp)


* get gender breakdown of total employment each year
bysort sex year: egen emp_sex=total(emp)
gen f_share_tot=emp_sex/emp_tot if sex==2
gen negsex=-sex
bysort year  sector (negsex): carryforward f_share_tot, replace back

* get gender breakdown of sectoral employment each year
gen f_share_sec=emp/emp_sec if sex==2
bysort year  sector (negsex): carryforward f_share_sec, replace back


* calculate gender breakdown of sector RELATIVE to aggregate employment
gen f_share_diff=f_share_sec-f_share_tot

*share of total employment in each sector
gen emp_share_sec=emp_sec/emp_tot

xtile initial_xtile=f_share_sec if year==1976, nq(4)
gen f_share_sec0=f_share_sec if year==1976
gen moref0=f_share_sec>f_share_tot if year==1976
gen emp_sec0=emp_sec if year==1976
gen emp_share_sec0=emp_share_sec if year==1976
bysort sector (year): carryforward initial_xtile f_share_sec0 moref0 emp_sec0 emp_share_sec0, replace


save "${data}/f_shares_sector", replace


* sort sectors by employment growth - for each decade and each recession, absolute and fraction
use "${data}/f_shares_sector", clear

*first, growth over ten year periods
recode year (1976/1985=1) (1986/1995=2) (1996/2005=3) (2006/2018=4), gen(decade)
gen lastyear=0
replace lastyear=1 if inlist(year,1985,1995,2005,2018)
gen emp_sec_final=emp_sec if lastyear==1
gen emp_share_sec_final=emp_share_sec if lastyear==1
gen negyear=-year
bysort sector (negyear): carryforward emp_sec_final emp_share_sec_final, back replace
gen emp_sec_change=emp_sec_final-emp_sec
gen emp_share_sec_change=emp_share_sec_final-emp_share_sec

* for each decade, quantify which sectors are growing the fastest and slowest
forv y=1976(10)2006 {
	xtile dlevelq`y'=emp_sec_change if year==`y', nq(4)
	xtile dshareq`y'=emp_share_sec_change if year==`y', nq(4)
}



*scatterplots - emp_share_sec_change on f_share_diff for each base year
save "${data}/sectors_decades", replace

* do the same with recession/recoveries
use "${data}/f_shares_sector", clear

merge m:1 year using "${data}/recession_years"
bysort sector (year): carryforward recession recovery, replace

*growth in each recovery
egen serid=group(sector sex)
tsset serid year
* record end of recovery
gen recoveryend=0
replace recoveryend=1 if recovery!=0 & f.recovery==0
replace recoveryend=1 if year==2018 //last year of data, still in recovery
* calculate growth from first to last of recovery
gen emp_sec_final=emp_sec if recoveryend==1
gen emp_share_sec_final=emp_share_sec if recoveryend==1
gen negyear=-year
bysort sector (negyear): carryforward emp_sec_final emp_share_sec_final, back replace
sort serid year
gen emp_sec_change=emp_sec_final-emp_sec if recovery!=0
gen emp_sec_change_pct=(emp_sec_final-emp_sec)/emp_sec if recovery!=0
gen emp_share_sec_change=emp_share_sec_final-emp_share_sec if recovery!=0

* calculate growth starting at beginning of recovery
gen recoverystart=0
replace recoverystart=1 if recovery!=0 & L.recovery==0
replace recoverystart=1 if year==1976
* record employment and employment shares at start of recovery
gen emp_sec_start=emp_sec if recoverystart==1
gen emp_share_sec_start=emp_share_sec if recoverystart==1
bysort sector (year): carryforward emp_sec_start emp_share_sec_start, replace
sort serid year
*record cumulative changes from initial employment by month
gen emp_sec_change_s=emp_sec-emp_sec_start if recovery!=0
gen emp_sec_change_pct_s=(emp_sec-emp_sec_start)/emp_sec if recovery!=0
gen emp_share_sec_change_s=emp_share_sec-emp_share_sec_start if recovery!=0

*save
save "${temp}/sectors_recoveries", replace

* do the same with the entire sample
use "${data}/f_shares_sector", clear


*growth in entire sample
egen serid=group(sector sex)
tsset serid year
* record employment and employment shares at start of recovery
gen emp_sec_start=emp_sec if year==1976
gen emp_share_sec_start=emp_share_sec if year==1976
bysort sector (year): carryforward emp_sec_start emp_share_sec_start, replace
sort serid year
*record cumulative changes from initial employment by month
gen emp_sec_change=emp_sec-emp_sec_start
gen emp_sec_change_pct=(emp_sec-emp_sec_start)/emp_sec
gen emp_share_sec_change=emp_share_sec-emp_share_sec_start

*save
save "${temp}/sectors_growth", replace

/* want to see if sectors that are growing are more female dominated.
calculate growth in each sector in ABSOLUTE and SHARES of employment 
for each
-decade
-recovery
then need to figure out how to match this with relative female employment */
