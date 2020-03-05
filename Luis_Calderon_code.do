* Setup directory and import data
cd "C:\Users\Jrxz12\Desktop\pre_doc_tasks"
use "cps_wages_LFP_10pct.dta", replace

			* DATA MANAGEMENT
			* ===============
* Assume observations are independent for now
gen id = _n
svyset id [pweight= wtsupp]

* For people above 25 years of age
gen males_over_25 = (age>25 & sex==1)
replace males_over_25=. if age==.|sex==.

* Generate log wages to measure percent change and removes those with zero wages
svy: mean wage, over(year)
gen log_wages = log(wage)
svy: mean log_wages, over(year)

* Create race/ethnic groups to analyze
gen black = (race==200)
gen asian = (race==651)
gen hisp = (hisp!=0)

* Correct for missing
foreach var in black white asian{
replace `var'=. if race==.
}

foreach var in hisp{
replace `var'=. if hispan==.
}

* Create race/ethinic groups variable
gen groups = .
replace groups= 1 if white==1
replace groups= 2 if black==1
replace groups= 3 if asian==1
replace groups= 4 if hisp==1

* Demean wage
bysort year: egen avg_logwage = mean(log_wages)
gen demeaned_wage = log_wages - avg_logwage

* ==============================================================================
			* GRAPHS
			* ======

* Create graphs. PLEASE PRESERVE and RESTORE manually. Known bug in Stata 
* Outcomes: Log Hourly Wages and Labor Force Participation
* ==============================================================================

* Collapse data by year and skill 
preserve
collapse (mean) demeaned_wage log_wages lfp, by(year skilled)

* Detrend wage
reg log_wages year
predict wage_res, residuals

* Set graph style and label vars
grstyle init 
grstyle set plain, grid
grstyle set legend 10, inside
la var log_wages "Log-Hourly Wage"
la var demeaned_wage "Demeaned Log-Hourly Wage"
la var wage_res "Detrended Log-Hourly Wage"
la var lfp "Labor Force Participation"

* Graph: skill vs unskilled for demeaned wage, detrended wage, log wage, and lfp
foreach var in demeaned_wage wage_res log_wages lfp{
twoway (line `var' year if skilled==1) (line `var' year if skilled==0), ytitle(`: var label') xtitle(Years) legend(order(1 "Skilled Labor" 2 "Unskilled Labor")) ylabel(, format(%9.0g)) 
graph export overall_diff_`var'.png, replace
}
restore, preserve
* ==============================================================================
* Considering Males over 25 years of age
* ==============================================================================

* Skill vs unskilled overall, outcome: labor force participation
drop if males_over_25 ==0
collapse (mean) lfp, by(year skilled)

grstyle init 
grstyle set plain, grid
grstyle set legend 10, inside
la var lfp "Labor Force Participation"

foreach var in lfp{
tw (line `var' year if skilled==1) (line `var' year if skilled==0), ytitle(`: var label') xtitle(Years) legend(order(1 "Skilled Labor" 2 "Unskilled Labor")) ylabel(, format(%9.0g))
graph export overall_diff_`var'25.png, replace
}

* Skill vs unskilled by race/ethnicities, outcome: labor force participation
restore, preserve
drop if males_over_25 ==0 
collapse (mean) lfp if skilled==1, by(year groups)
xtset groups year

grstyle init 
grstyle set plain, grid
grstyle set legend 10, inside
la var lfp "Labor Force Participation"

* Graph 4 plots, observing lfp amongst all groups for skilled laborers
 twoway (tsline D.lfp if group==1) (tsline D.lfp if group==2) (tsline D.lfp if group==3) (tsline D.lfp if group==4), xtitle(Years) ytitle(Labor Force Participation) legend(order(1 "White" 2 "Black" 3 "Asian" 4 "Hispanic" )) ylabel(, format(%9.0g)) 
graph export FDgrps_lpc_all.png, replace

restore, preserve
drop if males_over_25 ==0 
collapse (mean) lfp if skilled==0, by(year groups)
xtset groups year

grstyle init 
grstyle set plain, grid
grstyle set legend 10, inside
la var lfp "Labor Force Participation"

* Graph 4 plots, observing lfp amongst all groups for unskilled laborers
 twoway (tsline D.lfp if group==1) (tsline D.lfp if group==2) (tsline D.lfp if group==3) (tsline D.lfp if group==4), xtitle(Years) ytitle(Labor Force Participation) legend(order(1 "White" 2 "Black" 3 "Asian" 4 "Hispanic" )) ylabel(, format(%9.0g)) 
graph export FDgrps_lpc_all_unskilled.png, replace

* Skill vs unskilled by age, outcome: labor force participation
restore, preserve
drop if males_over_25 ==0 
collapse (mean) lfp, by(year skilled age_group)

grstyle init 
grstyle set plain, grid
grstyle set legend 0
la var lfp "Labor Force Participation"

forval i = 0/1{
tw (line lfp year if age_group==1 & skilled==`i') (line lfp year if age_group==2 & skilled==`i') (line lfp year if age_group==3 & skilled==`i'), xtitle(Years) ytitle(Labor Force Participation) legend(order(1 "25-45 years old" 2 "45-65 years old" 3 "> 65 years old")) ylabel(, format(%9.0g))
graph export age_lfp_`i'.png, replace
}
}

			* DESCRIPTIVE STATISTICS
			* ======================
eststo clear
foreach var in lfp log_wages{
eststo: svy: mean `var', over(skilled)
eststo:  svy: reg `var' skilled
eststo:  svy: mean `var' if males_over_25 ==1, over(skilled)
eststo:  svy: reg `var' skilled if males_over_25 ==1
}


			* REGRESSIONS
			* ===========
use "cps_wages_LFP_10pct.dta", replace
gen id = _n
gen age_sq = age^2

* Assume observations are independent for now
svyset id [pweight= wtsupp]

* Locals for controls
local demographics control_dem
local state_fe stfe
local year_fe years

* Regression on skill 
eststo clear
foreach var in log_wages lfp{
eststo: svy: reg `var' skilled white black asian i.statefip hisp sex age age_sq i.year 
estadd ysumm
estadd local demographics "Yes", replace
estadd local state_fe "Yes", replace
estadd local year_fe "Yes", replace

}

esttab using "outcomes.tex", label b(3) /// 
se stats(demographics state_fe year_fe ymean N r2, labels("\hspace{2mm} Demographics" "\hspace{2mm} State Fixed Effects" "\hspace{2mm} Year Dummies" "Mean dep. var." "Observations" "$ R^2$") ///
fmt(0 0 0 3 0 3)) noconstant compress starlevels(* 0.1 ** 0.05 *** 0.01) replace 
