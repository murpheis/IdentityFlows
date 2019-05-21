clear
set scheme plotplain , permanently
set more off, perm
*set maxvar 10000
set matsize 11000

gl user="rachel"

if "${user}"=="emily" {
	cd /Users/murpheis/Dropbox/UCB/IdentityFlows
}
else {
	cd "C:/Users/Rachel S/Dropbox/Research/IdentityFlows"
}


* IMPORT DATA
use analyze/output/ManufacturingMovers.dta, clear


*============================================================================*
* REGRESSIONS
*============================================================================*

preserve

* set as PANEL
xtset cpsidp t


* fix "none" category in broad Industries
replace broadInd = "Unemployed" if empstat >=20 & empstat < 30
replace broadInd = "NILF" if empstat >= 30


* categorical variables for industries
tab broadInd, gen(indCat)

* clean sex variable
drop if sex == 9
replace sex = sex - 1

* can't have factor variables that are negative in the regression...
sum t, de
gen t_reg = t - r(min)

* define "before" and "after" dummy
gen post = (t >= 0)

* label variables
label var post "post"
label var sex "sex"
label var t_reg "t"
* label values
label define sexl 0 "male" 1 "female"
label values sex sexl


* run simple regressions
levelsof broadInd, local(industries)
local i = 1
foreach ind of local industries {
  eststo clear
  *eststo: qui reg indCat`i' i.t_reg, r
  eststo: qui reg indCat`i' post, r
  eststo: qui xtreg indCat`i' post, r fe
  eststo: qui xtreg indCat`i' post##sex, r fe
  eststo: qui xtreg indCat`i' post##sex i.occ2010, r fe
  esttab using ./analyze/output/ManuMoversRegs_`i'.tex, ///
	se replace drop(*occ2010) varwidth(25) label ///
	nobaselevels interaction(" $\times$ ") style(tex) ///
	mtitles("OLS" "FE" "FE" "FE, Occ FE") title("Probability of Being in `ind'")
  local i = `i' + 1
  *esttab *, drop(i.occ2010)
}




restore

*============================================================================*
* CHARTS
*============================================================================*

* fix "none" category in broad Industries
replace broadInd = "Unemployed" if empstat >=20 & empstat < 30
replace broadInd = "NILF" if empstat >= 30


* COLLAPSE BY BROAD IND AND T
collapse (count) cpsidp , by(t broadInd sex)
bysort t sex : egen total = sum(cpsidp)
gen pct = cpsidp/total
reshape wide cpsidp pct total , i(t broadInd) j(sex)
drop *9
encode broadInd, gen(industry)
xtset industry t
tsfill
replace pct1 = 0 if mi(pct1)
replace pct2 = 0 if mi(pct2)


* CREATE STANDARD ERRORS
gen se1 = sqrt((pct1)*(1-pct1)/total1)
gen se2 = sqrt((pct2)*(1-pct2)/total2)
replace se1 = 0 if mi(se1)
replace se2 = 0 if mi(se2)
gen CI_95_1 = pct1+ 2*se1
gen CI_05_1 = pct1- 2*se1
gen CI_95_2 = pct2+ 2*se2
gen CI_05_2 = pct2- 2*se2


* LOOP OVER IDUSTRIES AND MAKE DUMB CHARTS
levelsof industry, local(inds)
foreach ind of local inds {
  binscatter pct* CI* t if industry == `ind' , line(connect) ///
      title("probability of being in industry `ind'") ///
      legend(lab(1 "Male") lab(2  "Female")) ///
      colors(blue red blue blue red red)
    graph export analyze/output/ManuSex`ind'.png, as(png) replace
}






*
