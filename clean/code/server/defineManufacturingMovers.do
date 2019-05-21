* THIS CODE WAS WRITTEN BY EMILY AND DEFINES THE MANUFACTURING MOVERS DATASET


clear
*set scheme plotplain , permanently
set more off, perm
set maxvar 10000
*cd /Users/murpheis/Dropbox/UCB/IdentityFlows


* IMPORT DATA
use "/scratch/public/murpheis/CPS/output/CPS.dta", clear

* DATEM VARIABLE
gen datem = 12*(year-1960) + month - 1
format datem %tm


* SET AS PANEL
bysort cpsidp: gen N = _N
drop if N > 8
drop N
xtset cpsidp datem, m

* LOOK AT IF SOMEONE CHANGES OUT OF MANUFACTURING
gen manu = broadInd == "Manufacturing"
gen Lmanu = L.manu
gen outManu = Lmanu==1 & manu==0
bysort cpsidp: egen outManuEver = max(outManu)

* LOOK ONLY AT PEOPLE WHO LEAVE MANUFACTURING
keep if outManuEver


* DEFINE TIME THAT THEY SWITCH AS t=0
bysort cpsidp (datem): gen t = _n
gen timeOut = t if outManu
bysort cpsidp (datem): egen temp = max(timeOut)
replace t = t - temp

* KEEP ONLY IF HAVE 3 MONTHS IN MANUFACTURING
gen manuPre = manu * ( t < 0)
bysort cpsidp: egen manuPreTot = total(manuPre)
keep if manuPreTot >=3

/*
* SET AS PANEL
bysort cpsidp: gen N = _N
drop if N > 8
drop N
bysort cpsidp (datem): gen t = _n
xtset cpsidp t

* LOOK AT IF SOMEONE CHANGES OUT OF MANUFACTURING
gen manu = broadInd == "Manufacturing"
gen Lmanu = L.manu
gen outManu = Lmanu==1 & manu==0

* KEEP ONLY THOSE WHO LEAVE EXACTLY ONCE (HOW MANY ARE FLIPPING?)
bysort cpsidp: egen outManuEver = sum(outManu)
tab outManuEver
keep if outManuEver == 1

* DEFINE TIME THAT THEY SWITCH AS t=0
gen timeOut = datem if outManu
bysort cpsidp (datem): egen temp = max(timeOut)
replace t = datem - temp

* KEEP ONLY IF HAVE 3 MONTHS IN MANUFACTURING
gen manuPre = manu * ( t < 0)
bysort cpsidp: egen manuPreTot = sum(manuPre)
keep if manuPreTot >=3
*/

* OUTPUT AS STATA FILE
saveold "/scratch/public/murpheis/CPS/output/ManufacturingMovers.dta", replace

* COLLAPSE BY TIME RELATIVE TO LEAVING MANUFACTURING AND SEX
collapse (count) cpsidp, by(t broadInd sex)

* OUTPUT AS STATA FILE
saveold "/scratch/public/murpheis/CPS/output/ManuMoveCollapsed.dta", replace
