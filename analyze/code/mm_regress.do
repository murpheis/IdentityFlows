*Emily's code for manufacturing movements with slight edits from rachel
* edits to graph labels and change to sector groupings from rachel's other code
* (probably worse grouping but makes smaller number of charts)

clear

set more off, perm
*set maxvar 10000

gl user="rachel" //rachel or emily

if "$user"=="emily" {
	cd /Users/murpheis/Dropbox/UCB/IdentityFlows
	set scheme plotplain , permanently
}
if "$user"=="rachel" {
	cd "C:\Users\Rachel S\Dropbox\Research\IdentityFlows"
	grstyle init
	grstyle set plain
	grstyle set color hue, n(6)
	grstyle set legend 6, nobox
}

* IMPORT DATA
use analyze/output/ManufacturingMovers.dta, clear

* RACHEL'S SECTORS (COLLAPSES PROFESSIONAL AND RELATED SERVICES TOGETHER WHICH IS DUMB ACTUALLY BUT WHATEVER FOR NOW)
gen sector=0
		*  AGRICULTURE, FORESTRY, AND FISHERIES
		replace sector = 1 if inrange(ind1990, 10,32)
		* MINING 
		replace sector = 2 if inrange(ind1990,40,50)
		* CONSTRUCTION
		replace sector = 3  if inrange(ind1990,60,60)
		* MANUFACTURING
		replace sector = 4 if inrange(ind1990,100,392)
		* TRANSPORTATION, COMMUNICATIONS, AND OTHER PUBLIC UTILITIES
		replace sector = 5 if inrange(ind1990,400,472)
		* WHOLESALE TRADE
		replace sector = 6 if inrange(ind1990,500,571)
		* RETAIL TRADE
		replace sector = 7 if inrange(ind1990,580,691)
		* FINANCE, INSURANCE, AND REAL ESTATE
		replace sector = 8 if inrange(ind1990,700,712)
		* BUSINESS AND REPAIR SERVICES
		replace sector = 9 if inrange(ind1990,721,760)
		* PERSONAL SERVICES
		replace sector = 10 if inrange(ind1990,761,791)
		* ENTERTAINMENT AND RECREATION SERVICES
		replace sector = 11 if inrange(ind1990,800,810)
		* PROFESSIONAL AND RELATED SERVICES (INCLUDES EDUCATION AND HEALTH)
		replace sector = 12 if inrange(ind1990,812,893)
		* PUBLIC ADMINISTRATION
		replace sector = 13 if inrange(ind1990,900,932)
		* ACTIVE DUTY MILITARY
		replace sector = 14 if inrange(ind1990,940,960)
		* only left with 0 (NIU) and 998 (Unknown) for 0
		
		label define sectorl 1 "Agriculture, forestry, and fisheries" ///
		2 "Mining" 3 "Construction" 4 "Manufacturing" ///
		5 "Transportation, communications, and other public utilities" ///
		6 "Wholesale trade" 7 "Retail trade" 8 "Finance, insurance, and real estate" ///
		9 "Business and repair services" 10 "Personal services" 11 "Entertainment and recreation services" ///
		12 "Professional and related services" 13 "Public administration" ///
		14 "Active duty military" 0 "NIU/Unknown" -1 "Unemployed" -2 "NILF"
		label values sector sectorl

gen lfs = "_" 
			* EMPLOYED: at work (10) or has job, not at work last week (12)
			replace lfs = "E" if inlist(empstat,10,12)
			* UNEMPLOYED: unemployed (20), u experienced worker (21) or u, new worker (22)
			replace lfs = "U" if inlist(empstat,20,21,22)
			* NILF: N (30), N housewk (31), N unable to work (32); N other (34); N unpaid lt 15 (35); NILF, retired (36)
			replace lfs = "N" if inlist(empstat,30,31,32,34,35,36)
		
		
replace sector=-1 if lfs=="U" //-1 for unemployed
replace sector=-2 if lfs=="N" //-2 for NILF

* COLLAPSE BY BROAD IND AND T
* rachel - should probably use weights somehow but unclear if it is ok to aggregate them across time
collapse (count) cpsidp (sum) wtfinl , by(t sector sex year)


*merge with my female share counts and sector growth
merge m:1 year sector sex using analyze/temp/sectors_growth
* with counts
bysort t sex : egen total = sum(cpsidp)
gen pct = cpsidp/total
* with weights
bysort t sex: egen totalw=sum(wtfinl)
gen pctw=wtfinl/totalw


ren wtfinl countw
ren cpsidp count

replace sector=0 if inrange(sector,-2,-1)

* try some random regressions
reg pct f_share_sec0 emp_share_sec i.year if sex==1 & t==0
reg pctw f_share_sec0 emp_share_sec i.year if sex==1 & t==0


*
