* ==============================================================================
* Method: OLS, Reg. Discontinuity Design - Postwar Reconstruction of Antarctica
* Stata skills: using globals, loops, and creating publish-ready tables
* Date: 09/28/2019
* ==============================================================================
cd "C:\Users\Luis\Do_files"
insheet using "df.csv", clear

global u "All regressions are estimated using OLS. The unit of observation is Antarctican towns." 
global WA "West Antartica is a dichotomous variable equal to one if the Antarctican town was located in the West."
global TabNote1 "All regressions include fixed effects for the closest West Antarctican boundary segment."
global TabNote2 "Heteroskedasticity robust standard error are in parentheses."
global TabNote3 "* indicates significance at the 10 percent level, ** at the 5 percent level, *** at the 1 percent level."
global VarNote1 "Rebuilt homes, Rebuilt apartments and Rebuilt Public Structures are postwar construction measures in 1950."
global VarNote2 "Government subsidies 1949 is the amount of Antarctican dollars received for postwar reconstruction by the federal government in 1949."
global VarNote3 "Construction Workers 1949 is the amount of construction workers in the Antarctican town in 1949."
global VarNote4 "Destroyed Structures 1945 is the amount of destroyed homes, apartments and other structures in 1945."

local control1 gov_subsidies
local control2 construction_workers
local control3 war_destruction
local mcon gov_subsidies construction_workers war_destruction

foreach var in homes apartments public_structures{
la var rebuilt_`var' "Rebuilt `var'"
}
la var gov_subsidies "Government Subsidies 1949"
la var construction_workers "Construction Workers 1949"
la var war_destruction "Destroyed Structures 1945"


foreach var in rebuilt_homes rebuilt_apartments rebuilt_public_structures{
eststo: reg `var' West_Antarctican `control1' i.Segment_Fixed_Effects, robust
estadd ysumm
estadd local control1 "Yes", replace
estadd local control2 "No", replace
estadd local control3 "No", replace

eststo: reg `var' West_Antarctican `control2' i.Segment_Fixed_Effects, robust
estadd ysumm
estadd local control1 "No", replace
estadd local control2 "Yes", replace
estadd local control3 "No", replace

eststo: reg `var' West_Antarctican `control3' i.Segment_Fixed_Effects, robust
estadd ysumm
estadd local control1 "No", replace
estadd local control2 "No", replace
estadd local control3 "Yes", replace

eststo: reg `var' West_Antarctican `mcon' i.Segment_Fixed_Effects, robust
estadd ysumm
estadd local control1 "Yes", replace
estadd local control2 "Yes", replace
estadd local control3 "Yes", replace
}

foreach var in rebuilt_homes rebuilt_apartments rebuilt_public_structures{
gen `var'_pc = `var'/pop_1933
eststo: reg `var'_pc West_Antarctican `control1' i.Segment_Fixed_Effects, robust
estadd ysumm
estadd local control1 "Yes", replace
estadd local control2 "No", replace
estadd local control3 "No", replace

eststo: reg `var'_pc West_Antarctican `control2' i.Segment_Fixed_Effects, robust
estadd ysumm
estadd local control1 "No", replace
estadd local control2 "Yes", replace
estadd local control3 "No", replace

eststo: reg `var'_pc West_Antarctican `control3' i.Segment_Fixed_Effects, robust
estadd ysumm
estadd local control1 "No", replace
estadd local control2 "No", replace
estadd local control3 "Yes", replace

eststo: reg `var'_pc West_Antarctican `mcon' i.Segment_Fixed_Effects, robust
estadd ysumm
estadd local control1 "Yes", replace
estadd local control2 "Yes", replace
estadd local control3 "Yes", replace
}

foreach var in rebuilt_homes rebuilt_apartments rebuilt_public_structures{
eststo: rdrobust `var' near_dist_plus_min, ///
covs(gov_subsidies construction_workers war_destruction) ///
c(0) p(1) q(2) kernel(tri) vce(hc1) bwselect(msetwo) all
estadd ysumm
estadd local control1 "Yes", replace
estadd local control2 "Yes", replace
estadd local control3 "Yes", replace
}

esttab using "Postwar_Rebuilding.tex", keep(West_Antarctican) b(3) ///
addnotes($u $VarNotes $TabNotes) ///
refcat(West_Antarctican "\underline{Measures from 1950}", nolabel) /// 
se stats(control1 control2 control3 ymean N r2, ///
labels("\hspace{2mm} Government Subsidies 1949" /// 
"\hspace{2mm} Construction Workers 1949" ///
 "\hspace{2mm} Destroyed Structures 1945" "Mean dep. var." "Observations" ///
 "$ R^2$") fmt(0 0 0 3 0 3)) ///
noconstant compress starlevels(* 0.1 ** 0.05 *** 0.01) ///
nolines prehead(\hline\hline) posthead(\hline) label replace

foreach var in rebuilt_homes rebuilt_apartments rebuilt_public_structures{
cmogram `var' running_variable if dist_to_border<50000, ///
cut(0) scatter line(0.5) lowess histopts(bin(15)) qfitci 
}

* ==============================================================================
* Difference in Differences Model - Uber Example
* Stata skills: The use of the hashtag, double hashtag, and formatting dates
* 09/28/2019
* ==============================================================================
use "C:\Users\Luis\Seattle Uber-before and after (1).dta", replace

gen uber = 0
replace uber = 1 if (Year ==2015)
replace uber = 2 if (Year==2010)
drop if uber==0
replace uber =0 if uber==2
gen DUI= 1 if SummarizedOffenseDescription =="DUI"
replace DUI=0 if DUI==.

gen Monday = 1 if DOW=="Mon"
gen Tuesday=1 if DOW=="Tue"
gen Wednesday=1 if DOW=="Wed"
gen Thursday=1 if DOW=="Thu"
gen Friday=1 if DOW=="Fri"
gen Saturday=1 if DOW=="Sat"
gen Sunday=1 if DOW=="Sun"
foreach var in Monday Tuesday Wednesday Thursday Friday Saturday Sunday{
replace `var' = 0 if `var'==.
}
foreach var in Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec{
gen `var'=0
}

replace Jan =1 if (Month==1)
replace Feb =1 if Month ==2
replace Mar =1 if Month ==3
replace Apr =1 if Month ==4
replace May =1 if Month==5
replace Jun =1 if Month ==6
replace Jul=1 if Month ==7
replace Aug=1 if Month==8
replace Sep=1 if Month==9
replace Oct=1 if Month==10
replace Nov=1 if Month==11
replace Dec=1 if Month==12

gen real_day = dofc(DateReported)
format real_day %tdD_M_CY
egen nDUIsPD = total(DUI), by(real_day)

reg nDUIsPD uber##Saturday i.District_sector, robust 

* ==============================================================================
* Using US census data and survey weights for IV estimation using 2sls
* Dates: 09/28/2019
* ==============================================================================

svyset[pweight= pwgtp], vce(brr) brrweight(pwgtp1-pwgtp80) fay(.5)mse

svy: reg EngA ME max sex agep White Black Asian Hisp NES 
est sto T6

svy: reg lnWage EngA max sex agep White Black Asian Hisp NES 
est sto T7

svy: ivregress 2sls lnWage max sex agep Asian Black White Hisp (EngA = ME)
est sto T8

esttab T6 T7 T8 using "Outcomes.tex"
