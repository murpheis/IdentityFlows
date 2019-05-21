clear
set more off, perm
*set maxvar 10000



gl user="emily" //rachel or emily

if "$user"=="emily" {
	cd /Users/murpheis/Dropbox/UCB/IdentityFlows
	set scheme plotplain , permanently
  gl datafolder = "/Volumes/My Passport for Mac/data/cps"
}
if "$user"=="rachel" {
	cd "C:\Users\Rachel S\Dropbox\Research\IdentityFlows"
	grstyle init
	grstyle set plain
	grstyle set color hue, n(6)
	grstyle set legend 6, nobox
}


clear
quietly infix                  ///
  int     year        1-4      ///
  long    serial      5-9      ///
  byte    month       10-11    ///
  double  cpsid       12-25    ///
  byte    asecflag    26-26    ///
  byte    hflag       27-27    ///
  double  asecwth     28-37    ///
  byte    pernum      38-39    ///
  double  cpsidp      40-53    ///
  double  asecwt      54-63    ///
  int     occly       64-67    ///
  int     occ50ly     68-70    ///
  int     indly       71-74    ///
  int     ind50ly     75-77    ///
  int     occ90ly     78-80    ///
  int     ind90ly     81-83    ///
  int     occ10ly     84-87    ///
  byte    wkswork1    88-89    ///
  int     uhrsworkly  90-92    ///
  double  ftotval     93-102   ///
  double  inctot      103-110  ///
  long    incwage     111-117  ///
  long    incbus      118-124  ///
  long    incfarm     125-131  ///
  using "$datafolder/cps_00007.dat"

replace asecwth    = asecwth    / 10000
replace asecwt     = asecwt     / 10000

format cpsid      %14.0g
format asecwth    %10.4f
format cpsidp     %14.0g
format asecwt     %10.4f
format ftotval    %10.0g
format inctot     %8.0g

label var year       `"Survey year"'
label var serial     `"Household serial number"'
label var month      `"Month"'
label var cpsid      `"CPSID, household record"'
label var asecflag   `"Flag for ASEC"'
label var hflag      `"Flag for the 3/8 file 2014"'
label var asecwth    `"Annual Social and Economic Supplement Household weight"'
label var pernum     `"Person number in sample unit"'
label var cpsidp     `"CPSID, person record"'
label var asecwt     `"Annual Social and Economic Supplement Weight"'
label var occly      `"Occupation last year"'
label var occ50ly    `"Occupation last year, 1950 basis"'
label var indly      `"Industry last year"'
label var ind50ly    `"Industry last year, 1950 basis"'
label var occ90ly    `"Occupation last year, 1990 basis"'
label var ind90ly    `"Industry last year, 1990 basis"'
label var occ10ly    `"Occupation, 2010 basis"'
label var wkswork1   `"Weeks worked last year"'
label var uhrsworkly `"Usual hours worked per week (last yr)"'
label var ftotval    `"Total family income"'
label var inctot     `"Total personal income"'
label var incwage    `"Wage and salary income"'
label var incbus     `"Non-farm business income"'
label var incfarm    `"Farm income"'




* DEFINE BROAD INDUSTRIES
gen broadInd = ""
replace broadInd = "Farm" if ind90ly > 0 & ind90ly < 40
replace broadInd = "Mining" if ind90ly >= 40 & ind90ly < 60
replace broadInd = "Construction" if ind90ly == 60
replace broadInd = "Manufacturing" if ind90ly >= 100 & ind90ly < 400
replace broadInd = "Public Utilities" if ind90ly >= 400 & ind90ly < 500
replace broadInd = "Wholesale Trade" if ind90ly >=500 & ind90ly < 580
replace broadInd = "Retail Trade" if ind90ly >= 580 & ind90ly < 700
replace broadInd = "Finance" if ind90ly >=700 & ind90ly < 721
replace broadInd = "Business" if ind90ly >=721 & ind90ly < 761
replace broadInd = "Personal Services" if ind90ly >=761 & ind90ly < 800
replace broadInd = "Entertainment" if ind90ly >=800 & ind90ly < 812
replace broadInd = "Health" if ind90ly >=812 & ind90ly < 841
replace broadInd = "Legal" if ind90ly == 841
replace broadInd = "Education" if ind90ly >=842 & ind90ly <= 863
replace broadInd = "Other Professional" if ind90ly >=870 & ind90ly < 900
replace broadInd = "Public Administration" if ind90ly >=900 & ind90ly < 940
replace broadInd = "Military" if ind90ly >=940 & ind90ly < 998
replace broadInd = "Unknown" if ind90ly ==998
replace broadInd = "None" if ind90ly == 0


* DEFINE HRLY WAGES
gen wageHrly = incwage / (wkswork1 * uhrsworkly)

* DEFINE WEEKLY WAGES
gen wageWkly = incwage / wkswork1


* collapse USING WEIGHTS
foreach var of varlist wage* inc* {
  gen `var'_wtd = `var' * asecwt
}
collapse (sum) wage* inc* asecwt (count) ct = wageHrly , by(year broadInd)
foreach var of varlist *_wtd {
  replace `var' = `var' / asecwt
}

* keep only weighted stuff
keep year broadInd *wtd


* save
save ./clean/output/CPS_ASEC_wages.dta, replace


/*
label define month_lbl 01 `"January"'
label define month_lbl 02 `"February"', add
label define month_lbl 03 `"March"', add
label define month_lbl 04 `"April"', add
label define month_lbl 05 `"May"', add
label define month_lbl 06 `"June"', add
label define month_lbl 07 `"July"', add
label define month_lbl 08 `"August"', add
label define month_lbl 09 `"September"', add
label define month_lbl 10 `"October"', add
label define month_lbl 11 `"November"', add
label define month_lbl 12 `"December"', add
label values month month_lbl

label define asecflag_lbl 1 `"ASEC"'
label define asecflag_lbl 2 `"March Basic"', add
label values asecflag asecflag_lbl

label define hflag_lbl 0 `"5/8 file"'
label define hflag_lbl 1 `"3/8 file"', add
label values hflag hflag_lbl

label define occ50ly_lbl 000 `"Accountants and auditors"'
label define occ50ly_lbl 001 `"Actors and actresses"', add
label define occ50ly_lbl 002 `"Airplane pilots and navigators"', add
label define occ50ly_lbl 003 `"Architects"', add
label define occ50ly_lbl 004 `"Artists and art teachers"', add
label define occ50ly_lbl 005 `"Athletes"', add
label define occ50ly_lbl 006 `"Authors"', add
label define occ50ly_lbl 007 `"Chemists"', add
label define occ50ly_lbl 008 `"Chiropractors"', add
label define occ50ly_lbl 009 `"Clergymen"', add
label define occ50ly_lbl 010 `"College presidents and deans"', add
label define occ50ly_lbl 012 `"Agricultural sciences"', add
label define occ50ly_lbl 013 `"Biological sciences"', add
label define occ50ly_lbl 014 `"Chemistry"', add
label define occ50ly_lbl 015 `"Economics"', add
label define occ50ly_lbl 016 `"Engineering"', add
label define occ50ly_lbl 017 `"Geology and geophysics"', add
label define occ50ly_lbl 018 `"Mathematics"', add
label define occ50ly_lbl 019 `"Medical sciences"', add
label define occ50ly_lbl 023 `"Physics"', add
label define occ50ly_lbl 024 `"Psychology"', add
label define occ50ly_lbl 025 `"Statistics"', add
label define occ50ly_lbl 026 `"Natural science (n.e.c.)"', add
label define occ50ly_lbl 027 `"Social sciences (n.e.c.)"', add
label define occ50ly_lbl 028 `"Nonscientific subjects"', add
label define occ50ly_lbl 029 `"Subject not specified"', add
label define occ50ly_lbl 031 `"Dancers and dancing teachers"', add
label define occ50ly_lbl 032 `"Dentists"', add
label define occ50ly_lbl 033 `"Designers"', add
label define occ50ly_lbl 034 `"Dieticians and nutritionists"', add
label define occ50ly_lbl 035 `"Draftsmen"', add
label define occ50ly_lbl 036 `"Editors and reporters"', add
label define occ50ly_lbl 041 `"Engineers, aeronautical"', add
label define occ50ly_lbl 042 `"Engineers, chemical"', add
label define occ50ly_lbl 043 `"Engineers, civil"', add
label define occ50ly_lbl 044 `"Engineers, electrical"', add
label define occ50ly_lbl 045 `"Engineers, industrial"', add
label define occ50ly_lbl 046 `"Engineers, mechanical"', add
label define occ50ly_lbl 047 `"Engineers, metallurgical, metallurgists"', add
label define occ50ly_lbl 048 `"Engineers, mining"', add
label define occ50ly_lbl 049 `"Engineers (n.e.c.)"', add
label define occ50ly_lbl 051 `"Entertainers (n.e.c.)"', add
label define occ50ly_lbl 052 `"Farm and home management advisors"', add
label define occ50ly_lbl 053 `"Foresters and conservationists"', add
label define occ50ly_lbl 054 `"Funeral directors and embalmers"', add
label define occ50ly_lbl 055 `"Lawyers and judges"', add
label define occ50ly_lbl 056 `"Librarians"', add
label define occ50ly_lbl 057 `"Musicians and music teachers"', add
label define occ50ly_lbl 058 `"Nurses, professional"', add
label define occ50ly_lbl 059 `"Nurses, student professional"', add
label define occ50ly_lbl 061 `"Agricultural scientists"', add
label define occ50ly_lbl 062 `"Biological scientists"', add
label define occ50ly_lbl 063 `"Geologists and geophysicists"', add
label define occ50ly_lbl 067 `"Mathematicians"', add
label define occ50ly_lbl 068 `"Physicists"', add
label define occ50ly_lbl 069 `"Miscellaneous natural scientists"', add
label define occ50ly_lbl 070 `"Optometrists"', add
label define occ50ly_lbl 071 `"Osteopaths"', add
label define occ50ly_lbl 072 `"Personnel and labor relations workers"', add
label define occ50ly_lbl 073 `"Pharmacists"', add
label define occ50ly_lbl 074 `"Photographers"', add
label define occ50ly_lbl 075 `"Physicians and surgeons"', add
label define occ50ly_lbl 076 `"Radio operators"', add
label define occ50ly_lbl 077 `"Recreation and group workers"', add
label define occ50ly_lbl 078 `"Religious workers"', add
label define occ50ly_lbl 079 `"Social and welfare workers, except group"', add
label define occ50ly_lbl 081 `"Economists"', add
label define occ50ly_lbl 082 `"Psychologists"', add
label define occ50ly_lbl 083 `"Statisticians and actuaries"', add
label define occ50ly_lbl 084 `"Miscellaneous social scientists"', add
label define occ50ly_lbl 091 `"Sports instructors and officials"', add
label define occ50ly_lbl 092 `"Surveyors"', add
label define occ50ly_lbl 093 `"Teachers (n.e.c.)"', add
label define occ50ly_lbl 094 `"Technicians, medical and dental"', add
label define occ50ly_lbl 095 `"Technicians, testing"', add
label define occ50ly_lbl 096 `"Technicians (n.e.c.)"', add
label define occ50ly_lbl 097 `"Therapists and healers (n.e.c.)"', add
label define occ50ly_lbl 098 `"Veterinarians"', add
label define occ50ly_lbl 099 `"Professional, technical and kindred workers (n.e.c.)"', add
label define occ50ly_lbl 100 `"Farmers (owners and tenants)"', add
label define occ50ly_lbl 123 `"Farm managers"', add
label define occ50ly_lbl 200 `"Buyers and department heads, store"', add
label define occ50ly_lbl 201 `"Buyers and shippers, farm products"', add
label define occ50ly_lbl 203 `"Conductors, railroad"', add
label define occ50ly_lbl 204 `"Credit men"', add
label define occ50ly_lbl 205 `"Floormen and floor managers, store"', add
label define occ50ly_lbl 210 `"Inspectors, public administration"', add
label define occ50ly_lbl 230 `"Managers and superintendents, building"', add
label define occ50ly_lbl 240 `"Officers, pilots, pursers and engineers, ship"', add
label define occ50ly_lbl 250 `"Officials and administrators (n.e.c.), public administration"', add
label define occ50ly_lbl 260 `"Officials, lodge, society, union, etc."', add
label define occ50ly_lbl 270 `"Postmasters"', add
label define occ50ly_lbl 280 `"Purchasing agents and buyers (n.e.c.)"', add
label define occ50ly_lbl 290 `"Managers, officials, and proprietors (n.e.c.)"', add
label define occ50ly_lbl 300 `"Agents (n.e.c.)"', add
label define occ50ly_lbl 301 `"Attendants and assistants, library"', add
label define occ50ly_lbl 302 `"Attendants, physicians and dentists office"', add
label define occ50ly_lbl 304 `"Baggagemen, transportation"', add
label define occ50ly_lbl 305 `"Bank tellers"', add
label define occ50ly_lbl 310 `"Bookkeepers"', add
label define occ50ly_lbl 320 `"Cashiers"', add
label define occ50ly_lbl 321 `"Collectors, bill and account"', add
label define occ50ly_lbl 322 `"Dispatchers and starters, vehicle"', add
label define occ50ly_lbl 325 `"Express messengers and railway mail clerks"', add
label define occ50ly_lbl 335 `"Mail carriers"', add
label define occ50ly_lbl 340 `"Messengers and office boys"', add
label define occ50ly_lbl 341 `"Office machine operators"', add
label define occ50ly_lbl 342 `"Shipping and receiving clerks"', add
label define occ50ly_lbl 350 `"Stenographers, typists, and secretaries"', add
label define occ50ly_lbl 360 `"Telegraph messengers"', add
label define occ50ly_lbl 365 `"Telegraph operators"', add
label define occ50ly_lbl 370 `"Telephone operators"', add
label define occ50ly_lbl 380 `"Ticket, station, and express agents"', add
label define occ50ly_lbl 390 `"Clerical and kindred workers (n.e.c.)"', add
label define occ50ly_lbl 400 `"Advertising agents and salesmen"', add
label define occ50ly_lbl 410 `"Auctioneers"', add
label define occ50ly_lbl 420 `"Demonstrators"', add
label define occ50ly_lbl 430 `"Hucksters and peddlers"', add
label define occ50ly_lbl 450 `"Insurance agents and brokers"', add
label define occ50ly_lbl 460 `"Newsboys"', add
label define occ50ly_lbl 470 `"Real estate agents and brokers"', add
label define occ50ly_lbl 480 `"Stock and bond salesmen"', add
label define occ50ly_lbl 490 `"Salesmen and sales clerks (n.e.c.)"', add
label define occ50ly_lbl 500 `"Bakers"', add
label define occ50ly_lbl 501 `"Blacksmiths"', add
label define occ50ly_lbl 502 `"Bookbinders"', add
label define occ50ly_lbl 503 `"Boilermakers"', add
label define occ50ly_lbl 504 `"Brickmasons, stonemasons, and tile setters"', add
label define occ50ly_lbl 505 `"Cabinetmakers"', add
label define occ50ly_lbl 510 `"Carpenters"', add
label define occ50ly_lbl 511 `"Cement and concrete finishers"', add
label define occ50ly_lbl 512 `"Compositors and typesetters"', add
label define occ50ly_lbl 513 `"Cranemen, derrickmen, and hoistmen"', add
label define occ50ly_lbl 514 `"Decorators and window dressers"', add
label define occ50ly_lbl 515 `"Electricians"', add
label define occ50ly_lbl 520 `"Electrotypers and stereotypers"', add
label define occ50ly_lbl 521 `"Engravers, except photoengravers"', add
label define occ50ly_lbl 522 `"Excavating, grading, and road machinery operators"', add
label define occ50ly_lbl 523 `"Foremen (n.e.c.)"', add
label define occ50ly_lbl 524 `"Forgemen and hammermen"', add
label define occ50ly_lbl 525 `"Furriers"', add
label define occ50ly_lbl 530 `"Glaziers"', add
label define occ50ly_lbl 531 `"Heat treaters, annealers, temperers"', add
label define occ50ly_lbl 532 `"Inspectors, scalers, and graders, log and lumber"', add
label define occ50ly_lbl 533 `"Inspectors (n.e.c.)"', add
label define occ50ly_lbl 534 `"Jewelers, watchmakers, goldsmiths, and silversmiths"', add
label define occ50ly_lbl 535 `"Job setters, metal"', add
label define occ50ly_lbl 540 `"Linemen and servicemen, telegraph, telephone, and power"', add
label define occ50ly_lbl 541 `"Locomotive engineers"', add
label define occ50ly_lbl 542 `"Locomotive firemen"', add
label define occ50ly_lbl 543 `"Loom fixers"', add
label define occ50ly_lbl 544 `"Machinists"', add
label define occ50ly_lbl 545 `"Mechanics and repairmen, airplane"', add
label define occ50ly_lbl 550 `"Mechanics and repairmen, automobile"', add
label define occ50ly_lbl 551 `"Mechanics and repairmen, office machine"', add
label define occ50ly_lbl 552 `"Mechanics and repairmen, radio and television"', add
label define occ50ly_lbl 553 `"Mechanics and repairmen, railroad and car shop"', add
label define occ50ly_lbl 554 `"Mechanics and repairmen (n.e.c.)"', add
label define occ50ly_lbl 555 `"Millers, grain, flour, feed, etc."', add
label define occ50ly_lbl 560 `"Millwrights"', add
label define occ50ly_lbl 561 `"Molders, metal"', add
label define occ50ly_lbl 562 `"Motion picture projectionists"', add
label define occ50ly_lbl 563 `"Opticians and lens grinders and polishers"', add
label define occ50ly_lbl 564 `"Painters, construction and maintenance"', add
label define occ50ly_lbl 565 `"Paperhangers"', add
label define occ50ly_lbl 570 `"Pattern and model makers, except paper"', add
label define occ50ly_lbl 571 `"Photoengravers and lithographers"', add
label define occ50ly_lbl 572 `"Piano and organ tuners and repairmen"', add
label define occ50ly_lbl 573 `"Plasterers"', add
label define occ50ly_lbl 574 `"Plumbers and pipe fitters"', add
label define occ50ly_lbl 575 `"Pressmen and plate printers, printing"', add
label define occ50ly_lbl 580 `"Rollers and roll hands, metal"', add
label define occ50ly_lbl 581 `"Roofers and slaters"', add
label define occ50ly_lbl 582 `"Shoemakers and repairers, except factory"', add
label define occ50ly_lbl 583 `"Stationary engineers"', add
label define occ50ly_lbl 584 `"Stone cutters and stone carvers"', add
label define occ50ly_lbl 585 `"Structural metal workers"', add
label define occ50ly_lbl 590 `"Tailors and tailoresses"', add
label define occ50ly_lbl 591 `"Tinsmiths, coppersmiths, and sheet metal workers"', add
label define occ50ly_lbl 592 `"Tool makers, and die makers and setters"', add
label define occ50ly_lbl 593 `"Upholsterers"', add
label define occ50ly_lbl 594 `"Craftsmen and kindred workers (n.e.c.)"', add
label define occ50ly_lbl 595 `"Members of the armed services"', add
label define occ50ly_lbl 600 `"Apprentice auto mechanics"', add
label define occ50ly_lbl 601 `"Apprentice bricklayers and masons"', add
label define occ50ly_lbl 602 `"Apprentice carpenters"', add
label define occ50ly_lbl 603 `"Apprentice electricians"', add
label define occ50ly_lbl 604 `"Apprentice machinists and toolmakers"', add
label define occ50ly_lbl 605 `"Apprentice mechanics, except auto"', add
label define occ50ly_lbl 610 `"Apprentice plumbers and pipe fitters"', add
label define occ50ly_lbl 611 `"Apprentices, building trades (n.e.c.)"', add
label define occ50ly_lbl 612 `"Apprentices, metalworking trades (n.e.c.)"', add
label define occ50ly_lbl 613 `"Apprentices, printing trades"', add
label define occ50ly_lbl 614 `"Apprentices, other specified trades"', add
label define occ50ly_lbl 615 `"Apprentices, trade not specified"', add
label define occ50ly_lbl 620 `"Asbestos and insulation workers"', add
label define occ50ly_lbl 621 `"Attendants, auto service and parking"', add
label define occ50ly_lbl 622 `"Blasters and powdermen"', add
label define occ50ly_lbl 623 `"Boatmen, canalmen, and lock keepers"', add
label define occ50ly_lbl 624 `"Brakemen, railroad"', add
label define occ50ly_lbl 625 `"Bus drivers"', add
label define occ50ly_lbl 630 `"Chainmen, rodmen, and axmen, surveying"', add
label define occ50ly_lbl 631 `"Conductors, bus and street railway"', add
label define occ50ly_lbl 632 `"Deliverymen and routemen"', add
label define occ50ly_lbl 633 `"Dressmakers and seamstresses, except factory"', add
label define occ50ly_lbl 634 `"Dyers"', add
label define occ50ly_lbl 635 `"Filers, grinders, and polishers, metal"', add
label define occ50ly_lbl 640 `"Fruit, nut, veg graders and packers, except factory"', add
label define occ50ly_lbl 641 `"Furnacemen, smeltermen and pourers"', add
label define occ50ly_lbl 642 `"Heaters, metal"', add
label define occ50ly_lbl 643 `"Laundry and dry cleaning operatives"', add
label define occ50ly_lbl 644 `"Meat cutters, except slaughter and packing house"', add
label define occ50ly_lbl 645 `"Milliners"', add
label define occ50ly_lbl 650 `"Mine operatives and laborers"', add
label define occ50ly_lbl 660 `"Motormen, mine, factory, logging camp, etc."', add
label define occ50ly_lbl 661 `"Motormen, street, subway, and elevated railway"', add
label define occ50ly_lbl 662 `"Oilers and greaser, except auto"', add
label define occ50ly_lbl 670 `"Painters, except construction or maintenance"', add
label define occ50ly_lbl 671 `"Photographic process workers"', add
label define occ50ly_lbl 672 `"Power station operators"', add
label define occ50ly_lbl 673 `"Sailors and deck hands"', add
label define occ50ly_lbl 674 `"Sawyers"', add
label define occ50ly_lbl 675 `"Spinners, textile"', add
label define occ50ly_lbl 680 `"Stationary firemen"', add
label define occ50ly_lbl 681 `"Switchmen, railroad"', add
label define occ50ly_lbl 682 `"Taxicab drivers and chauffers"', add
label define occ50ly_lbl 683 `"Truck and tractor drivers"', add
label define occ50ly_lbl 684 `"Weavers, textile"', add
label define occ50ly_lbl 685 `"Welders and flame cutters"', add
label define occ50ly_lbl 690 `"Operative and kindred workers (n.e.c.)"', add
label define occ50ly_lbl 700 `"Housekeepers, private household"', add
label define occ50ly_lbl 710 `"Laundressses, private household"', add
label define occ50ly_lbl 720 `"Private household workers (n.e.c.)"', add
label define occ50ly_lbl 730 `"Attendants, hospital and other institution"', add
label define occ50ly_lbl 731 `"Attendants, professional and personal service (n.e.c.)"', add
label define occ50ly_lbl 732 `"Attendants, recreation and amusement"', add
label define occ50ly_lbl 740 `"Barbers, beauticians, and manicurists"', add
label define occ50ly_lbl 750 `"Bartenders"', add
label define occ50ly_lbl 751 `"Bootblacks"', add
label define occ50ly_lbl 752 `"Boarding and lodging house keepers"', add
label define occ50ly_lbl 753 `"Charwomen and cleaners"', add
label define occ50ly_lbl 754 `"Cooks, except private household"', add
label define occ50ly_lbl 760 `"Counter and fountain workers"', add
label define occ50ly_lbl 761 `"Elevator operators"', add
label define occ50ly_lbl 762 `"Firemen, fire protection"', add
label define occ50ly_lbl 763 `"Guards, watchmen, and doorkeepers"', add
label define occ50ly_lbl 764 `"Housekeepers and stewards, except private household"', add
label define occ50ly_lbl 770 `"Janitors and sextons"', add
label define occ50ly_lbl 771 `"Marshals and constables"', add
label define occ50ly_lbl 772 `"Midwives"', add
label define occ50ly_lbl 773 `"Policemen and detectives"', add
label define occ50ly_lbl 780 `"Porters"', add
label define occ50ly_lbl 781 `"Practical nurses"', add
label define occ50ly_lbl 782 `"Sheriffs and bailiffs"', add
label define occ50ly_lbl 783 `"Ushers, recreation and amusement"', add
label define occ50ly_lbl 784 `"Waiters and waitresses"', add
label define occ50ly_lbl 785 `"Watchmen (crossing) and bridge tenders"', add
label define occ50ly_lbl 790 `"Service workers, except private household (n.e.c.)"', add
label define occ50ly_lbl 810 `"Farm foremen"', add
label define occ50ly_lbl 820 `"Farm laborers, wage workers"', add
label define occ50ly_lbl 830 `"Farm laborers, unpaid family workers"', add
label define occ50ly_lbl 840 `"Farm service laborers, self-employed"', add
label define occ50ly_lbl 910 `"Fishermen and oystermen"', add
label define occ50ly_lbl 920 `"Garage laborers and car washers and greasers"', add
label define occ50ly_lbl 930 `"Gardeners, except farm, and groundskeepers"', add
label define occ50ly_lbl 940 `"Longshoremen and stevedores"', add
label define occ50ly_lbl 950 `"Lumbermen, raftsmen, and woodchoppers"', add
label define occ50ly_lbl 960 `"Teamsters"', add
label define occ50ly_lbl 970 `"Laborers (n.e.c.)"', add
label define occ50ly_lbl 997 `"Unknown"', add
label define occ50ly_lbl 999 `"Unemployed- last worked over x years ago"', add
label values occ50ly occ50ly_lbl

label define ind50ly_lbl 000 `"NIU"'
label define ind50ly_lbl 105 `"Agriculture"', add
label define ind50ly_lbl 116 `"Forestry"', add
label define ind50ly_lbl 126 `"Fisheries"', add
label define ind50ly_lbl 206 `"Metal mining"', add
label define ind50ly_lbl 216 `"Coal mining"', add
label define ind50ly_lbl 226 `"Crude petroleum and natural gas extraction"', add
label define ind50ly_lbl 236 `"Nonmetallic mining and quarrying, except fuel"', add
label define ind50ly_lbl 239 `"Mining not specified"', add
label define ind50ly_lbl 246 `"Construction"', add
label define ind50ly_lbl 306 `"Logging"', add
label define ind50ly_lbl 307 `"Sawmills, planing mills, and millwork"', add
label define ind50ly_lbl 308 `"Misc wood products"', add
label define ind50ly_lbl 309 `"Furniture and fixtures"', add
label define ind50ly_lbl 316 `"Glass and glass products"', add
label define ind50ly_lbl 317 `"Cement, concrete, gypsum and plaster products"', add
label define ind50ly_lbl 318 `"Structural clay products"', add
label define ind50ly_lbl 319 `"Pottery and related products"', add
label define ind50ly_lbl 326 `"Miscellaneous nonmetallic mineral and stone products"', add
label define ind50ly_lbl 336 `"Blast furnaces, steel works, and rolling mills"', add
label define ind50ly_lbl 337 `"Other primary iron and steel industries"', add
label define ind50ly_lbl 338 `"Primary nonferrous industries"', add
label define ind50ly_lbl 346 `"Fabricated steel products"', add
label define ind50ly_lbl 347 `"Fabricated nonferrous metal products"', add
label define ind50ly_lbl 348 `"Not specified metal industries"', add
label define ind50ly_lbl 356 `"Agricultural machinery and tractors"', add
label define ind50ly_lbl 357 `"Office and store machines and devices"', add
label define ind50ly_lbl 358 `"Miscellaneous machinery"', add
label define ind50ly_lbl 367 `"Electrical machinery, equipment, and supplies"', add
label define ind50ly_lbl 376 `"Motor vehicles and motor vehicle equipment"', add
label define ind50ly_lbl 377 `"Aircraft and parts"', add
label define ind50ly_lbl 378 `"Ship and boat building and repairing"', add
label define ind50ly_lbl 379 `"Railroad and miscellaneous transportation equipment"', add
label define ind50ly_lbl 386 `"Professional equipment and supplies"', add
label define ind50ly_lbl 387 `"Photographic equipment and supplies"', add
label define ind50ly_lbl 388 `"Watches, clocks, and clockwork-operated devices"', add
label define ind50ly_lbl 399 `"Miscellaneous manufacturing industries"', add
label define ind50ly_lbl 406 `"Meat products"', add
label define ind50ly_lbl 407 `"Dairy products"', add
label define ind50ly_lbl 408 `"Canning and preserving fruits, vegetables, and seafoods"', add
label define ind50ly_lbl 409 `"Grain-mill products"', add
label define ind50ly_lbl 416 `"Bakery products"', add
label define ind50ly_lbl 417 `"Confectionery and related products"', add
label define ind50ly_lbl 418 `"Beverage industries"', add
label define ind50ly_lbl 419 `"Miscellaneous food preparations and kindred products"', add
label define ind50ly_lbl 426 `"Not specified food industries"', add
label define ind50ly_lbl 429 `"Tobacco manufactures"', add
label define ind50ly_lbl 436 `"Knitting mills"', add
label define ind50ly_lbl 437 `"Dyeing and finishing textiles, except knit goods"', add
label define ind50ly_lbl 438 `"Carpets, rugs, and other floor coverings"', add
label define ind50ly_lbl 439 `"Yarn, thread, and fabric mills"', add
label define ind50ly_lbl 446 `"Miscellaneous textile mill products"', add
label define ind50ly_lbl 448 `"Apparel and accessories"', add
label define ind50ly_lbl 449 `"Miscellaneous fabricated textile products"', add
label define ind50ly_lbl 456 `"Pulp, paper, and paperboard mills"', add
label define ind50ly_lbl 457 `"Paperboard containers and boxes"', add
label define ind50ly_lbl 458 `"Miscellaneous paper and pulp products"', add
label define ind50ly_lbl 459 `"Printing, publishing, and allied industries"', add
label define ind50ly_lbl 466 `"Synthetic fibers"', add
label define ind50ly_lbl 467 `"Drugs and medicines"', add
label define ind50ly_lbl 468 `"Paints, varnishes, and related products"', add
label define ind50ly_lbl 469 `"Miscellaneous chemicals and allied products"', add
label define ind50ly_lbl 476 `"Petroleum refining"', add
label define ind50ly_lbl 477 `"Miscellaneous petroleum and coal products"', add
label define ind50ly_lbl 478 `"Rubber products"', add
label define ind50ly_lbl 487 `"Leather: tanned, curried, and finished"', add
label define ind50ly_lbl 488 `"Footwear, except rubber"', add
label define ind50ly_lbl 489 `"Leather products, except footwear"', add
label define ind50ly_lbl 499 `"Not specified manufacturing industries"', add
label define ind50ly_lbl 506 `"Railroads and railway express service"', add
label define ind50ly_lbl 516 `"Street railways and bus lines"', add
label define ind50ly_lbl 526 `"Trucking service"', add
label define ind50ly_lbl 527 `"Warehousing and storage"', add
label define ind50ly_lbl 536 `"Taxicab service"', add
label define ind50ly_lbl 546 `"Water transportation"', add
label define ind50ly_lbl 556 `"Air transportation"', add
label define ind50ly_lbl 567 `"Petroleum and gasoline pipe lines"', add
label define ind50ly_lbl 568 `"Services incidental to transportation"', add
label define ind50ly_lbl 578 `"Telephone"', add
label define ind50ly_lbl 579 `"Telegraph"', add
label define ind50ly_lbl 586 `"Electric light and power"', add
label define ind50ly_lbl 587 `"Gas and steam supply systems"', add
label define ind50ly_lbl 588 `"Electric-gas utilities"', add
label define ind50ly_lbl 596 `"Water supply"', add
label define ind50ly_lbl 597 `"Sanitary services"', add
label define ind50ly_lbl 598 `"Other and not specified utilities"', add
label define ind50ly_lbl 606 `"Motor vehicles and equipment"', add
label define ind50ly_lbl 607 `"Drugs, chemicals, and allied products"', add
label define ind50ly_lbl 608 `"Dry goods apparel"', add
label define ind50ly_lbl 609 `"Food and related products"', add
label define ind50ly_lbl 616 `"Electrical goods, hardware, and plumbing equipment"', add
label define ind50ly_lbl 617 `"Machinery, equipment, and supplies"', add
label define ind50ly_lbl 618 `"Petroleum products"', add
label define ind50ly_lbl 619 `"Farm products--raw materials"', add
label define ind50ly_lbl 626 `"Miscellaneous wholesale trade"', add
label define ind50ly_lbl 627 `"Not specified wholesale trade"', add
label define ind50ly_lbl 636 `"Food stores, except dairy products"', add
label define ind50ly_lbl 637 `"Dairy products stores and milk retailing"', add
label define ind50ly_lbl 646 `"General merchandise stores"', add
label define ind50ly_lbl 647 `"Five and ten cent stores"', add
label define ind50ly_lbl 656 `"Apparel and accessories stores, except shoe"', add
label define ind50ly_lbl 657 `"Shoe stores"', add
label define ind50ly_lbl 658 `"Furniture and house furnishing stores"', add
label define ind50ly_lbl 659 `"Household appliance and radio stores"', add
label define ind50ly_lbl 667 `"Motor vehicles and accessories retailing"', add
label define ind50ly_lbl 668 `"Gasoline service stations"', add
label define ind50ly_lbl 669 `"Drug stores"', add
label define ind50ly_lbl 679 `"Eating and drinking places"', add
label define ind50ly_lbl 686 `"Hardware and farm implement stores"', add
label define ind50ly_lbl 687 `"Lumber and building material retailing"', add
label define ind50ly_lbl 688 `"Liquor stores"', add
label define ind50ly_lbl 689 `"Retail florists"', add
label define ind50ly_lbl 696 `"Jewelry stores"', add
label define ind50ly_lbl 697 `"Fuel and ice retailing"', add
label define ind50ly_lbl 698 `"Miscellaneous retail stores"', add
label define ind50ly_lbl 699 `"Not specified retail trade"', add
label define ind50ly_lbl 716 `"Banking and credit agencies"', add
label define ind50ly_lbl 726 `"Security and commodity brokerage and investment companies"', add
label define ind50ly_lbl 736 `"Insurance"', add
label define ind50ly_lbl 746 `"Real estate"', add
label define ind50ly_lbl 806 `"Advertising"', add
label define ind50ly_lbl 807 `"Accounting, auditing, and bookkeeping services"', add
label define ind50ly_lbl 808 `"Miscellaneous business services"', add
label define ind50ly_lbl 816 `"Auto repair services and garages"', add
label define ind50ly_lbl 817 `"Miscellaneous repair services"', add
label define ind50ly_lbl 826 `"Private households"', add
label define ind50ly_lbl 836 `"Hotels and lodging places"', add
label define ind50ly_lbl 846 `"Laundering, cleaning, and dyeing services"', add
label define ind50ly_lbl 847 `"Dressmaking shops"', add
label define ind50ly_lbl 848 `"Shoe repair shops"', add
label define ind50ly_lbl 849 `"Miscellaneous personal services"', add
label define ind50ly_lbl 856 `"Radio broadcasting and television"', add
label define ind50ly_lbl 857 `"Theaters and motion pictures"', add
label define ind50ly_lbl 858 `"Bowling alleys, and billiard and pool parlors"', add
label define ind50ly_lbl 859 `"Miscellaneous entertainment and recreation services"', add
label define ind50ly_lbl 868 `"Medical and other health services, except hospitals"', add
label define ind50ly_lbl 869 `"Hospitals"', add
label define ind50ly_lbl 879 `"Legal services"', add
label define ind50ly_lbl 888 `"Educational services"', add
label define ind50ly_lbl 896 `"Welfare and religious services"', add
label define ind50ly_lbl 897 `"Nonprofit membership organizations"', add
label define ind50ly_lbl 898 `"Engineering and architectural services"', add
label define ind50ly_lbl 899 `"Miscellaneous professional and related services"', add
label define ind50ly_lbl 906 `"Postal service"', add
label define ind50ly_lbl 916 `"Federal public administration"', add
label define ind50ly_lbl 926 `"State public administration"', add
label define ind50ly_lbl 936 `"Local public administration"', add
label define ind50ly_lbl 997 `"Nonclassifiable"', add
label define ind50ly_lbl 998 `"Industry not reported"', add
label values ind50ly ind50ly_lbl

label define occ90ly_lbl 003 `"Legislators"'
label define occ90ly_lbl 004 `"Chief executives and public administrators"', add
label define occ90ly_lbl 007 `"Financial managers"', add
label define occ90ly_lbl 008 `"Human resources and labor relations managers"', add
label define occ90ly_lbl 013 `"Managers and specialists in marketing, advertising, and public relations"', add
label define occ90ly_lbl 014 `"Managers in education and related fields"', add
label define occ90ly_lbl 015 `"Managers of medicine and health occupations"', add
label define occ90ly_lbl 016 `"Postmasters and mail superintendents"', add
label define occ90ly_lbl 017 `"Managers of food-serving and lodging establishments"', add
label define occ90ly_lbl 018 `"Managers of properties and real estate"', add
label define occ90ly_lbl 019 `"Funeral directors"', add
label define occ90ly_lbl 021 `"Managers of service organizations, n.e.c."', add
label define occ90ly_lbl 022 `"Managers and administrators, n.e.c."', add
label define occ90ly_lbl 023 `"Accountants and auditors"', add
label define occ90ly_lbl 024 `"Insurance underwriters"', add
label define occ90ly_lbl 025 `"Other financial specialists"', add
label define occ90ly_lbl 026 `"Management analysts"', add
label define occ90ly_lbl 027 `"Personnel, HR, training, and labor relations specialists"', add
label define occ90ly_lbl 028 `"Purchasing agents and buyers, of farm products"', add
label define occ90ly_lbl 029 `"Buyers, wholesale and retail trade"', add
label define occ90ly_lbl 033 `"Purchasing managers, agents and buyers, n.e.c."', add
label define occ90ly_lbl 034 `"Business and promotion agents"', add
label define occ90ly_lbl 035 `"Construction inspectors"', add
label define occ90ly_lbl 036 `"Inspectors and compliance officers, outside construction"', add
label define occ90ly_lbl 037 `"Management support occupations"', add
label define occ90ly_lbl 043 `"Architects"', add
label define occ90ly_lbl 044 `"Aerospace engineer"', add
label define occ90ly_lbl 045 `"Metallurgical and materials engineers, variously phrased"', add
label define occ90ly_lbl 047 `"Petroleum, mining, and geological engineers"', add
label define occ90ly_lbl 048 `"Chemical engineers"', add
label define occ90ly_lbl 053 `"Civil engineers"', add
label define occ90ly_lbl 055 `"Electrical engineer"', add
label define occ90ly_lbl 056 `"Industrial engineers"', add
label define occ90ly_lbl 057 `"Mechanical engineers"', add
label define occ90ly_lbl 059 `"Not-elsewhere-classified engineers"', add
label define occ90ly_lbl 064 `"Computer systems analysts and computer scientists"', add
label define occ90ly_lbl 065 `"Operations and systems researchers and analysts"', add
label define occ90ly_lbl 066 `"Actuaries"', add
label define occ90ly_lbl 067 `"Statisticians"', add
label define occ90ly_lbl 068 `"Mathematicians and mathematical scientists"', add
label define occ90ly_lbl 069 `"Physicists and astronomers"', add
label define occ90ly_lbl 073 `"Chemists"', add
label define occ90ly_lbl 074 `"Atmospheric and space scientists"', add
label define occ90ly_lbl 075 `"Geologists"', add
label define occ90ly_lbl 076 `"Physical scientists, n.e.c."', add
label define occ90ly_lbl 077 `"Agricultural and food scientists"', add
label define occ90ly_lbl 078 `"Biological scientists"', add
label define occ90ly_lbl 079 `"Foresters and conservation scientists"', add
label define occ90ly_lbl 083 `"Medical scientists"', add
label define occ90ly_lbl 084 `"Physicians"', add
label define occ90ly_lbl 085 `"Dentists"', add
label define occ90ly_lbl 086 `"Veterinarians"', add
label define occ90ly_lbl 087 `"Optometrists"', add
label define occ90ly_lbl 088 `"Podiatrists"', add
label define occ90ly_lbl 089 `"Other health and therapy"', add
label define occ90ly_lbl 095 `"Registered nurses"', add
label define occ90ly_lbl 096 `"Pharmacists"', add
label define occ90ly_lbl 097 `"Dietitians and nutritionists"', add
label define occ90ly_lbl 098 `"Respiratory therapists"', add
label define occ90ly_lbl 099 `"Occupational therapists"', add
label define occ90ly_lbl 103 `"Physical therapists"', add
label define occ90ly_lbl 104 `"Speech therapists"', add
label define occ90ly_lbl 105 `"Therapists, n.e.c."', add
label define occ90ly_lbl 106 `"Physicians' assistants"', add
label define occ90ly_lbl 113 `"Earth, environmental, and marine science instructors"', add
label define occ90ly_lbl 114 `"Biological science instructors"', add
label define occ90ly_lbl 115 `"Chemistry instructors"', add
label define occ90ly_lbl 116 `"Physics instructors"', add
label define occ90ly_lbl 118 `"Psychology instructors"', add
label define occ90ly_lbl 119 `"Economics instructors"', add
label define occ90ly_lbl 123 `"History instructors"', add
label define occ90ly_lbl 125 `"Sociology instructors"', add
label define occ90ly_lbl 127 `"Engineering instructors"', add
label define occ90ly_lbl 128 `"Math instructors"', add
label define occ90ly_lbl 139 `"Education instructors"', add
label define occ90ly_lbl 145 `"Law instructors"', add
label define occ90ly_lbl 147 `"Theology instructors"', add
label define occ90ly_lbl 149 `"Home economics instructors"', add
label define occ90ly_lbl 150 `"Humanities profs/instructors, college, nec"', add
label define occ90ly_lbl 154 `"Subject instructors (HS/college)"', add
label define occ90ly_lbl 155 `"Kindergarten and earlier school teachers"', add
label define occ90ly_lbl 156 `"Primary school teachers"', add
label define occ90ly_lbl 157 `"Secondary school teachers"', add
label define occ90ly_lbl 158 `"Special education teachers"', add
label define occ90ly_lbl 159 `"Teachers , n.e.c."', add
label define occ90ly_lbl 163 `"Vocational and educational counselors"', add
label define occ90ly_lbl 164 `"Librarians"', add
label define occ90ly_lbl 165 `"Archivists and curators"', add
label define occ90ly_lbl 166 `"Economists, market researchers, and survey researchers"', add
label define occ90ly_lbl 167 `"Psychologists"', add
label define occ90ly_lbl 168 `"Sociologists"', add
label define occ90ly_lbl 169 `"Social scientists, n.e.c."', add
label define occ90ly_lbl 173 `"Urban and regional planners"', add
label define occ90ly_lbl 174 `"Social workers"', add
label define occ90ly_lbl 175 `"Recreation workers"', add
label define occ90ly_lbl 176 `"Clergy and religious workers"', add
label define occ90ly_lbl 178 `"Lawyers"', add
label define occ90ly_lbl 179 `"Judges"', add
label define occ90ly_lbl 183 `"Writers and authors"', add
label define occ90ly_lbl 184 `"Technical writers"', add
label define occ90ly_lbl 185 `"Designers"', add
label define occ90ly_lbl 186 `"Musician or composer"', add
label define occ90ly_lbl 187 `"Actors, directors, producers"', add
label define occ90ly_lbl 188 `"Art makers: painters, sculptors, craft-artists, and print-makers"', add
label define occ90ly_lbl 189 `"Photographers"', add
label define occ90ly_lbl 193 `"Dancers"', add
label define occ90ly_lbl 194 `"Art/entertainment performers and related"', add
label define occ90ly_lbl 195 `"Editors and reporters"', add
label define occ90ly_lbl 198 `"Announcers"', add
label define occ90ly_lbl 199 `"Athletes, sports instructors, and officials"', add
label define occ90ly_lbl 200 `"Professionals, n.e.c."', add
label define occ90ly_lbl 203 `"Clinical laboratory technologies and technicians"', add
label define occ90ly_lbl 204 `"Dental hygenists"', add
label define occ90ly_lbl 205 `"Health record tech specialists"', add
label define occ90ly_lbl 206 `"Radiologic tech specialists"', add
label define occ90ly_lbl 207 `"Licensed practical nurses"', add
label define occ90ly_lbl 208 `"Health technologists and technicians, n.e.c."', add
label define occ90ly_lbl 213 `"Electrical and electronic (engineering) technicians"', add
label define occ90ly_lbl 214 `"Engineering technicians, n.e.c."', add
label define occ90ly_lbl 215 `"Mechanical engineering technicians"', add
label define occ90ly_lbl 217 `"Drafters"', add
label define occ90ly_lbl 218 `"Surveyors, cartographers, mapping scientists and technicians"', add
label define occ90ly_lbl 223 `"Biological technicians"', add
label define occ90ly_lbl 224 `"Chemical technicians"', add
label define occ90ly_lbl 225 `"Other science technicians"', add
label define occ90ly_lbl 226 `"Airplane pilots and navigators"', add
label define occ90ly_lbl 227 `"Air traffic controllers"', add
label define occ90ly_lbl 228 `"Broadcast equipment operators"', add
label define occ90ly_lbl 229 `"Computer software developers"', add
label define occ90ly_lbl 233 `"Programmers of numerically controlled machine tools"', add
label define occ90ly_lbl 234 `"Legal assistants, paralegals, legal support, etc"', add
label define occ90ly_lbl 235 `"Technicians, n.e.c."', add
label define occ90ly_lbl 243 `"Supervisors and proprietors of sales jobs"', add
label define occ90ly_lbl 253 `"Insurance sales occupations"', add
label define occ90ly_lbl 254 `"Real estate sales occupations"', add
label define occ90ly_lbl 255 `"Financial services sales occupations"', add
label define occ90ly_lbl 256 `"Advertising and related sales jobs"', add
label define occ90ly_lbl 258 `"Sales engineers"', add
label define occ90ly_lbl 274 `"Salespersons, n.e.c."', add
label define occ90ly_lbl 275 `"Retail sales clerks"', add
label define occ90ly_lbl 276 `"Cashiers"', add
label define occ90ly_lbl 277 `"Door-to-door sales, street sales, and news vendors"', add
label define occ90ly_lbl 283 `"Sales demonstrators / promoters / models"', add
label define occ90ly_lbl 290 `"Sales workers--allocated (1990 internal census)"', add
label define occ90ly_lbl 303 `"Office supervisors"', add
label define occ90ly_lbl 308 `"Computer and peripheral equipment operators"', add
label define occ90ly_lbl 313 `"Secretaries"', add
label define occ90ly_lbl 314 `"Stenographers"', add
label define occ90ly_lbl 315 `"Typists"', add
label define occ90ly_lbl 316 `"Interviewers, enumerators, and surveyors"', add
label define occ90ly_lbl 317 `"Hotel clerks"', add
label define occ90ly_lbl 318 `"Transportation ticket and reservation agents"', add
label define occ90ly_lbl 319 `"Receptionists"', add
label define occ90ly_lbl 323 `"Information clerks, nec"', add
label define occ90ly_lbl 326 `"Correspondence and order clerks"', add
label define occ90ly_lbl 328 `"Human resources clerks, except payroll and timekeeping"', add
label define occ90ly_lbl 329 `"Library assistants"', add
label define occ90ly_lbl 335 `"File clerks"', add
label define occ90ly_lbl 336 `"Records clerks"', add
label define occ90ly_lbl 337 `"Bookkeepers and accounting and auditing clerks"', add
label define occ90ly_lbl 338 `"Payroll and timekeeping clerks"', add
label define occ90ly_lbl 343 `"Cost and rate clerks (financial records processing)"', add
label define occ90ly_lbl 344 `"Billing clerks and related financial records processing"', add
label define occ90ly_lbl 345 `"Duplication machine operators / office machine operators"', add
label define occ90ly_lbl 346 `"Mail and paper handlers"', add
label define occ90ly_lbl 347 `"Office machine operators, n.e.c."', add
label define occ90ly_lbl 348 `"Telephone operators"', add
label define occ90ly_lbl 349 `"Other telecom operators"', add
label define occ90ly_lbl 354 `"Postal clerks, excluding mail carriers"', add
label define occ90ly_lbl 355 `"Mail carriers for postal service"', add
label define occ90ly_lbl 356 `"Mail clerks, outside of post office"', add
label define occ90ly_lbl 357 `"Messengers"', add
label define occ90ly_lbl 359 `"Dispatchers"', add
label define occ90ly_lbl 361 `"Inspectors, n.e.c."', add
label define occ90ly_lbl 364 `"Shipping and receiving clerks"', add
label define occ90ly_lbl 365 `"Stock and inventory clerks"', add
label define occ90ly_lbl 366 `"Meter readers"', add
label define occ90ly_lbl 368 `"Weighers, measurers, and checkers"', add
label define occ90ly_lbl 373 `"Material recording, scheduling, production, planning, and expediting clerks"', add
label define occ90ly_lbl 375 `"Insurance adjusters, examiners, and investigators"', add
label define occ90ly_lbl 376 `"Customer service reps, investigators and adjusters, except insurance"', add
label define occ90ly_lbl 377 `"Eligibility clerks for government programs; social welfare"', add
label define occ90ly_lbl 378 `"Bill and account collectors"', add
label define occ90ly_lbl 379 `"General office clerks"', add
label define occ90ly_lbl 383 `"Bank tellers"', add
label define occ90ly_lbl 384 `"Proofreaders"', add
label define occ90ly_lbl 385 `"Data entry keyers"', add
label define occ90ly_lbl 386 `"Statistical clerks"', add
label define occ90ly_lbl 387 `"Teacher's aides"', add
label define occ90ly_lbl 389 `"Administrative support jobs, n.e.c."', add
label define occ90ly_lbl 390 `"Professional, technical, and kindred workers--allocated (1990 internal census)"', add
label define occ90ly_lbl 391 `"Clerical and kindred workers--allocated (1990 internal census)"', add
label define occ90ly_lbl 405 `"Housekeepers, maids, butlers, stewards, and lodging quarters cleaners"', add
label define occ90ly_lbl 407 `"Private household cleaners and servants"', add
label define occ90ly_lbl 408 `"Private household workers--allocated (1990 internal census)"', add
label define occ90ly_lbl 415 `"Supervisors of guards"', add
label define occ90ly_lbl 417 `"Fire fighting, prevention, and inspection"', add
label define occ90ly_lbl 418 `"Police, detectives, and private investigators"', add
label define occ90ly_lbl 423 `"Other law enforcement: sheriffs, bailiffs, correctional institution officers"', add
label define occ90ly_lbl 425 `"Crossing guards and bridge tenders"', add
label define occ90ly_lbl 426 `"Guards, watchmen, doorkeepers"', add
label define occ90ly_lbl 427 `"Protective services, n.e.c."', add
label define occ90ly_lbl 434 `"Bartenders"', add
label define occ90ly_lbl 435 `"Waiter/waitress"', add
label define occ90ly_lbl 436 `"Cooks, variously defined"', add
label define occ90ly_lbl 438 `"Food counter and fountain workers"', add
label define occ90ly_lbl 439 `"Kitchen workers"', add
label define occ90ly_lbl 443 `"Waiter's assistant"', add
label define occ90ly_lbl 444 `"Misc food prep workers"', add
label define occ90ly_lbl 445 `"Dental assistants"', add
label define occ90ly_lbl 446 `"Health aides, except nursing"', add
label define occ90ly_lbl 447 `"Nursing aides, orderlies, and attendants"', add
label define occ90ly_lbl 448 `"Supervisors of cleaning and building service"', add
label define occ90ly_lbl 453 `"Janitors"', add
label define occ90ly_lbl 454 `"Elevator operators"', add
label define occ90ly_lbl 455 `"Pest control occupations"', add
label define occ90ly_lbl 456 `"Supervisors of personal service jobs, n.e.c."', add
label define occ90ly_lbl 457 `"Barbers"', add
label define occ90ly_lbl 458 `"Hairdressers and cosmetologists"', add
label define occ90ly_lbl 459 `"Recreation facility attendants"', add
label define occ90ly_lbl 461 `"Guides"', add
label define occ90ly_lbl 462 `"Ushers"', add
label define occ90ly_lbl 463 `"Public transportation attendants and inspectors"', add
label define occ90ly_lbl 464 `"Baggage porters"', add
label define occ90ly_lbl 465 `"Welfare service aides"', add
label define occ90ly_lbl 468 `"Child care workers"', add
label define occ90ly_lbl 469 `"Personal service occupations, nec"', add
label define occ90ly_lbl 473 `"Farmers (owners and tenants)"', add
label define occ90ly_lbl 474 `"Horticultural specialty farmers"', add
label define occ90ly_lbl 475 `"Farm managers, except for horticultural farms"', add
label define occ90ly_lbl 476 `"Managers of horticultural specialty farms"', add
label define occ90ly_lbl 479 `"Farm workers"', add
label define occ90ly_lbl 480 `"Farm laborers and farm foreman--allocated (1990 internal census)"', add
label define occ90ly_lbl 483 `"Marine life cultivation workers"', add
label define occ90ly_lbl 484 `"Nursery farming workers"', add
label define occ90ly_lbl 485 `"Supervisors of agricultural occupations"', add
label define occ90ly_lbl 486 `"Gardeners and groundskeepers"', add
label define occ90ly_lbl 487 `"Animal caretakers except on farms"', add
label define occ90ly_lbl 488 `"Graders and sorters of agricultural products"', add
label define occ90ly_lbl 489 `"Inspectors of agricultural products"', add
label define occ90ly_lbl 496 `"Timber, logging, and forestry workers"', add
label define occ90ly_lbl 498 `"Fishers, hunters, and kindred"', add
label define occ90ly_lbl 503 `"Supervisors of mechanics and repairers"', add
label define occ90ly_lbl 505 `"Automobile mechanics"', add
label define occ90ly_lbl 507 `"Bus, truck, and stationary engine mechanics"', add
label define occ90ly_lbl 508 `"Aircraft mechanics"', add
label define occ90ly_lbl 509 `"Small engine repairers"', add
label define occ90ly_lbl 514 `"Auto body repairers"', add
label define occ90ly_lbl 516 `"Heavy equipment and farm equipment mechanics"', add
label define occ90ly_lbl 518 `"Industrial machinery repairers"', add
label define occ90ly_lbl 519 `"Machinery maintenance occupations"', add
label define occ90ly_lbl 523 `"Repairers of industrial electrical equipment"', add
label define occ90ly_lbl 525 `"Repairers of data processing equipment"', add
label define occ90ly_lbl 526 `"Repairers of household appliances and power tools"', add
label define occ90ly_lbl 527 `"Telecom and line installers and repairers"', add
label define occ90ly_lbl 533 `"Repairers of electrical equipment, n.e.c."', add
label define occ90ly_lbl 534 `"Heating, air conditioning, and refigeration mechanics"', add
label define occ90ly_lbl 535 `"Precision makers, repairers, and smiths"', add
label define occ90ly_lbl 536 `"Locksmiths and safe repairers"', add
label define occ90ly_lbl 538 `"Office machine repairers and mechanics"', add
label define occ90ly_lbl 539 `"Repairers of mechanical controls and valves"', add
label define occ90ly_lbl 543 `"Elevator installers and repairers"', add
label define occ90ly_lbl 544 `"Millwrights"', add
label define occ90ly_lbl 549 `"Mechanics and repairers, n.e.c."', add
label define occ90ly_lbl 558 `"Supervisors of construction work"', add
label define occ90ly_lbl 563 `"Masons, tilers, and carpet installers"', add
label define occ90ly_lbl 567 `"Carpenters"', add
label define occ90ly_lbl 573 `"Drywall installers"', add
label define occ90ly_lbl 575 `"Electricians"', add
label define occ90ly_lbl 577 `"Electric power installers and repairers"', add
label define occ90ly_lbl 579 `"Painters, construction and maintenance"', add
label define occ90ly_lbl 583 `"Paperhangers"', add
label define occ90ly_lbl 584 `"Plasterers"', add
label define occ90ly_lbl 585 `"Plumbers, pipe fitters, and steamfitters"', add
label define occ90ly_lbl 588 `"Concrete and cement workers"', add
label define occ90ly_lbl 589 `"Glaziers"', add
label define occ90ly_lbl 593 `"Insulation workers"', add
label define occ90ly_lbl 594 `"Paving, surfacing, and tamping equipment operators"', add
label define occ90ly_lbl 595 `"Roofers and slaters"', add
label define occ90ly_lbl 596 `"Sheet metal duct installers"', add
label define occ90ly_lbl 597 `"Structural metal workers"', add
label define occ90ly_lbl 598 `"Drillers of earth"', add
label define occ90ly_lbl 599 `"Construction trades, n.e.c."', add
label define occ90ly_lbl 614 `"Drillers of oil wells"', add
label define occ90ly_lbl 615 `"Explosives workers"', add
label define occ90ly_lbl 616 `"Miners"', add
label define occ90ly_lbl 617 `"Other mining occupations"', add
label define occ90ly_lbl 628 `"Production supervisors or foremen"', add
label define occ90ly_lbl 634 `"Tool and die makers and die setters"', add
label define occ90ly_lbl 637 `"Machinists"', add
label define occ90ly_lbl 643 `"Boilermakers"', add
label define occ90ly_lbl 644 `"Precision grinders and filers"', add
label define occ90ly_lbl 645 `"Patternmakers and model makers"', add
label define occ90ly_lbl 646 `"Lay-out workers"', add
label define occ90ly_lbl 649 `"Engravers"', add
label define occ90ly_lbl 653 `"Tinsmiths, coppersmiths, and sheet metal workers"', add
label define occ90ly_lbl 657 `"Cabinetmakers and bench carpenters"', add
label define occ90ly_lbl 658 `"Furniture and wood finishers"', add
label define occ90ly_lbl 659 `"Other precision woodworkers"', add
label define occ90ly_lbl 666 `"Dressmakers and seamstresses"', add
label define occ90ly_lbl 667 `"Tailors"', add
label define occ90ly_lbl 668 `"Upholsterers"', add
label define occ90ly_lbl 669 `"Shoe repairers"', add
label define occ90ly_lbl 674 `"Other precision apparel and fabric workers"', add
label define occ90ly_lbl 675 `"Hand molders and shapers, except jewelers"', add
label define occ90ly_lbl 677 `"Optical goods workers"', add
label define occ90ly_lbl 678 `"Dental laboratory and medical appliance technicians"', add
label define occ90ly_lbl 679 `"Bookbinders"', add
label define occ90ly_lbl 684 `"Other precision and craft workers"', add
label define occ90ly_lbl 686 `"Butchers and meat cutters"', add
label define occ90ly_lbl 687 `"Bakers"', add
label define occ90ly_lbl 688 `"Batch food makers"', add
label define occ90ly_lbl 693 `"Adjusters and calibrators"', add
label define occ90ly_lbl 694 `"Water and sewage treatment plant operators"', add
label define occ90ly_lbl 695 `"Power plant operators"', add
label define occ90ly_lbl 696 `"Plant and system operators, stationary engineers"', add
label define occ90ly_lbl 699 `"Other plant and system operators"', add
label define occ90ly_lbl 703 `"Lathe, milling, and turning machine operatives"', add
label define occ90ly_lbl 706 `"Punching and stamping press operatives"', add
label define occ90ly_lbl 707 `"Rollers, roll hands, and finishers of metal"', add
label define occ90ly_lbl 708 `"Drilling and boring machine operators"', add
label define occ90ly_lbl 709 `"Grinding, abrading, buffing, and polishing workers"', add
label define occ90ly_lbl 713 `"Forge and hammer operators"', add
label define occ90ly_lbl 717 `"Fabricating machine operators, n.e.c."', add
label define occ90ly_lbl 719 `"Molders, and casting machine operators"', add
label define occ90ly_lbl 723 `"Metal platers"', add
label define occ90ly_lbl 724 `"Heat treating equipment operators"', add
label define occ90ly_lbl 726 `"Wood lathe, routing, and planing machine operators"', add
label define occ90ly_lbl 727 `"Sawing machine operators and sawyers"', add
label define occ90ly_lbl 728 `"Shaping and joining machine operator (woodworking)"', add
label define occ90ly_lbl 729 `"Nail and tacking machine operators  (woodworking)"', add
label define occ90ly_lbl 733 `"Other woodworking machine operators"', add
label define occ90ly_lbl 734 `"Printing machine operators, n.e.c."', add
label define occ90ly_lbl 735 `"Photoengravers and lithographers"', add
label define occ90ly_lbl 736 `"Typesetters and compositors"', add
label define occ90ly_lbl 738 `"Winding and twisting textile/apparel operatives"', add
label define occ90ly_lbl 739 `"Knitters, loopers, and toppers textile operatives"', add
label define occ90ly_lbl 743 `"Textile cutting machine operators"', add
label define occ90ly_lbl 744 `"Textile sewing machine operators"', add
label define occ90ly_lbl 745 `"Shoemaking machine operators"', add
label define occ90ly_lbl 747 `"Pressing machine operators (clothing)"', add
label define occ90ly_lbl 748 `"Laundry workers"', add
label define occ90ly_lbl 749 `"Misc textile machine operators"', add
label define occ90ly_lbl 753 `"Cementing and gluing maching operators"', add
label define occ90ly_lbl 754 `"Packers, fillers, and wrappers"', add
label define occ90ly_lbl 755 `"Extruding and forming machine operators"', add
label define occ90ly_lbl 756 `"Mixing and blending machine operatives"', add
label define occ90ly_lbl 757 `"Separating, filtering, and clarifying machine operators"', add
label define occ90ly_lbl 759 `"Painting machine operators"', add
label define occ90ly_lbl 763 `"Roasting and baking machine operators (food)"', add
label define occ90ly_lbl 764 `"Washing, cleaning, and pickling machine operators"', add
label define occ90ly_lbl 765 `"Paper folding machine operators"', add
label define occ90ly_lbl 766 `"Furnace, kiln, and oven operators, apart from food"', add
label define occ90ly_lbl 768 `"Crushing and grinding machine operators"', add
label define occ90ly_lbl 769 `"Slicing and cutting machine operators"', add
label define occ90ly_lbl 773 `"Motion picture projectionists"', add
label define occ90ly_lbl 774 `"Photographic process workers"', add
label define occ90ly_lbl 779 `"Machine operators, n.e.c."', add
label define occ90ly_lbl 783 `"Welders and metal cutters"', add
label define occ90ly_lbl 784 `"Solderers"', add
label define occ90ly_lbl 785 `"Assemblers of electrical equipment"', add
label define occ90ly_lbl 789 `"Hand painting, coating, and decorating occupations"', add
label define occ90ly_lbl 796 `"Production checkers and inspectors"', add
label define occ90ly_lbl 799 `"Graders and sorters in manufacturing"', add
label define occ90ly_lbl 803 `"Supervisors of motor vehicle transportation"', add
label define occ90ly_lbl 804 `"Truck, delivery, and tractor drivers"', add
label define occ90ly_lbl 808 `"Bus drivers"', add
label define occ90ly_lbl 809 `"Taxi cab drivers and chauffeurs"', add
label define occ90ly_lbl 813 `"Parking lot attendants"', add
label define occ90ly_lbl 815 `"Transport equipment operatives--allocated (1990 internal census)"', add
label define occ90ly_lbl 823 `"Railroad conductors and yardmasters"', add
label define occ90ly_lbl 824 `"Locomotive operators (engineers and firemen)"', add
label define occ90ly_lbl 825 `"Railroad brake, coupler, and switch operators"', add
label define occ90ly_lbl 829 `"Ship crews and marine engineers"', add
label define occ90ly_lbl 834 `"Water transport infrastructure tenders and crossing guards"', add
label define occ90ly_lbl 844 `"Operating engineers of construction equipment"', add
label define occ90ly_lbl 848 `"Crane, derrick, winch, and hoist operators"', add
label define occ90ly_lbl 853 `"Excavating and loading machine operators"', add
label define occ90ly_lbl 859 `"Misc material moving occupations"', add
label define occ90ly_lbl 865 `"Helpers, constructions"', add
label define occ90ly_lbl 866 `"Helpers, surveyors"', add
label define occ90ly_lbl 869 `"Construction laborers"', add
label define occ90ly_lbl 874 `"Production helpers"', add
label define occ90ly_lbl 875 `"Garbage and recyclable material collectors"', add
label define occ90ly_lbl 876 `"Materials movers: stevedores and longshore workers"', add
label define occ90ly_lbl 877 `"Stock handlers"', add
label define occ90ly_lbl 878 `"Machine feeders and offbearers"', add
label define occ90ly_lbl 883 `"Freight, stock, and materials handlers"', add
label define occ90ly_lbl 885 `"Garage and service station related occupations"', add
label define occ90ly_lbl 887 `"Vehicle washers and equipment cleaners"', add
label define occ90ly_lbl 888 `"Packers and packagers by hand"', add
label define occ90ly_lbl 889 `"Laborers outside construction"', add
label define occ90ly_lbl 890 `"Laborers, except farm--allocated (1990 internal census)"', add
label define occ90ly_lbl 905 `"Military"', add
label define occ90ly_lbl 991 `"Unemployed"', add
label define occ90ly_lbl 999 `"Unknown"', add
label values occ90ly occ90ly_lbl

label define ind90ly_lbl 000 `"NIU"'
label define ind90ly_lbl 010 `"Agricultural production, crops"', add
label define ind90ly_lbl 011 `"Agricultural production, livestock"', add
label define ind90ly_lbl 012 `"Veterinary services"', add
label define ind90ly_lbl 020 `"Landscape and horticultural services"', add
label define ind90ly_lbl 030 `"Agricultural services, n.e.c."', add
label define ind90ly_lbl 031 `"Forestry"', add
label define ind90ly_lbl 032 `"Fishing, hunting, and trapping"', add
label define ind90ly_lbl 040 `"Metal mining"', add
label define ind90ly_lbl 041 `"Coal mining"', add
label define ind90ly_lbl 042 `"Oil and gas extraction"', add
label define ind90ly_lbl 050 `"Nonmetallic mining and quarrying, except fuels"', add
label define ind90ly_lbl 060 `"All construction"', add
label define ind90ly_lbl 100 `"Meat products"', add
label define ind90ly_lbl 101 `"Dairy products"', add
label define ind90ly_lbl 102 `"Canned, frozen, and preserved fruits and vegetables"', add
label define ind90ly_lbl 110 `"Grain mill products"', add
label define ind90ly_lbl 111 `"Bakery products"', add
label define ind90ly_lbl 112 `"Sugar and confectionery products"', add
label define ind90ly_lbl 120 `"Beverage industries"', add
label define ind90ly_lbl 121 `"Misc. food preparations and kindred products"', add
label define ind90ly_lbl 122 `"Food industries, n.s."', add
label define ind90ly_lbl 130 `"Tobacco manufactures"', add
label define ind90ly_lbl 132 `"Knitting mills"', add
label define ind90ly_lbl 140 `"Dyeing and finishing textiles, except wool and knit goods"', add
label define ind90ly_lbl 141 `"Carpets and rugs"', add
label define ind90ly_lbl 142 `"Yarn, thread, and fabric mills"', add
label define ind90ly_lbl 150 `"Miscellaneous textile mill products"', add
label define ind90ly_lbl 151 `"Apparel and accessories, except knit"', add
label define ind90ly_lbl 152 `"Miscellaneous fabricated textile products"', add
label define ind90ly_lbl 160 `"Pulp, paper, and paperboard mills"', add
label define ind90ly_lbl 161 `"Miscellaneous paper and pulp products"', add
label define ind90ly_lbl 162 `"Paperboard containers and boxes"', add
label define ind90ly_lbl 171 `"Newspaper publishing and printing"', add
label define ind90ly_lbl 172 `"Printing, publishing, and allied industries, except newspapers"', add
label define ind90ly_lbl 180 `"Plastics, synthetics, and resins"', add
label define ind90ly_lbl 181 `"Drugs"', add
label define ind90ly_lbl 182 `"Soaps and cosmetics"', add
label define ind90ly_lbl 190 `"Paints, varnishes, and related products"', add
label define ind90ly_lbl 191 `"Agricultural chemicals"', add
label define ind90ly_lbl 192 `"Industrial and miscellaneous chemicals"', add
label define ind90ly_lbl 200 `"Petroleum refining"', add
label define ind90ly_lbl 201 `"Miscellaneous petroleum and coal products"', add
label define ind90ly_lbl 210 `"Tires and inner tubes"', add
label define ind90ly_lbl 211 `"Other rubber products, and plastics footwear and belting"', add
label define ind90ly_lbl 212 `"Miscellaneous plastics products"', add
label define ind90ly_lbl 220 `"Leather tanning and finishing"', add
label define ind90ly_lbl 221 `"Footwear, except rubber and plastic"', add
label define ind90ly_lbl 222 `"Leather products, except footwear"', add
label define ind90ly_lbl 229 `"Manufacturing, non-durable - allocated"', add
label define ind90ly_lbl 230 `"Logging"', add
label define ind90ly_lbl 231 `"Sawmills, planing mills, and millwork"', add
label define ind90ly_lbl 232 `"Wood buildings and mobile homes"', add
label define ind90ly_lbl 241 `"Miscellaneous wood products"', add
label define ind90ly_lbl 242 `"Furniture and fixtures"', add
label define ind90ly_lbl 250 `"Glass and glass products"', add
label define ind90ly_lbl 251 `"Cement, concrete, gypsum, and plaster products"', add
label define ind90ly_lbl 252 `"Structural clay products"', add
label define ind90ly_lbl 261 `"Pottery and related products"', add
label define ind90ly_lbl 262 `"Misc. nonmetallic mineral and stone products"', add
label define ind90ly_lbl 270 `"Blast furnaces, steelworks, rolling and finishing mills"', add
label define ind90ly_lbl 271 `"Iron and steel foundries"', add
label define ind90ly_lbl 272 `"Primary aluminum industries"', add
label define ind90ly_lbl 280 `"Other primary metal industries"', add
label define ind90ly_lbl 281 `"Cutlery, handtools, and general hardware"', add
label define ind90ly_lbl 282 `"Fabricated structural metal products"', add
label define ind90ly_lbl 290 `"Screw machine products"', add
label define ind90ly_lbl 291 `"Metal forgings and stampings"', add
label define ind90ly_lbl 292 `"Ordnance"', add
label define ind90ly_lbl 300 `"Miscellaneous fabricated metal products"', add
label define ind90ly_lbl 301 `"Metal industries, n.s."', add
label define ind90ly_lbl 310 `"Engines and turbines"', add
label define ind90ly_lbl 311 `"Farm machinery and equipment"', add
label define ind90ly_lbl 312 `"Construction and material handling machines"', add
label define ind90ly_lbl 320 `"Metalworking machinery"', add
label define ind90ly_lbl 321 `"Office and accounting machines"', add
label define ind90ly_lbl 322 `"Computers and related equipment"', add
label define ind90ly_lbl 331 `"Machinery, except electrical, n.e.c."', add
label define ind90ly_lbl 332 `"Machinery, n.s."', add
label define ind90ly_lbl 340 `"Household appliances"', add
label define ind90ly_lbl 341 `"Radio, TV, and communication equipment"', add
label define ind90ly_lbl 342 `"Electrical machinery, equipment, and supplies, n.e.c."', add
label define ind90ly_lbl 350 `"Electrical machinery, equipment, and supplies, n.s."', add
label define ind90ly_lbl 351 `"Motor vehicles and motor vehicle equipment"', add
label define ind90ly_lbl 352 `"Aircraft and parts"', add
label define ind90ly_lbl 360 `"Ship and boat building and repairing"', add
label define ind90ly_lbl 361 `"Railroad locomotives and equipment"', add
label define ind90ly_lbl 362 `"Guided missiles, space vehicles, and parts"', add
label define ind90ly_lbl 370 `"Cycles and miscellaneous transportation equipment"', add
label define ind90ly_lbl 371 `"Scientific and controlling instruments"', add
label define ind90ly_lbl 372 `"Medical, dental, and optical instruments and supplies"', add
label define ind90ly_lbl 380 `"Photographic equipment and supplies"', add
label define ind90ly_lbl 381 `"Watches, clocks, and clockwork operated devices"', add
label define ind90ly_lbl 390 `"Toys, amusement, and sporting goods"', add
label define ind90ly_lbl 391 `"Miscellaneous manufacturing industries"', add
label define ind90ly_lbl 392 `"Manufacturing industries, n.s."', add
label define ind90ly_lbl 400 `"Railroads"', add
label define ind90ly_lbl 401 `"Bus service and urban transit"', add
label define ind90ly_lbl 402 `"Taxicab service"', add
label define ind90ly_lbl 410 `"Trucking service"', add
label define ind90ly_lbl 411 `"Warehousing and storage"', add
label define ind90ly_lbl 412 `"U.S. Postal Service"', add
label define ind90ly_lbl 420 `"Water transportation"', add
label define ind90ly_lbl 421 `"Air transportation"', add
label define ind90ly_lbl 422 `"Pipe lines, except natural gas"', add
label define ind90ly_lbl 432 `"Services incidental to transportation"', add
label define ind90ly_lbl 440 `"Radio and television broadcasting and cable"', add
label define ind90ly_lbl 441 `"Wired communications"', add
label define ind90ly_lbl 442 `"Telegraph and miscellaneous communications services"', add
label define ind90ly_lbl 450 `"Electric light and power"', add
label define ind90ly_lbl 451 `"Gas and steam supply systems"', add
label define ind90ly_lbl 452 `"Electric and gas, and other combinations"', add
label define ind90ly_lbl 470 `"Water supply and irrigation"', add
label define ind90ly_lbl 471 `"Sanitary services"', add
label define ind90ly_lbl 472 `"Utilities, n.s."', add
label define ind90ly_lbl 500 `"Motor vehicles and equipment"', add
label define ind90ly_lbl 501 `"Furniture and home furnishings"', add
label define ind90ly_lbl 502 `"Lumber and construction materials"', add
label define ind90ly_lbl 510 `"Professional and commercial equipment and supplies"', add
label define ind90ly_lbl 511 `"Metals and minerals, except petroleum"', add
label define ind90ly_lbl 512 `"Electrical goods"', add
label define ind90ly_lbl 521 `"Hardware, plumbing and heating supplies"', add
label define ind90ly_lbl 530 `"Machinery, equipment, and supplies"', add
label define ind90ly_lbl 531 `"Scrap and waste materials"', add
label define ind90ly_lbl 532 `"Miscellaneous wholesale, durable goods"', add
label define ind90ly_lbl 540 `"Paper and paper products"', add
label define ind90ly_lbl 541 `"Drugs, chemicals, and allied products"', add
label define ind90ly_lbl 542 `"Apparel, fabrics, and notions"', add
label define ind90ly_lbl 550 `"Groceries and related products"', add
label define ind90ly_lbl 551 `"Farm-product raw materials"', add
label define ind90ly_lbl 552 `"Petroleum products"', add
label define ind90ly_lbl 560 `"Alcoholic beverages"', add
label define ind90ly_lbl 561 `"Farm supplies"', add
label define ind90ly_lbl 562 `"Miscellaneous wholesale, nondurable goods"', add
label define ind90ly_lbl 571 `"Wholesale trade, n.s."', add
label define ind90ly_lbl 580 `"Lumber and building material retailing"', add
label define ind90ly_lbl 581 `"Hardware stores"', add
label define ind90ly_lbl 582 `"Retail nurseries and garden stores"', add
label define ind90ly_lbl 590 `"Mobile home dealers"', add
label define ind90ly_lbl 591 `"Department stores"', add
label define ind90ly_lbl 592 `"Variety stores"', add
label define ind90ly_lbl 600 `"Miscellaneous general merchandise stores"', add
label define ind90ly_lbl 601 `"Grocery stores"', add
label define ind90ly_lbl 602 `"Dairy products stores"', add
label define ind90ly_lbl 610 `"Retail bakeries"', add
label define ind90ly_lbl 611 `"Food stores, n.e.c."', add
label define ind90ly_lbl 612 `"Motor vehicle dealers"', add
label define ind90ly_lbl 620 `"Auto and home supply stores"', add
label define ind90ly_lbl 621 `"Gasoline service stations"', add
label define ind90ly_lbl 622 `"Miscellaneous vehicle dealers"', add
label define ind90ly_lbl 623 `"Apparel and accessory stores, except shoe"', add
label define ind90ly_lbl 630 `"Shoe stores"', add
label define ind90ly_lbl 631 `"Furniture and home furnishings stores"', add
label define ind90ly_lbl 632 `"Household appliance stores"', add
label define ind90ly_lbl 633 `"Radio, TV, and computer stores"', add
label define ind90ly_lbl 640 `"Music stores"', add
label define ind90ly_lbl 641 `"Eating and drinking places"', add
label define ind90ly_lbl 642 `"Drug stores"', add
label define ind90ly_lbl 650 `"Liquor stores"', add
label define ind90ly_lbl 651 `"Sporting goods, bicycles, and hobby stores"', add
label define ind90ly_lbl 652 `"Book and stationery stores"', add
label define ind90ly_lbl 660 `"Jewelry stores"', add
label define ind90ly_lbl 661 `"Gift, novelty, and souvenir shops"', add
label define ind90ly_lbl 662 `"Sewing, needlework, and piece goods stores"', add
label define ind90ly_lbl 663 `"Catalog and mail order houses"', add
label define ind90ly_lbl 670 `"Vending machine operators"', add
label define ind90ly_lbl 671 `"Direct selling establishments"', add
label define ind90ly_lbl 672 `"Fuel dealers"', add
label define ind90ly_lbl 681 `"Retail florists"', add
label define ind90ly_lbl 682 `"Miscellaneous retail stores"', add
label define ind90ly_lbl 691 `"Retail trade, n.s."', add
label define ind90ly_lbl 700 `"Banking"', add
label define ind90ly_lbl 701 `"Savings institutions, including credit unions"', add
label define ind90ly_lbl 702 `"Credit agencies, n.e.c."', add
label define ind90ly_lbl 710 `"Security, commodity brokerage, and investment companies"', add
label define ind90ly_lbl 711 `"Insurance"', add
label define ind90ly_lbl 712 `"Real estate, including real estate-insurance offices"', add
label define ind90ly_lbl 721 `"Advertising"', add
label define ind90ly_lbl 722 `"Services to dwellings and other buildings"', add
label define ind90ly_lbl 731 `"Personnel supply services"', add
label define ind90ly_lbl 732 `"Computer and data processing services"', add
label define ind90ly_lbl 740 `"Detective and protective services"', add
label define ind90ly_lbl 741 `"Business services, n.e.c."', add
label define ind90ly_lbl 742 `"Automotive rental and leasing, without drivers"', add
label define ind90ly_lbl 750 `"Automobile parking and carwashes"', add
label define ind90ly_lbl 751 `"Automotive repair and related services"', add
label define ind90ly_lbl 752 `"Electrical repair shops"', add
label define ind90ly_lbl 760 `"Miscellaneous repair services"', add
label define ind90ly_lbl 761 `"Private households"', add
label define ind90ly_lbl 762 `"Hotels and motels"', add
label define ind90ly_lbl 770 `"Lodging places, except hotels and motels"', add
label define ind90ly_lbl 771 `"Laundry, cleaning, and garment services"', add
label define ind90ly_lbl 772 `"Beauty shops"', add
label define ind90ly_lbl 780 `"Barber shops"', add
label define ind90ly_lbl 781 `"Funeral service and crematories"', add
label define ind90ly_lbl 782 `"Shoe repair shops"', add
label define ind90ly_lbl 790 `"Dressmaking shops"', add
label define ind90ly_lbl 791 `"Miscellaneous personal services"', add
label define ind90ly_lbl 800 `"Theaters and motion pictures"', add
label define ind90ly_lbl 801 `"Video tape rental"', add
label define ind90ly_lbl 802 `"Bowling centers"', add
label define ind90ly_lbl 810 `"Miscellaneous entertainment and recreation services"', add
label define ind90ly_lbl 812 `"Offices and clinics of physicians"', add
label define ind90ly_lbl 820 `"Offices and clinics of dentists"', add
label define ind90ly_lbl 821 `"Offices and clinics of chiropractors"', add
label define ind90ly_lbl 822 `"Offices and clinics of optometrists"', add
label define ind90ly_lbl 830 `"Offices and clinics of health practitioners, n.e.c."', add
label define ind90ly_lbl 831 `"Hospitals"', add
label define ind90ly_lbl 832 `"Nursing and personal care facilities"', add
label define ind90ly_lbl 840 `"Health services, n.e.c."', add
label define ind90ly_lbl 841 `"Legal services"', add
label define ind90ly_lbl 842 `"Elementary and secondary schools"', add
label define ind90ly_lbl 850 `"Colleges and universities"', add
label define ind90ly_lbl 851 `"Vocational schools"', add
label define ind90ly_lbl 852 `"Libraries"', add
label define ind90ly_lbl 860 `"Educational services, n.e.c."', add
label define ind90ly_lbl 861 `"Job training and vocational rehabilitation services"', add
label define ind90ly_lbl 862 `"Child day care services"', add
label define ind90ly_lbl 863 `"Family child care homes"', add
label define ind90ly_lbl 870 `"Residential care facilities, without nursing"', add
label define ind90ly_lbl 871 `"Social services, n.e.c."', add
label define ind90ly_lbl 872 `"Museums, art galleries, and zoos"', add
label define ind90ly_lbl 873 `"Labor unions"', add
label define ind90ly_lbl 880 `"Religious organizations"', add
label define ind90ly_lbl 881 `"Membership organizations, n.e.c."', add
label define ind90ly_lbl 882 `"Engineering, architectural, and surveying services"', add
label define ind90ly_lbl 890 `"Accounting, auditing, and bookkeeping services"', add
label define ind90ly_lbl 891 `"Research, development, and testing services"', add
label define ind90ly_lbl 892 `"Management and public relations services"', add
label define ind90ly_lbl 893 `"Miscellaneous professional and related services"', add
label define ind90ly_lbl 900 `"Executive and legislative offices"', add
label define ind90ly_lbl 901 `"General government, n.e.c."', add
label define ind90ly_lbl 910 `"Justice, public order, and safety"', add
label define ind90ly_lbl 921 `"Public finance, taxation, and monetary policy"', add
label define ind90ly_lbl 922 `"Administration of human resources programs"', add
label define ind90ly_lbl 930 `"Administration of environmental quality and housing programs"', add
label define ind90ly_lbl 931 `"Administration of economic programs"', add
label define ind90ly_lbl 932 `"National security and international affairs"', add
label define ind90ly_lbl 940 `"Army"', add
label define ind90ly_lbl 941 `"Air Force"', add
label define ind90ly_lbl 942 `"Navy"', add
label define ind90ly_lbl 950 `"Marines"', add
label define ind90ly_lbl 951 `"Coast Guard"', add
label define ind90ly_lbl 952 `"Armed Forces, branch not specified"', add
label define ind90ly_lbl 960 `"Military Reserves or National Guard"', add
label define ind90ly_lbl 998 `"Unknown"', add
label values ind90ly ind90ly_lbl

label define occ10ly_lbl 0010 `"Chief executives and legislators/public administration"'
label define occ10ly_lbl 0020 `"General and Operations Managers"', add
label define occ10ly_lbl 0030 `"Managers in Marketing, Advertising, and Public Relations"', add
label define occ10ly_lbl 0100 `"Administrative Services Managers"', add
label define occ10ly_lbl 0110 `"Computer and Information Systems Managers"', add
label define occ10ly_lbl 0120 `"Financial Managers"', add
label define occ10ly_lbl 0130 `"Human Resources Managers"', add
label define occ10ly_lbl 0140 `"Industrial Production Managers"', add
label define occ10ly_lbl 0150 `"Purchasing Managers"', add
label define occ10ly_lbl 0160 `"Transportation, Storage, and Distribution Managers"', add
label define occ10ly_lbl 0205 `"Farmers, Ranchers, and Other Agricultural Managers"', add
label define occ10ly_lbl 0220 `"Constructions Managers"', add
label define occ10ly_lbl 0230 `"Education Administrators"', add
label define occ10ly_lbl 0300 `"Architectural and Engineering Managers"', add
label define occ10ly_lbl 0310 `"Food Service and Lodging Managers"', add
label define occ10ly_lbl 0320 `"Funeral Directors"', add
label define occ10ly_lbl 0330 `"Gaming Managers"', add
label define occ10ly_lbl 0350 `"Medical and Health Services Managers"', add
label define occ10ly_lbl 0360 `"Natural Science Managers"', add
label define occ10ly_lbl 0410 `"Property, Real Estate, and Community Association Managers"', add
label define occ10ly_lbl 0420 `"Social and Community Service Managers"', add
label define occ10ly_lbl 0430 `"Managers, nec (including Postmasters)"', add
label define occ10ly_lbl 0500 `"Agents and Business Managers of Artists, Performers, and Athletes"', add
label define occ10ly_lbl 0510 `"Buyers and Purchasing Agents, Farm Products"', add
label define occ10ly_lbl 0520 `"Wholesale and Retail Buyers, Except Farm Products"', add
label define occ10ly_lbl 0530 `"Purchasing Agents, Except Wholesale, Retail, and Farm Products"', add
label define occ10ly_lbl 0540 `"Claims Adjusters, Appraisers, Examiners, and Investigators"', add
label define occ10ly_lbl 0560 `"Compliance Officers, Except Agriculture"', add
label define occ10ly_lbl 0600 `"Cost Estimators"', add
label define occ10ly_lbl 0620 `"Human Resources, Training, and Labor Relations Specialists"', add
label define occ10ly_lbl 0700 `"Logisticians"', add
label define occ10ly_lbl 0710 `"Management Analysts"', add
label define occ10ly_lbl 0720 `"Meeting and Convention Planners"', add
label define occ10ly_lbl 0730 `"Other Business Operations and Management Specialists"', add
label define occ10ly_lbl 0800 `"Accountants and Auditors"', add
label define occ10ly_lbl 0810 `"Appraisers and Assessors of Real Estate"', add
label define occ10ly_lbl 0820 `"Budget Analysts"', add
label define occ10ly_lbl 0830 `"Credit Analysts"', add
label define occ10ly_lbl 0840 `"Financial Analysts"', add
label define occ10ly_lbl 0850 `"Personal Financial Advisors"', add
label define occ10ly_lbl 0860 `"Insurance Underwriters"', add
label define occ10ly_lbl 0900 `"Financial Examiners"', add
label define occ10ly_lbl 0910 `"Credit Counselors and Loan Officers"', add
label define occ10ly_lbl 0930 `"Tax Examiners and Collectors, and Revenue Agents"', add
label define occ10ly_lbl 0940 `"Tax Preparers"', add
label define occ10ly_lbl 0950 `"Financial Specialists, nec"', add
label define occ10ly_lbl 1000 `"Computer Scientists and Systems Analysts/Network systems Analysts/Web Developers"', add
label define occ10ly_lbl 1010 `"Computer Programmers"', add
label define occ10ly_lbl 1020 `"Software Developers, Applications and Systems Software"', add
label define occ10ly_lbl 1050 `"Computer Support Specialists"', add
label define occ10ly_lbl 1060 `"Database Administrators"', add
label define occ10ly_lbl 1100 `"Network and Computer Systems Administrators"', add
label define occ10ly_lbl 1200 `"Actuaries"', add
label define occ10ly_lbl 1220 `"Operations Research Analysts"', add
label define occ10ly_lbl 1230 `"Statisticians"', add
label define occ10ly_lbl 1240 `"Mathematical science occupations, nec"', add
label define occ10ly_lbl 1300 `"Architects, Except Naval"', add
label define occ10ly_lbl 1310 `"Surveyors, Cartographers, and Photogrammetrists"', add
label define occ10ly_lbl 1320 `"Aerospace Engineers"', add
label define occ10ly_lbl 1350 `"Chemical Engineers"', add
label define occ10ly_lbl 1360 `"Civil Engineers"', add
label define occ10ly_lbl 1400 `"Computer Hardware Engineers"', add
label define occ10ly_lbl 1410 `"Electrical and Electronics Engineers"', add
label define occ10ly_lbl 1420 `"Environmental Engineers"', add
label define occ10ly_lbl 1430 `"Industrial Engineers, including Health and Safety"', add
label define occ10ly_lbl 1440 `"Marine Engineers and Naval Architects"', add
label define occ10ly_lbl 1450 `"Materials Engineers"', add
label define occ10ly_lbl 1460 `"Mechanical Engineers"', add
label define occ10ly_lbl 1520 `"Petroleum, mining and geological engineers, including mining safety engineers"', add
label define occ10ly_lbl 1530 `"Engineers, nec"', add
label define occ10ly_lbl 1540 `"Drafters"', add
label define occ10ly_lbl 1550 `"Engineering Technicians, Except Drafters"', add
label define occ10ly_lbl 1560 `"Surveying and Mapping Technicians"', add
label define occ10ly_lbl 1600 `"Agricultural and Food Scientists"', add
label define occ10ly_lbl 1610 `"Biological Scientists"', add
label define occ10ly_lbl 1640 `"Conservation Scientists and Foresters"', add
label define occ10ly_lbl 1650 `"Medical Scientists, and Life Scientists, All Other"', add
label define occ10ly_lbl 1700 `"Astronomers and Physicists"', add
label define occ10ly_lbl 1710 `"Atmospheric and Space Scientists"', add
label define occ10ly_lbl 1720 `"Chemists and Materials Scientists"', add
label define occ10ly_lbl 1740 `"Environmental Scientists and Geoscientists"', add
label define occ10ly_lbl 1760 `"Physical Scientists, nec"', add
label define occ10ly_lbl 1800 `"Economists and market researchers"', add
label define occ10ly_lbl 1820 `"Psychologists"', add
label define occ10ly_lbl 1830 `"Urban and Regional Planners"', add
label define occ10ly_lbl 1840 `"Social Scientists, nec"', add
label define occ10ly_lbl 1900 `"Agricultural and Food Science Technicians"', add
label define occ10ly_lbl 1910 `"Biological Technicians"', add
label define occ10ly_lbl 1920 `"Chemical Technicians"', add
label define occ10ly_lbl 1930 `"Geological and Petroleum Technicians, and Nuclear Technicians"', add
label define occ10ly_lbl 1960 `"Life, Physical, and Social Science Technicians, nec"', add
label define occ10ly_lbl 1980 `"Professional, Research, or Technical Workers, nec"', add
label define occ10ly_lbl 2000 `"Counselors"', add
label define occ10ly_lbl 2010 `"Social Workers"', add
label define occ10ly_lbl 2020 `"Community and Social Service Specialists, nec"', add
label define occ10ly_lbl 2040 `"Clergy"', add
label define occ10ly_lbl 2050 `"Directors, Religious Activities and Education"', add
label define occ10ly_lbl 2060 `"Religious Workers, nec"', add
label define occ10ly_lbl 2100 `"Lawyers, and judges, magistrates, and other judicial workers"', add
label define occ10ly_lbl 2140 `"Paralegals and Legal Assistants"', add
label define occ10ly_lbl 2150 `"Legal Support Workers, nec"', add
label define occ10ly_lbl 2200 `"Postsecondary Teachers"', add
label define occ10ly_lbl 2300 `"Preschool and Kindergarten Teachers"', add
label define occ10ly_lbl 2310 `"Elementary and Middle School Teachers"', add
label define occ10ly_lbl 2320 `"Secondary School Teachers"', add
label define occ10ly_lbl 2330 `"Special Education Teachers"', add
label define occ10ly_lbl 2340 `"Other Teachers and Instructors"', add
label define occ10ly_lbl 2400 `"Archivists, Curators, and Museum Technicians"', add
label define occ10ly_lbl 2430 `"Librarians"', add
label define occ10ly_lbl 2440 `"Library Technicians"', add
label define occ10ly_lbl 2540 `"Teacher Assistants"', add
label define occ10ly_lbl 2550 `"Education, Training, and Library Workers, nec"', add
label define occ10ly_lbl 2600 `"Artists and Related Workers"', add
label define occ10ly_lbl 2630 `"Designers"', add
label define occ10ly_lbl 2700 `"Actors, Producers, and Directors"', add
label define occ10ly_lbl 2720 `"Athletes, Coaches, Umpires, and Related Workers"', add
label define occ10ly_lbl 2740 `"Dancers and Choreographers"', add
label define occ10ly_lbl 2750 `"Musicians, Singers, and Related Workers"', add
label define occ10ly_lbl 2760 `"Entertainers and Performers, Sports and Related Workers, All Other"', add
label define occ10ly_lbl 2800 `"Announcers"', add
label define occ10ly_lbl 2810 `"Editors, News Analysts, Reporters, and Correspondents"', add
label define occ10ly_lbl 2825 `"Public Relations Specialists"', add
label define occ10ly_lbl 2840 `"Technical Writers"', add
label define occ10ly_lbl 2850 `"Writers and Authors"', add
label define occ10ly_lbl 2860 `"Media and Communication Workers, nec"', add
label define occ10ly_lbl 2900 `"Broadcast and Sound Engineering Technicians and Radio Operators, and media and communication equipment workers, all other"', add
label define occ10ly_lbl 2910 `"Photographers"', add
label define occ10ly_lbl 2920 `"Television, Video, and Motion Picture Camera Operators and Editors"', add
label define occ10ly_lbl 3000 `"Chiropractors"', add
label define occ10ly_lbl 3010 `"Dentists"', add
label define occ10ly_lbl 3030 `"Dieticians and Nutritionists"', add
label define occ10ly_lbl 3040 `"Optometrists"', add
label define occ10ly_lbl 3050 `"Pharmacists"', add
label define occ10ly_lbl 3060 `"Physicians and Surgeons"', add
label define occ10ly_lbl 3110 `"Physician Assistants"', add
label define occ10ly_lbl 3120 `"Podiatrists"', add
label define occ10ly_lbl 3130 `"Registered Nurses"', add
label define occ10ly_lbl 3140 `"Audiologists"', add
label define occ10ly_lbl 3150 `"Occupational Therapists"', add
label define occ10ly_lbl 3160 `"Physical Therapists"', add
label define occ10ly_lbl 3200 `"Radiation Therapists"', add
label define occ10ly_lbl 3210 `"Recreational Therapists"', add
label define occ10ly_lbl 3220 `"Respiratory Therapists"', add
label define occ10ly_lbl 3230 `"Speech Language Pathologists"', add
label define occ10ly_lbl 3240 `"Therapists, nec"', add
label define occ10ly_lbl 3250 `"Veterinarians"', add
label define occ10ly_lbl 3260 `"Health Diagnosing and Treating Practitioners, nec"', add
label define occ10ly_lbl 3300 `"Clinical Laboratory Technologists and Technicians"', add
label define occ10ly_lbl 3310 `"Dental Hygienists"', add
label define occ10ly_lbl 3320 `"Diagnostic Related Technologists and Technicians"', add
label define occ10ly_lbl 3400 `"Emergency Medical Technicians and Paramedics"', add
label define occ10ly_lbl 3410 `"Health Diagnosing and Treating Practitioner Support Technicians"', add
label define occ10ly_lbl 3500 `"Licensed Practical and Licensed Vocational Nurses"', add
label define occ10ly_lbl 3510 `"Medical Records and Health Information Technicians"', add
label define occ10ly_lbl 3520 `"Opticians, Dispensing"', add
label define occ10ly_lbl 3530 `"Health Technologists and Technicians, nec"', add
label define occ10ly_lbl 3540 `"Healthcare Practitioners and Technical Occupations, nec"', add
label define occ10ly_lbl 3600 `"Nursing, Psychiatric, and Home Health Aides"', add
label define occ10ly_lbl 3610 `"Occupational Therapy Assistants and Aides"', add
label define occ10ly_lbl 3620 `"Physical Therapist Assistants and Aides"', add
label define occ10ly_lbl 3630 `"Massage Therapists"', add
label define occ10ly_lbl 3640 `"Dental Assistants"', add
label define occ10ly_lbl 3650 `"Medical Assistants and Other Healthcare Support Occupations, nec"', add
label define occ10ly_lbl 3700 `"First-Line Supervisors of Correctional Officers"', add
label define occ10ly_lbl 3710 `"First-Line Supervisors of Police and Detectives"', add
label define occ10ly_lbl 3720 `"First-Line Supervisors of Fire Fighting and Prevention Workers"', add
label define occ10ly_lbl 3730 `"Supervisors, Protective Service Workers, All Other"', add
label define occ10ly_lbl 3740 `"Firefighters"', add
label define occ10ly_lbl 3750 `"Fire Inspectors"', add
label define occ10ly_lbl 3800 `"Sheriffs, Bailiffs, Correctional Officers, and Jailers"', add
label define occ10ly_lbl 3820 `"Police Officers and Detectives"', add
label define occ10ly_lbl 3900 `"Animal Control"', add
label define occ10ly_lbl 3910 `"Private Detectives and Investigators"', add
label define occ10ly_lbl 3930 `"Security Guards and Gaming Surveillance Officers"', add
label define occ10ly_lbl 3940 `"Crossing Guards"', add
label define occ10ly_lbl 3950 `"Law enforcement workers, nec"', add
label define occ10ly_lbl 4000 `"Chefs and Cooks"', add
label define occ10ly_lbl 4010 `"First-Line Supervisors of Food Preparation and Serving Workers"', add
label define occ10ly_lbl 4030 `"Food Preparation Workers"', add
label define occ10ly_lbl 4040 `"Bartenders"', add
label define occ10ly_lbl 4050 `"Combined Food Preparation and Serving Workers, Including Fast Food"', add
label define occ10ly_lbl 4060 `"Counter Attendant, Cafeteria, Food Concession, and Coffee Shop"', add
label define occ10ly_lbl 4110 `"Waiters and Waitresses"', add
label define occ10ly_lbl 4120 `"Food Servers, Nonrestaurant"', add
label define occ10ly_lbl 4130 `"Food preparation and serving related workers, nec"', add
label define occ10ly_lbl 4140 `"Dishwashers"', add
label define occ10ly_lbl 4150 `"Host and Hostesses, Restaurant, Lounge, and Coffee Shop"', add
label define occ10ly_lbl 4200 `"First-Line Supervisors of Housekeeping and Janitorial Workers"', add
label define occ10ly_lbl 4210 `"First-Line Supervisors of Landscaping, Lawn Service, and Groundskeeping Workers"', add
label define occ10ly_lbl 4220 `"Janitors and Building Cleaners"', add
label define occ10ly_lbl 4230 `"Maids and Housekeeping Cleaners"', add
label define occ10ly_lbl 4240 `"Pest Control Workers"', add
label define occ10ly_lbl 4250 `"Grounds Maintenance Workers"', add
label define occ10ly_lbl 4300 `"First-Line Supervisors of Gaming Workers"', add
label define occ10ly_lbl 4320 `"First-Line Supervisors of Personal Service Workers"', add
label define occ10ly_lbl 4340 `"Animal Trainers"', add
label define occ10ly_lbl 4350 `"Nonfarm Animal Caretakers"', add
label define occ10ly_lbl 4400 `"Gaming Services Workers"', add
label define occ10ly_lbl 4420 `"Ushers, Lobby Attendants, and Ticket Takers"', add
label define occ10ly_lbl 4430 `"Entertainment Attendants and Related Workers, nec"', add
label define occ10ly_lbl 4460 `"Funeral Service Workers and Embalmers"', add
label define occ10ly_lbl 4500 `"Barbers"', add
label define occ10ly_lbl 4510 `"Hairdressers, Hairstylists, and Cosmetologists"', add
label define occ10ly_lbl 4520 `"Personal Appearance Workers, nec"', add
label define occ10ly_lbl 4530 `"Baggage Porters, Bellhops, and Concierges"', add
label define occ10ly_lbl 4540 `"Tour and Travel Guides"', add
label define occ10ly_lbl 4600 `"Childcare Workers"', add
label define occ10ly_lbl 4610 `"Personal Care Aides"', add
label define occ10ly_lbl 4620 `"Recreation and Fitness Workers"', add
label define occ10ly_lbl 4640 `"Residential Advisors"', add
label define occ10ly_lbl 4650 `"Personal Care and Service Workers, All Other"', add
label define occ10ly_lbl 4700 `"First-Line Supervisors of Sales Workers"', add
label define occ10ly_lbl 4720 `"Cashiers"', add
label define occ10ly_lbl 4740 `"Counter and Rental Clerks"', add
label define occ10ly_lbl 4750 `"Parts Salespersons"', add
label define occ10ly_lbl 4760 `"Retail Salespersons"', add
label define occ10ly_lbl 4800 `"Advertising Sales Agents"', add
label define occ10ly_lbl 4810 `"Insurance Sales Agents"', add
label define occ10ly_lbl 4820 `"Securities, Commodities, and Financial Services Sales Agents"', add
label define occ10ly_lbl 4830 `"Travel Agents"', add
label define occ10ly_lbl 4840 `"Sales Representatives, Services, All Other"', add
label define occ10ly_lbl 4850 `"Sales Representatives, Wholesale and Manufacturing"', add
label define occ10ly_lbl 4900 `"Models, Demonstrators, and Product Promoters"', add
label define occ10ly_lbl 4920 `"Real Estate Brokers and Sales Agents"', add
label define occ10ly_lbl 4930 `"Sales Engineers"', add
label define occ10ly_lbl 4940 `"Telemarketers"', add
label define occ10ly_lbl 4950 `"Door-to-Door Sales Workers, News and Street Vendors, and Related Workers"', add
label define occ10ly_lbl 4965 `"Sales and Related Workers, All Other"', add
label define occ10ly_lbl 5000 `"First-Line Supervisors of Office and Administrative Support Workers"', add
label define occ10ly_lbl 5010 `"Switchboard Operators, Including Answering Service"', add
label define occ10ly_lbl 5020 `"Telephone Operators"', add
label define occ10ly_lbl 5030 `"Communications Equipment Operators, All Other"', add
label define occ10ly_lbl 5100 `"Bill and Account Collectors"', add
label define occ10ly_lbl 5110 `"Billing and Posting Clerks"', add
label define occ10ly_lbl 5120 `"Bookkeeping, Accounting, and Auditing Clerks"', add
label define occ10ly_lbl 5130 `"Gaming Cage Workers"', add
label define occ10ly_lbl 5140 `"Payroll and Timekeeping Clerks"', add
label define occ10ly_lbl 5150 `"Procurement Clerks"', add
label define occ10ly_lbl 5160 `"Bank Tellers"', add
label define occ10ly_lbl 5165 `"Financial Clerks, nec"', add
label define occ10ly_lbl 5200 `"Brokerage Clerks"', add
label define occ10ly_lbl 5220 `"Court, Municipal, and License Clerks"', add
label define occ10ly_lbl 5230 `"Credit Authorizers, Checkers, and Clerks"', add
label define occ10ly_lbl 5240 `"Customer Service Representatives"', add
label define occ10ly_lbl 5250 `"Eligibility Interviewers, Government Programs"', add
label define occ10ly_lbl 5260 `"File Clerks"', add
label define occ10ly_lbl 5300 `"Hotel, Motel, and Resort Desk Clerks"', add
label define occ10ly_lbl 5310 `"Interviewers, Except Eligibility and Loan"', add
label define occ10ly_lbl 5320 `"Library Assistants, Clerical"', add
label define occ10ly_lbl 5330 `"Loan Interviewers and Clerks"', add
label define occ10ly_lbl 5340 `"New Account Clerks"', add
label define occ10ly_lbl 5350 `"Correspondent clerks and order clerks"', add
label define occ10ly_lbl 5360 `"Human Resources Assistants, Except Payroll and Timekeeping"', add
label define occ10ly_lbl 5400 `"Receptionists and Information Clerks"', add
label define occ10ly_lbl 5410 `"Reservation and Transportation Ticket Agents and Travel Clerks"', add
label define occ10ly_lbl 5420 `"Information and Record Clerks, All Other"', add
label define occ10ly_lbl 5500 `"Cargo and Freight Agents"', add
label define occ10ly_lbl 5510 `"Couriers and Messengers"', add
label define occ10ly_lbl 5520 `"Dispatchers"', add
label define occ10ly_lbl 5530 `"Meter Readers, Utilities"', add
label define occ10ly_lbl 5540 `"Postal Service Clerks"', add
label define occ10ly_lbl 5550 `"Postal Service Mail Carriers"', add
label define occ10ly_lbl 5560 `"Postal Service Mail Sorters, Processors, and Processing Machine Operators"', add
label define occ10ly_lbl 5600 `"Production, Planning, and Expediting Clerks"', add
label define occ10ly_lbl 5610 `"Shipping, Receiving, and Traffic Clerks"', add
label define occ10ly_lbl 5620 `"Stock Clerks and Order Fillers"', add
label define occ10ly_lbl 5630 `"Weighers, Measurers, Checkers, and Samplers, Recordkeeping"', add
label define occ10ly_lbl 5700 `"Secretaries and Administrative Assistants"', add
label define occ10ly_lbl 5800 `"Computer Operators"', add
label define occ10ly_lbl 5810 `"Data Entry Keyers"', add
label define occ10ly_lbl 5820 `"Word Processors and Typists"', add
label define occ10ly_lbl 5840 `"Insurance Claims and Policy Processing Clerks"', add
label define occ10ly_lbl 5850 `"Mail Clerks and Mail Machine Operators, Except Postal Service"', add
label define occ10ly_lbl 5860 `"Office Clerks, General"', add
label define occ10ly_lbl 5900 `"Office Machine Operators, Except Computer"', add
label define occ10ly_lbl 5910 `"Proofreaders and Copy Markers"', add
label define occ10ly_lbl 5920 `"Statistical Assistants"', add
label define occ10ly_lbl 5940 `"Office and administrative support workers, nec"', add
label define occ10ly_lbl 6005 `"First-Line Supervisors of Farming, Fishing, and Forestry Workers"', add
label define occ10ly_lbl 6010 `"Agricultural Inspectors"', add
label define occ10ly_lbl 6040 `"Graders and Sorters, Agricultural Products"', add
label define occ10ly_lbl 6050 `"Agricultural workers, nec"', add
label define occ10ly_lbl 6100 `"Fishing and hunting workers"', add
label define occ10ly_lbl 6120 `"Forest and Conservation Workers"', add
label define occ10ly_lbl 6130 `"Logging Workers"', add
label define occ10ly_lbl 6200 `"First-Line Supervisors of Construction Trades and Extraction Workers"', add
label define occ10ly_lbl 6210 `"Boilermakers"', add
label define occ10ly_lbl 6220 `"Brickmasons, Blockmasons, and Stonemasons"', add
label define occ10ly_lbl 6230 `"Carpenters"', add
label define occ10ly_lbl 6240 `"Carpet, Floor, and Tile Installers and Finishers"', add
label define occ10ly_lbl 6250 `"Cement Masons, Concrete Finishers, and Terrazzo Workers"', add
label define occ10ly_lbl 6260 `"Construction Laborers"', add
label define occ10ly_lbl 6300 `"Paving, Surfacing, and Tamping Equipment Operators"', add
label define occ10ly_lbl 6320 `"Construction equipment operators except paving, surfacing, and tamping equipment operators"', add
label define occ10ly_lbl 6330 `"Drywall Installers, Ceiling Tile Installers, and Tapers"', add
label define occ10ly_lbl 6355 `"Electricians"', add
label define occ10ly_lbl 6360 `"Glaziers"', add
label define occ10ly_lbl 6400 `"Insulation Workers"', add
label define occ10ly_lbl 6420 `"Painters, Construction and Maintenance"', add
label define occ10ly_lbl 6430 `"Paperhangers"', add
label define occ10ly_lbl 6440 `"Pipelayers, Plumbers, Pipefitters, and Steamfitters"', add
label define occ10ly_lbl 6460 `"Plasterers and Stucco Masons"', add
label define occ10ly_lbl 6500 `"Reinforcing Iron and Rebar Workers"', add
label define occ10ly_lbl 6515 `"Roofers"', add
label define occ10ly_lbl 6520 `"Sheet Metal Workers, metal-working"', add
label define occ10ly_lbl 6530 `"Structural Iron and Steel Workers"', add
label define occ10ly_lbl 6600 `"Helpers, Construction Trades"', add
label define occ10ly_lbl 6660 `"Construction and Building Inspectors"', add
label define occ10ly_lbl 6700 `"Elevator Installers and Repairers"', add
label define occ10ly_lbl 6710 `"Fence Erectors"', add
label define occ10ly_lbl 6720 `"Hazardous Materials Removal Workers"', add
label define occ10ly_lbl 6730 `"Highway Maintenance Workers"', add
label define occ10ly_lbl 6740 `"Rail-Track Laying and Maintenance Equipment Operators"', add
label define occ10ly_lbl 6765 `"Construction workers, nec"', add
label define occ10ly_lbl 6800 `"Derrick, rotary drill, and service unit operators, and roustabouts, oil, gas, and mining"', add
label define occ10ly_lbl 6820 `"Earth Drillers, Except Oil and Gas"', add
label define occ10ly_lbl 6830 `"Explosives Workers, Ordnance Handling Experts, and Blasters"', add
label define occ10ly_lbl 6840 `"Mining Machine Operators"', add
label define occ10ly_lbl 6940 `"Extraction workers, nec"', add
label define occ10ly_lbl 7000 `"First-Line Supervisors of Mechanics, Installers, and Repairers"', add
label define occ10ly_lbl 7010 `"Computer, Automated Teller, and Office Machine Repairers"', add
label define occ10ly_lbl 7020 `"Radio and Telecommunications Equipment Installers and Repairers"', add
label define occ10ly_lbl 7030 `"Avionics Technicians"', add
label define occ10ly_lbl 7040 `"Electric Motor, Power Tool, and Related Repairers"', add
label define occ10ly_lbl 7100 `"Electrical and electronics repairers, transportation equipment, and industrial and utility"', add
label define occ10ly_lbl 7110 `"Electronic Equipment Installers and Repairers, Motor Vehicles"', add
label define occ10ly_lbl 7120 `"Electronic Home Entertainment Equipment Installers and Repairers"', add
label define occ10ly_lbl 7125 `"Electronic Repairs, nec"', add
label define occ10ly_lbl 7130 `"Security and Fire Alarm Systems Installers"', add
label define occ10ly_lbl 7140 `"Aircraft Mechanics and Service Technicians"', add
label define occ10ly_lbl 7150 `"Automotive Body and Related Repairers"', add
label define occ10ly_lbl 7160 `"Automotive Glass Installers and Repairers"', add
label define occ10ly_lbl 7200 `"Automotive Service Technicians and Mechanics"', add
label define occ10ly_lbl 7210 `"Bus and Truck Mechanics and Diesel Engine Specialists"', add
label define occ10ly_lbl 7220 `"Heavy Vehicle and Mobile Equipment Service Technicians and Mechanics"', add
label define occ10ly_lbl 7240 `"Small Engine Mechanics"', add
label define occ10ly_lbl 7260 `"Vehicle and Mobile Equipment Mechanics, Installers, and Repairers, nec"', add
label define occ10ly_lbl 7300 `"Control and Valve Installers and Repairers"', add
label define occ10ly_lbl 7315 `"Heating, Air Conditioning, and Refrigeration Mechanics and Installers"', add
label define occ10ly_lbl 7320 `"Home Appliance Repairers"', add
label define occ10ly_lbl 7330 `"Industrial and Refractory Machinery Mechanics"', add
label define occ10ly_lbl 7340 `"Maintenance and Repair Workers, General"', add
label define occ10ly_lbl 7350 `"Maintenance Workers, Machinery"', add
label define occ10ly_lbl 7360 `"Millwrights"', add
label define occ10ly_lbl 7410 `"Electrical Power-Line Installers and Repairers"', add
label define occ10ly_lbl 7420 `"Telecommunications Line Installers and Repairers"', add
label define occ10ly_lbl 7430 `"Precision Instrument and Equipment Repairers"', add
label define occ10ly_lbl 7510 `"Coin, Vending, and Amusement Machine Servicers and Repairers"', add
label define occ10ly_lbl 7540 `"Locksmiths and Safe Repairers"', add
label define occ10ly_lbl 7550 `"Manufactured Building and Mobile Home Installers"', add
label define occ10ly_lbl 7560 `"Riggers"', add
label define occ10ly_lbl 7610 `"Helpers--Installation, Maintenance, and Repair Workers"', add
label define occ10ly_lbl 7630 `"Other Installation, Maintenance, and Repair Workers Including Wind Turbine Service Technicians, and Commercial Divers, and Signal and Track Switch Repairers"', add
label define occ10ly_lbl 7700 `"First-Line Supervisors of Production and Operating Workers"', add
label define occ10ly_lbl 7710 `"Aircraft Structure, Surfaces, Rigging, and Systems Assemblers"', add
label define occ10ly_lbl 7720 `"Electrical, Electronics, and Electromechanical Assemblers"', add
label define occ10ly_lbl 7730 `"Engine and Other Machine Assemblers"', add
label define occ10ly_lbl 7740 `"Structural Metal Fabricators and Fitters"', add
label define occ10ly_lbl 7750 `"Assemblers and Fabricators, nec"', add
label define occ10ly_lbl 7800 `"Bakers"', add
label define occ10ly_lbl 7810 `"Butchers and Other Meat, Poultry, and Fish Processing Workers"', add
label define occ10ly_lbl 7830 `"Food and Tobacco Roasting, Baking, and Drying Machine Operators and Tenders"', add
label define occ10ly_lbl 7840 `"Food Batchmakers"', add
label define occ10ly_lbl 7850 `"Food Cooking Machine Operators and Tenders"', add
label define occ10ly_lbl 7855 `"Food Processing, nec"', add
label define occ10ly_lbl 7900 `"Computer Control Programmers and Operators"', add
label define occ10ly_lbl 7920 `"Extruding and Drawing Machine Setters, Operators, and Tenders, Metal and Plastic"', add
label define occ10ly_lbl 7930 `"Forging Machine Setters, Operators, and Tenders, Metal and Plastic"', add
label define occ10ly_lbl 7940 `"Rolling Machine Setters, Operators, and Tenders, metal and Plastic"', add
label define occ10ly_lbl 7950 `"Cutting, Punching, and Press Machine Setters, Operators, and Tenders, Metal and Plastic"', add
label define occ10ly_lbl 7960 `"Drilling and Boring Machine Tool Setters, Operators, and Tenders, Metal and Plastic"', add
label define occ10ly_lbl 8000 `"Grinding, Lapping, Polishing, and Buffing Machine Tool Setters, Operators, and Tenders, Metal and Plastic"', add
label define occ10ly_lbl 8010 `"Lathe and Turning Machine Tool Setters, Operators, and Tenders, Metal and Plastic"', add
label define occ10ly_lbl 8030 `"Machinists"', add
label define occ10ly_lbl 8040 `"Metal Furnace Operators, Tenders, Pourers, and Casters"', add
label define occ10ly_lbl 8060 `"Model Makers and Patternmakers, Metal and Plastic"', add
label define occ10ly_lbl 8100 `"Molders and Molding Machine Setters, Operators, and Tenders, Metal and Plastic"', add
label define occ10ly_lbl 8130 `"Tool and Die Makers"', add
label define occ10ly_lbl 8140 `"Welding, Soldering, and Brazing Workers"', add
label define occ10ly_lbl 8150 `"Heat Treating Equipment Setters, Operators, and Tenders, Metal and Plastic"', add
label define occ10ly_lbl 8200 `"Plating and Coating Machine Setters, Operators, and Tenders, Metal and Plastic"', add
label define occ10ly_lbl 8210 `"Tool Grinders, Filers, and Sharpeners"', add
label define occ10ly_lbl 8220 `"Metal workers and plastic workers, nec"', add
label define occ10ly_lbl 8230 `"Bookbinders, Printing Machine Operators, and Job Printers"', add
label define occ10ly_lbl 8250 `"Prepress Technicians and Workers"', add
label define occ10ly_lbl 8300 `"Laundry and Dry-Cleaning Workers"', add
label define occ10ly_lbl 8310 `"Pressers, Textile, Garment, and Related Materials"', add
label define occ10ly_lbl 8320 `"Sewing Machine Operators"', add
label define occ10ly_lbl 8330 `"Shoe and Leather Workers and Repairers"', add
label define occ10ly_lbl 8340 `"Shoe Machine Operators and Tenders"', add
label define occ10ly_lbl 8350 `"Tailors, Dressmakers, and Sewers"', add
label define occ10ly_lbl 8400 `"Textile bleaching and dyeing, and cutting machine setters, operators, and tenders"', add
label define occ10ly_lbl 8410 `"Textile Knitting and Weaving Machine Setters, Operators, and Tenders"', add
label define occ10ly_lbl 8420 `"Textile Winding, Twisting, and Drawing Out Machine Setters, Operators, and Tenders"', add
label define occ10ly_lbl 8450 `"Upholsterers"', add
label define occ10ly_lbl 8460 `"Textile, Apparel, and Furnishings workers, nec"', add
label define occ10ly_lbl 8500 `"Cabinetmakers and Bench Carpenters"', add
label define occ10ly_lbl 8510 `"Furniture Finishers"', add
label define occ10ly_lbl 8530 `"Sawing Machine Setters, Operators, and Tenders, Wood"', add
label define occ10ly_lbl 8540 `"Woodworking Machine Setters, Operators, and Tenders, Except Sawing"', add
label define occ10ly_lbl 8550 `"Woodworkers including model makers and patternmakers, nec"', add
label define occ10ly_lbl 8600 `"Power Plant Operators, Distributors, and Dispatchers"', add
label define occ10ly_lbl 8610 `"Stationary Engineers and Boiler Operators"', add
label define occ10ly_lbl 8620 `"Water Wastewater Treatment Plant and System Operators"', add
label define occ10ly_lbl 8630 `"Plant and System Operators, nec"', add
label define occ10ly_lbl 8640 `"Chemical Processing Machine Setters, Operators, and Tenders"', add
label define occ10ly_lbl 8650 `"Crushing, Grinding, Polishing, Mixing, and Blending Workers"', add
label define occ10ly_lbl 8710 `"Cutting Workers"', add
label define occ10ly_lbl 8720 `"Extruding, Forming, Pressing, and Compacting Machine Setters, Operators, and Tenders"', add
label define occ10ly_lbl 8730 `"Furnace, Kiln, Oven, Drier, and Kettle Operators and Tenders"', add
label define occ10ly_lbl 8740 `"Inspectors, Testers, Sorters, Samplers, and Weighers"', add
label define occ10ly_lbl 8750 `"Jewelers and Precious Stone and Metal Workers"', add
label define occ10ly_lbl 8760 `"Medical, Dental, and Ophthalmic Laboratory Technicians"', add
label define occ10ly_lbl 8800 `"Packaging and Filling Machine Operators and Tenders"', add
label define occ10ly_lbl 8810 `"Painting Workers and Dyers"', add
label define occ10ly_lbl 8830 `"Photographic Process Workers and Processing Machine Operators"', add
label define occ10ly_lbl 8850 `"Adhesive Bonding Machine Operators and Tenders"', add
label define occ10ly_lbl 8860 `"Cleaning, Washing, and Metal Pickling Equipment Operators and Tenders"', add
label define occ10ly_lbl 8910 `"Etchers, Engravers, and Lithographers"', add
label define occ10ly_lbl 8920 `"Molders, Shapers, and Casters, Except Metal and Plastic"', add
label define occ10ly_lbl 8930 `"Paper Goods Machine Setters, Operators, and Tenders"', add
label define occ10ly_lbl 8940 `"Tire Builders"', add
label define occ10ly_lbl 8950 `"Helpers--Production Workers"', add
label define occ10ly_lbl 8965 `"Other production workers including semiconductor processors and cooling and freezing equipment operators"', add
label define occ10ly_lbl 9000 `"Supervisors of Transportation and Material Moving Workers"', add
label define occ10ly_lbl 9030 `"Aircraft Pilots and Flight Engineers"', add
label define occ10ly_lbl 9040 `"Air Traffic Controllers and Airfield Operations Specialists"', add
label define occ10ly_lbl 9050 `"Flight Attendants and Transportation Workers and Attendants"', add
label define occ10ly_lbl 9100 `"Bus and Ambulance Drivers and Attendants"', add
label define occ10ly_lbl 9130 `"Driver/Sales Workers and Truck Drivers"', add
label define occ10ly_lbl 9140 `"Taxi Drivers and Chauffeurs"', add
label define occ10ly_lbl 9150 `"Motor Vehicle Operators, All Other"', add
label define occ10ly_lbl 9200 `"Locomotive Engineers and Operators"', add
label define occ10ly_lbl 9230 `"Railroad Brake, Signal, and Switch Operators"', add
label define occ10ly_lbl 9240 `"Railroad Conductors and Yardmasters"', add
label define occ10ly_lbl 9260 `"Subway, Streetcar, and Other Rail Transportation Workers"', add
label define occ10ly_lbl 9300 `"Sailors and marine oilers, and ship engineers"', add
label define occ10ly_lbl 9310 `"Ship and Boat Captains and Operators"', add
label define occ10ly_lbl 9350 `"Parking Lot Attendants"', add
label define occ10ly_lbl 9360 `"Automotive and Watercraft Service Attendants"', add
label define occ10ly_lbl 9410 `"Transportation Inspectors"', add
label define occ10ly_lbl 9420 `"Transportation workers, nec"', add
label define occ10ly_lbl 9510 `"Crane and Tower Operators"', add
label define occ10ly_lbl 9520 `"Dredge, Excavating, and Loading Machine Operators"', add
label define occ10ly_lbl 9560 `"Conveyor operators and tenders, and hoist and winch operators"', add
label define occ10ly_lbl 9600 `"Industrial Truck and Tractor Operators"', add
label define occ10ly_lbl 9610 `"Cleaners of Vehicles and Equipment"', add
label define occ10ly_lbl 9620 `"Laborers and Freight, Stock, and Material Movers, Hand"', add
label define occ10ly_lbl 9630 `"Machine Feeders and Offbearers"', add
label define occ10ly_lbl 9640 `"Packers and Packagers, Hand"', add
label define occ10ly_lbl 9650 `"Pumping Station Operators"', add
label define occ10ly_lbl 9720 `"Refuse and Recyclable Material Collectors"', add
label define occ10ly_lbl 9750 `"Material moving workers, nec"', add
label define occ10ly_lbl 9800 `"Military Officer Special and Tactical Operations Leaders"', add
label define occ10ly_lbl 9810 `"First-Line Enlisted Military Supervisors"', add
label define occ10ly_lbl 9820 `"Military Enlisted Tactical Operations and Air/Weapons Specialists and Crew Members"', add
label define occ10ly_lbl 9830 `"Military, Rank Not Specified"', add
label define occ10ly_lbl 9920 `"Unemployed, with No Work Experience in the Last 5 Years or Earlier or Never Worked"', add
label define occ10ly_lbl 9999 `"Unknown"', add
label values occ10ly occ10ly_lbl





*
