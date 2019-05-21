*****************************************************************************
* program: flowobs.do
* author: rachel schuh
* purpose: make dataset of observations of worker flows
* date: 11/25/2018
*****************************************************************************

gl server = 0 //set to 1 if on server, 0 if not

if ${server}==1 {
  gl home = "/home/users/schuhr/cps"
  gl data = "${home}/data"
  gl temp = "/scratch/users/schuhr/temp"
  gl rawdata = "/scratch/users/schuhr"
}
else {
  gl home =  "C:\Users\Rachel S\Dropbox\Research\Data\CPSMonthly"
  gl data = "${home}/data"
  gl temp = "${home}/temp"
  gl rawdata = "${home}/data"
}

cd "${home}"


* import industry employment data
import delimited using "${data}/indemp.csv", clear
ren ind1990 ind1990_string
ren ym ym_string
save "${data}/indemp", replace


* import industry female shares data
import delimited using "${data}/indfshares.csv", clear
keep ind1990 ym fshare
ren ind1990 ind1990_string
ren ym ym_string
save "${data}/indfshares", replace



* get flow data
use "${data}/sample2010" if year==2010, clear


* sample selection
keep if age>=16
keep if inrange(mis,1,2)

* drop unnecessary vars
drop dw* jt*

* set panel
gen ym=ym(year,month)
format ym %tm
tsset cpsidp ym
sort cpsidp ym


* working 
keep if inlist(empstat,10,12)

* present for two months
bysort cpsidp: egen num=count(ym)
keep if num==2


* switches industry from month 1 to 2
gen indswitch= 1 if (ind1990!=F.ind1990 & mish==1)
bysort cpsidp (ym): carryforward indswitch, replace

* keep people who switch industry
keep if indswitch==1


* merge with data on industry sex composition

* need variable label with value label from industry
decode ind1990, gen(ind1990_string)
gen ym_string = string(ym, "%tm")


* merge with industry employment
merge m:1 ind1990_string ym_string using "${data}/indemp" , ///
	gen(merge_emp) keep(match master)

* merge with industry f shares
merge m:1 ind1990_string ym_string using "${data}/indfshares", ///
	gen(merge_fshares)
	

	
* SOME UNMATCHED - NEED TO GO BACK TO FIX!! ALSO CREATE LAGGED FEMALE SHARES!
drop if merge_fshares!=3

keep cpsidp mish ym year month ind1990 occ2010 age sex fshare educ ///
	empstat indstock indswitch
reshape wide ind1990 occ2010 age sex fshare month educ ///
	empstat indstock year ym, i(cpsidp) j(mish)



* try a regression
areg fshare2 fshare1 i.sex1 i.sex1#c.fshare1 indstock1 i.educ1 i.age1, a(occ20101)




