set more off

clear
quietly infix              ///
  int     year      1-4    ///
  byte    month     5-6    ///
  byte    region    7-8    ///
  double  wtfinl    9-22   ///
  double  cpsidp    23-36  ///
  int     relate    37-40  ///
  byte    age       41-42  ///
  byte    sex       43-43  ///
  int     race      44-46  ///
  byte    marst     47-47  ///
  byte    empstat   48-49  ///
  int     occ       50-53  ///
  int     occ1990   54-56  ///
  int     ind1990   57-59  ///
  int     ind       60-63  ///
  int     durunemp  64-66  ///
  byte    wkstat    67-68  ///
  using `"/accounts/grad/emily.eisner/Documents/CPS/data/cps_00006.dat"'

replace wtfinl   = wtfinl   / 10000

format wtfinl   %14.4f
format cpsidp   %14.0f

* drop people who are not working age
drop if age < 18  | age > 65

* OUTPUT AS STATA FILE
saveold "/accounts/grad/emily.eisner/Documents/CPS/output/CPS.dta"



* RESHAPE SO THAT THERE'S ONE OB PER INDIVIDUAL
keep year month region wtfinl cpsidp age sex race marst empstat occ1990 ind1990 durunemp wkstat
bysort cpsidp (year) (month): gen n = _n
reshape



* COLLAPSE TO THINGS I WANT
collapse (count) cpsid , by(year month occ1990 sex race ind1990)


* EXPORT
saveold "/accounts/grad/emily.eisner/Documents/CPS/output/aggregatedCPS.dta"
