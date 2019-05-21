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
import delimited ./clean/input/CESearnings/CES_All_Earnings.rtf, delim("\t") clear
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
gen industry = substr(series_id,4,8)
gen sector = substr(industry,1,2)
gen naics = substr(industry,3,5)
gen datatype = substr(series_id,12,2)


* keep only total supersectors
keep if naics == "00000"

* keep only seasonally adjusted data
keep if seasonal == "S"

* reformat
keep datem value sector datatype
reshape wide value, i(sector datem) j(datatype) string
rename value12 earningsWkly
rename value13 eaningsHrly

* save
save ./clean/output/CESsectorEarnings.dta, replace


/*
datatypes:
12	AVERAGE WEEKLY EARNINGS OF ALL EMPLOYEES, 1982-1984 DOLLARS
13	AVERAGE HOURLY EARNINGS OF ALL EMPLOYEES, 1982-1984 DOLLARS

supersector_code	supersector_name
00	Total nonfarm
05	Total private
06	Goods-producing
07	Service-providing
08	Private service-providing
10	Mining and logging
20	Construction
30	Manufacturing
31	Durable Goods
32	Nondurable Goods
40	Trade, transportation, and utilities
41	Wholesale trade
42	Retail trade
43	Transportation and warehousing
44	Utilities
50	Information
55	Financial activities
60	Professional and business services
65	Education and health services
70	Leisure and hospitality
80	Other services
90	Government




*
