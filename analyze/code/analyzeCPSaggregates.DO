
set scheme plotplain , permanently
set more off, perm
clear


cd /Users/murpheis/Dropbox/UCB/IdentityFlows

* IMPORT DATA
use ./clean/output/aggregatedCPS.dta, clear


* CONVERT DATES
gen datem = 12*(year - 1960) + month -1
format datem %tm

* DEFINE BROAD INDUSTRIES
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
replace broadInd = "Military" if ind1990 >=940
replace broadInd = "None" if broadInd == ""



* ====== TIME SERIES FOR GENDER ===================================*
preserve

* AGGREGATE TO GENDER and BROAD INDUSTRY
collapse (sum) cpsidp , by(sex year month broadInd datem)


* reshape so gender is wide
reshape wide cpsidp, i(datem broadInd) j(sex)

* get total workforce and pcts
gen temp1 = cpsidp1 if broadInd ~= "None"
gen temp2 = cpsidp2 if broadInd ~= "None"
bysort datem: egen totworkforce1 = total(temp1)
bysort datem: egen totworkforce2 = total(temp2)
gen totworkforceInd = cpsidp1 + cpsidp2
gen pct_emp1 = cpsidp1/totworkforce1
gen pct_emp2 = cpsidp2/totworkforce2
gen pctInd1 = cpsidp1/totworkforceInd
gen pctInd2 = cpsidp2/totworkforceInd


* BY BROAD CATEGORY, MAKE CHARTS
label var pct_emp1 "Males"
label var pct_emp2 "Females"
levelsof broadInd, local(inds)
foreach ind of local inds {
  line pct_emp* datem if broadInd == "`ind'", ///
    title("Fraction Total Males/Females Employed in `ind'") ///
    caption("Source: CPS")
    graph export  "./analyze/output/trend_sex_`ind'.png", as(png) replace
}
label var pctInd1 "Males"
label var pctInd2 "Females"
levelsof broadInd, local(inds)
foreach ind of local inds {
  line pctInd* datem if broadInd == "`ind'", ///
    title("Fraction Total People Employed in `ind' by Gender") ///
    caption("Source: CPS")
    graph export  "./analyze/output/trend_sex_`ind'_industryComp.png", as(png) replace
}
label var cpsidp1 "Males"
label var cpsidp2 "Females"
levelsof broadInd, local(inds)
foreach ind of local inds {
  line cpsidp* datem if broadInd == "`ind'", ///
    title("Total People Employed in `ind' by Gender") ///
    caption("Source: CPS")
    graph export  "./analyze/output/trend_sex_`ind'_industryTot.png", as(png) replace
}
restore


* ====== TIME SERIES FOR RACE ===================================*
preserve

* AGGREGATE TO RACE and BROAD INDUSTRY
collapse (sum) cpsidp , by(race year month broadInd datem)


* reduce to largest races (arbitrary cutoff...should reexamine)
 keep if race <= 700

* reshape so race is wide
reshape wide cpsidp, i(datem broadInd) j(race)

local i = 0
foreach var of varlist cpsidp* {
gen temp`i' = `var' if broadInd ~= "None"
local i = `i' + 1
}

egen totworkforceInd = rowtotal(cpsidp*)
local i = 0
foreach var of varlist cpsidp* {
bysort datem: egen totworkforce`i' = total(temp`i')
gen pct_emp`i' =  `var' / totworkforce`i'
gen pct_ind`i' = `var'/totworkforceInd
local i = `i' + 1
}

* BY BROAD CATEGORY, MAKE CHARTS
levelsof broadInd, local(inds)
foreach ind of local inds {
  line pct_emp* datem if broadInd == "`ind'", ///
    title("Fraction Total Males/Fenales Employed in `ind'") ///
    caption("Source: CPS")
    graph export  "./analyze/output/trend_RACE_`ind'.png", as(png) replace
}
label var pctInd1 "Males"
label var pctInd2 "Females"
levelsof broadInd, local(inds)s
foreach ind of local inds {
  line pctInd* datem if broadInd == "`ind'", ///
    title("Fraction Total People Employed in `ind' by Gender") ///
    caption("Source: CPS")
    graph export  "./analyze/output/trend_sex_`ind'_industryComp.png", as(png) replace
}
label var cpsidp1 "Males"
label var cpsidp2 "Females"
levelsof broadInd, local(inds)
foreach ind of local inds {
  line cpsidp* datem if broadInd == "`ind'", ///
    title("Total People Employed in `ind' by Gender") ///
    caption("Source: CPS")
    graph export  "./analyze/output/trend_sex_`ind'_industryTot.png", as(png) replace
}






*
