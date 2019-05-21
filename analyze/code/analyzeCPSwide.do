clear
set scheme plotplain , permanently
set more off, perm
*set maxvar 10000

cd /Users/murpheis/Dropbox/UCB/IdentityFlows


* IMPORT DATA
use clean/output/CPSwide_1pct.dta, clear


local i = 1
* DEFINE BROAD INDUSTRIES (GET RID OF STEP AFTER RE-CLEAN)
foreach var of varlist ind1990* {
  gen broadInd`i' = ""
  replace broadInd`i' = "Farm" if ind1990`i' > 0 & ind1990`i' < 40
  replace broadInd`i' = "Mining" if ind1990`i' >= 40 & ind1990`i' < 60
  replace broadInd`i' = "Construction" if ind1990`i' == 60
  replace broadInd`i' = "Manufacturing" if ind1990`i' >= 100 & ind1990`i' < 400
  replace broadInd`i' = "Public Utilities" if ind1990`i' >= 400 & ind1990`i' < 500
  replace broadInd`i' = "Wholesale Trade" if ind1990`i' >=500 & ind1990`i' < 580
  replace broadInd`i' = "Retail Trade" if ind1990`i' >= 580 & ind1990`i' < 700
  replace broadInd`i' = "Finance" if ind1990`i' >=700 & ind1990`i' < 721
  replace broadInd`i' = "Business" if ind1990`i' >=721 & ind1990`i' < 761
  replace broadInd`i' = "Personal Services" if ind1990`i' >=761 & ind1990`i' < 800
  replace broadInd`i' = "Entertainment" if ind1990`i' >=800 & ind1990`i' < 812
  replace broadInd`i' = "Health" if ind1990`i' >=812 & ind1990`i' < 841
  replace broadInd`i' = "Legal" if ind1990`i' == 841
  replace broadInd`i' = "Education" if ind1990`i' >=842 & ind1990`i' <= 863
  replace broadInd`i' = "Other Professional" if ind1990`i' >=870 & ind1990`i' < 900
  replace broadInd`i' = "Public Administration" if ind1990`i' >=900 & ind1990`i' < 940
  replace broadInd`i' = "Military" if ind1990`i' >=940 & ind1990`i' < 998
  replace broadInd`i' = "Unknown" if ind1990`i' ==998
  replace broadInd`i' = "None" if ind1990`i' == 0
  local i = `i' + 1
}

* IDENTIFY PEOPLE WHO LEAVE MANUFACTURING
foreach var of varlist broadInd* {

}




*
