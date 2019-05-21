clear
set more off, perm
*set maxvar 10000


gl user="rachel" //rachel or emily

if "$user"=="emily" {
	cd /Users/murpheis/Dropbox/UCB/IdentityFlows
	set scheme plotplain , permanently

	* IMPORT DATA
	use /scratch/emilyeisner/cps/CPS.dta, clear

}
if "$user"=="rachel" {
	cd "C:\Users\Rachel S\Dropbox\Research\IdentityFlows"
	grstyle init
	grstyle set plain
	grstyle set color hue, n(6)
	grstyle set legend 6, nobox

	use /scratch/users/schuhr/temp/cps2005.dta, clear

}




* DATEM VARIABLE
gen datem = 12*(year-1960) + month - 1
format datem %tm



* DEFINE BROAD INDUSTRIES
if "$user" == "rachel"  {
	gen broadInd = ""
	replace broadInd = "Farm" if ind1990 > 0 & ind1990 < 40
	replace broadInd = "Mining" if ind1990 >= 40 & ind1990 < 60
	replace broadInd = "Construction" if ind1990 == 60
	replace broadInd = "Manufacturing" if ind1990 >= 100 & ind1990 < 400
	replace broadInd = "Public Utilities" if ind1990 >= 400 & ind1990 < 500
	replace broadInd = "Wholesale Trade" if ind1990 >=500 & ind1990 < 580
	replace broadInd = "Retail Trade" if ind1990 >= 580 & ind1990 < 700
	replace broadInd = "Finance" if ind1990 >=700 & ind1990 < 721
	replace broadInd = "Business" if ind1990 >=721 & ind1990 < 761
	replace broadInd = "Personal Services" if ind1990 >=761 & ind1990 < 800
	replace broadInd = "Entertainment" if ind1990 >=800 & ind1990 < 812
	replace broadInd = "Health" if ind1990 >=812 & ind1990 < 841
	replace broadInd = "Legal" if ind1990 == 841
	replace broadInd = "Education" if ind1990 >=842 & ind1990 <= 863
	replace broadInd = "Other Professional" if ind1990 >=870 & ind1990 < 900
	replace broadInd = "Public Administration" if ind1990 >=900 & ind1990 < 940
	replace broadInd = "Military" if ind1990 >=940 & ind1990 < 998
	replace broadInd = "Unknown" if ind1990 ==998
	replace broadInd = "None" if ind1990 == 0
}



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
/*
preserve

collapse (mean) wage* , by(broadInd datem)
sort broadInd datem
levelsof broadInd, local(industries)
foreach ind of local industries {
  line wageHrly datem if broadInd == "`ind'", title("Average Hourly Wage in `ind', CPS March Supplement")
  graph export "./analyze/output/wages_`ind'.png", as(png) replace
}

restore
*/
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
