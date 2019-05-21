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
import delimited ./clean/input/JOLTS/JobOpenings_JOLTS.rtf, delim("\t") clear
gen n = _n
rename v1 series_id
rename v2 year
rename v3 period
rename v4 value
rename v5 footnote_codes
drop if n < 9


* reformat dates
destring year, replace
gen month = subinstr(period,"M","",1)
destring month, replace
gen datem = 12*(year - 1960) + month - 1
format datem %tm
drop if mi(datem)


* destring values
destring value, replace


* break down series IDs
gen seasonal = substr(series_id,3,1)
gen industry = substr(series_id,4,6)
gen region = substr(series_id,10,2)
gen dataelement = substr(series_id,12,2)
gen ratelevel = substr(series_id,14,1)


* save data
save ./clean/output/jolts.dta, replace


/*
* industry descriptions
gen industry_name = ""
replace industry_name = "total" if industry ==  "000000"
100000	Total private
110099	Mining and logging
230000	Construction
300000	Manufacturing
320000	Durable goods manufacturing
340000	Nondurable goods manufacturing
400000	Trade, transportation, and utilities	2
420000	Wholesale trade
440000	Retail trade
480099	Transportation, warehousing, and utilities
510000	Information
510099	Financial activities
520000	Finance and insurance
530000	Real estate and rental and leasing	3	T	15
540099	Professional and business services	2	T	16
600000	Education and health services	2	T	17
610000	Educational services	3	T	18
620000	Health care and social assistance	3	T	19
700000	Leisure and hospitality	2	T	20
710000	Arts, entertainment, and recreation	3	T	21
720000	Accommodation and food services	3	T	22
810000	Other services	2	T	23
900000	Government	1	T	24
910000	Federal	2	T	25
920000	State and local	2	T	26
923000	State and local government education	3	T	27
929000	State and local government, excluding education	3	T	28






*
