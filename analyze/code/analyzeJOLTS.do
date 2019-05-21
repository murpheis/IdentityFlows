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


* IMPORT
use ./clean/output/jolts.dta, clear


* keep only industry-specific
drop if industry == "000000"

* keep only levels
keep if ratelevel == "L"


* keep only seasonally adjusted
keep if seasonal == "S"








*
