clear
set more off, perm
*set maxvar 10000


gl user="emily" //rachel or emily

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
use clean/output/CPS_1pct.dta, clear

* DATEM VARIABLE
gen datem = 12*(year-1960) + month - 1
format datem %tm

* SET AS PANEL
bysort cpsidp: gen N = _N
drop if N > 8
drop N
xtset cpsidp datem, m



* MERGE TO CPS WAGE DATA
merge m:1 year broadInd using ./clean/output/CPS_ASEC_wages.dta
keep if _m == 3 //lose military people
drop _m

* CONSTRUCT DEMOGRAPHICS OF AN INDUSTRY EACH MONTH
gen male = sex == 1
gen white = race == 100
bysort broadInd datem: egen male_ct = total(male)
bysort broadInd datem: egen white_ct = total(white)
bysort broadInd datem: gen N = _N
gen pct_white = white_ct / N
gen pct_male = male_ct / N


* INDUSTRY PARTICIPATION DUMMY VARIABLE
tab broadInd, gen(industry)

* "RESHAPE" INDUSTRY CHARACTERISTICS DATA
foreach num of numlist 1/18 {
	gen wage`num' = wageHrly_wtd if industry`num' == 1
	bysort datem: egen temp = max(wage`num')
	replace wage`num' = temp
	drop temp
	gen pct_male`num' = pct_male if industry`num'
	bysort datem: egen temp = max(pct_male`num')
	replace pct_male`num' = temp
	drop temp
	gen pct_white`num' = pct_white if industry`num'
	bysort datem: egen temp = max(pct_white`num')
	replace pct_white`num' = temp
	drop temp
	gen white_pctwhite_inter`num' = white * pct_white`num'
	gen male_pctmale_inter`num' = male * pct_male`num'
	gen white_wage_inter`num' = white * wage`num'
	gen male_wage_inter`num' = male * wage`num'
}


*==============================================================================
* WAGE TRENDS
*==============================================================================

preserve

collapse (mean) wage* , by(broadInd datem)
sort broadInd datem
levelsof broadInd, local(industries)
foreach ind of local industries {
  line wageHrly datem if broadInd == "`ind'", title("Average Hourly Wage in `ind', CPS March Supplement")
  graph export "./analyze/output/wages_`ind'.png", as(png) replace
}

restore

*==============================================================================
* REGRESSIONS
*==============================================================================

xtset cpsidp datem, m


reg industry9 wage9  white male pct_white pct_male white_pctwhite_inter9 male_pctmale_inter9, r

reg d.industry9 d.wage9  white male  L.pct_white L.pct_male L.white_pctwhite_inter9 L.male_pctmale_inter9, r
xtreg industry9 wage9  white male white_pctwhite_inter9 male_pctmale_inter9, fe r


foreach i of numlist 1/18 {

	reg d.industry`i' d.wage`i'  white male  L.pct_white L.pct_male L.white_pctwhite_inter`i' L.male_pctmale_inter`i', r
	xtreg industry`i' wage`i'  white male pct_white pct_male white_pctwhite_inter`i' male_pctmale_inter`i', fe r

	reg d.industry`i' d.wage`i'  white male  L.pct_white L.pct_male L.white_wage_inter`i' L.male_wage_inter`i', r
	xtreg industry`i' wage`i'  white male pct_white pct_male white_wage_inter`i' male_wage_inter`i', fe r

}




*
