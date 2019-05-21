*****************************************************************************
* program: stocks.do
* author: rachel schuh
* purpose: create stock files from monthly data.
* date: 11/25/2018
*****************************************************************************

gl server = 1 //set to 1 if on server, 0 if not
set max_memory 32g

if ${server}==1 {
  gl home = "/home/users/schuhr/cps"
  gl data = "${home}/data"
  gl temp = "/scratch/users/schuhr/temp"
  gl rawdata = ""
}
else {
  gl home =  "C:\Users\Rachel S\Dropbox\Research\Data\CPSMonthly"
  gl data = "${home}/data"
  gl temp = "${home}/temp"
  gl rawdata = "${home}/data"
}

cd /scratch/users/schuhr


clear

*** STEP 0: Select variables to collapse on
gl wt = "wtfinl"
*OTHER POSSIBILITIES: panlwt, LNKFW1MWT

* Possibilities: NONE, sector, sex
gl stockvar1 = "ind1990"
gl stockvar2 = "sex"
gl stockvar3 = "NONE1"
gl stockvar4 = "NONE2"

gl lfstat = "3state"
/* Options: 
	3state: E, U, N
	j2j: E, U, N + EE' (starts in 1994!)
*/

*STOP and START years: intervals of five. will go to end year + 5
gl ystart=1975 // start year
gl yend=2015 //stop year 


pwd

*** STEP 1: Collapse to get flows by file
forv y=$ystart(5)$yend {
   *cd ${temp}
   use "${temp}/cps`y'.dta", clear
   *use cps`y', clear

   local y1 = `y'+5

   gen NONE1= 1
   gen NONE2 = 1
   
   *STANDARD SAMPLE RESTRICTIONS
   keep if inrange(age,16,99)
   
   
	*RECODE LABOR FORCE STATUS
	if "${lfstat}"=="3state" {
			gen lfs = "_" 
			* EMPLOYED: at work (10) or has job, not at work last week (12)
			replace lfs = "E" if inlist(empstat,10,12)
			* UNEMPLOYED: unemployed (20), u experienced worker (21) or u, new worker (22)
			replace lfs = "U" if inlist(empstat,20,21,22)
			* NILF: N (30), N housewk (31), N unable to work (32); N other (34); N unpaid lt 15 (35); NILF, retired (36)
			replace lfs = "N" if inlist(empstat,30,31,32,34,35,36)
	}
	
	
	if "${stockvar1}"=="sector" | "${stockvar2}"=="sector" {
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
		14 "Active duty military" 0 "NIU/Unknown"
		label values sector sectorl
	}

	if "${stockvar1}"=="broadInd" | "${stockvar2}"=="broadInd" {
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

	}

if "${stockvar1}"=="edu" | "${stockvar2}"=="edu" | "${stockvar3}"=="edu" | "${stockvar4}"=="edu" {
			gen edu = ""
		* less than hs or hs
		replace edu="HS" if inrange(educ,2,73)
		* some college	
		replace edu="SC" if inrange(educ,80,110)
		* BA
		replace edu="BA" if inrange(educ,111,122)
		* graduate degree
		replace edu="GR" if inrange(educ,123,125)
		}
	
	

	
	
	

	
   *COLLAPSE to get count of flows for each date by desired flow variables
   * date is SECOND month, so flows count inflows
   collapse (sum) ${wt}, by(${stockvar1} ${stockvar2} ${stockvar3} ${stockvar4}  lfs year month)
   
   gen ym=ym(year,month)
   format ym %tm
   *gen type=lfs
   gen stock=${wt}
   
   keep ym lfs stock ${stockvar1} ${stockvar2} ${stockvar3} ${stockvar4}
   
   save "${temp}/stock`y'", replace
   
   
   
}


*** STEP 2: Append data files
clear
forv y=$ystart(5)$yend {
  append using "${temp}/stock`y'"

   
}
cd "${data}"


saveold "${data}/stocks_${lfstat}_${stockvar1}_${stockvar2}_${stockvar3}_${stockvar4}", replace version(12)
export delimited using "${data}/stocks_${lfstat}_${stockvar1}_${stockvar2}_${stockvar3}_${stockvar4}.csv", replace
