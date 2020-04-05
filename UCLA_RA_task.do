* Import process
cd "C:\Users\Jrxz12\Desktop\UCLA_task\ra-task-data"
import delimited using "firm.tsv"
unique firm ano // To check the unique identifier
save "firm.dta"  
import delimited using "work.tsv", clear

* Merge
merge m:1 firm ano using "firm.dta"  // 41 unmatched

					* Label values and Label variables *
					* -------------------------------- *
* Gender
tab sex // to see current designations
gen male = .
replace male=1 if sex=="M"
replace male=0 if sex=="F"
label define male_label 0 "Female" 1 "Male"
label values male male_label
la var male "Male"

* Work hours
summ horas, d  // to look for weird behavior
rename horas work_hours
la var work_hours "Work Hours"

* Wages in multiples of Brazil’s minimum wage, 0 is equivalent to missing
replace rem=. if rem==0
summ rem, d  // noticed rather large values toward the end of the distribution
iqr rem  // Outlier analysis. There's evidence of outliers (high inner/outer fence). 
rename rem wages
la var wages "Wage (in multiples)"

* Work experience in months
summ exp, d  // data is well behaved
gen exp_years = .
	replace exp_years=exp/12  // more natural to see the effect of an extra year
							  // of experience. also, looking for weirdness in exp_years and idade
la var exp "Work Experience (in months)"
la var exp_years "Work Experience (in years)"

* Calendar year
tab ano  // 2005-2010 data
rename ano year
la var year "Year"

* Age
summ idade, d  // there are minors
rename idade age
gen age2 = age^2
replace age2=. if age==. 
gen minor = (age<18 & !missing(age))
la var age "Age"
la var age2 "Age-squared"

* Education level
tab edu
sort edu
encode edu, gen(edu_cat)
replace edu_cat=. if edu_cat==10 | edu_cat==1  // For the NA and 00 identified value 
label define edu_cat_label 2 "Less than elementary school" 3 "Elementary school" 4 ///
 "Some middle school" 5 "Middle school" 6 "Some high school" 7 "High school" 8 ///
 "Some higher education" 9 "Higher education degree"
label values edu_cat edu_cat_label
la var edu_cat "Education Level"

* State
sort state
encode state, gen(firm_state)  // No need to replace missing since state had
							   // empty strings. These equate missing in encode.

					*           Subset Variables       *
					* -------------------------------- *
		* note: stata dropped the leading zeros for industry. So for agriculture,
		* it is a 4-digit code. With the leading zero, the code is:
		* gen agr = 0
		* replace agr=1 if substr(string(industry), 1, 2) == "01" | substr(string(industry), 1, 2) == "02"
		* replace agr=. if industry==.
		* another way is to sort, encode then abuse codings

* Agriculture sector
gen agriculture = 0
replace agriculture=1 if industry < 3000  // abusing the fact that industry is numeric
replace agriculture=. if industry==.

* Full-time workers
gen full_time = 0
replace full_time=1 if work_hours==44
replace full_time=. if work_hours==.

* Firms with AT LEAST 5 full time employees. 
egen n_workers = count(worker) if work_hours==44, by(firm)  // Since this isn't a panel data analysis		
										  // I'll ignore the fact that there are sometimes  
										  // two of the same workers across years. 		
										  // I figured this must be the case since
										  // if I subset to firms with 5 full time 
										  // employees per year, that would reduce
										  // the obs count significantly.
										  


					*        Regression Model          *
					* -------------------------------- *
					
* define locals for controls and globals for notes
local controls set_of_controls
local fe year_firm
global unit "The unit of observation is a full-time Brazilian worker outside the agricultural sector. Further, only workers belonging to firms with more than 5 full-time employees are considered. Data is collected between 2005-2010."
global wage "Wage is earnings of the worker in multiples of Brazil’s minimum wage."
global Male "Male is 1 for male workers, 0 for female."
global other "Base controls include age, age-squared, level of education and 2 sets of fixed effects."
global FE "The fixed effects are for year and firm."
global se "Cluster robust standard errors are in parentheses."
global sig "* indicates significance at the 10 percent level, ** at the 5 percent level, *** at the 1 percent level."


* Regression 
eststo clear
eststo: reg wages i.male ib2.edu_cat age age2 i.year i.firm /// 
if agriculture==0 & full_time==1 & n_workers>=5, cluster(firm) 
estadd ysumm
estadd local set_of_controls "Yes", replace
estadd local year_firm "Yes", replace

* To see in Latex
esttab using "UCLA_task.tex", label keep(1.male 3.edu_cat 4.edu_cat ///
5.edu_cat 6.edu_cat 7.edu_cat 8.edu_cat) b(3) /// 
addnotes($unit $wage $Male $other $FE $se $sig) ///
se stats(set_of_controls year_firm ymean N r2, labels("\hspace{2mm} Base Controls" "\hspace{2mm} Year and Firm Fixed Effects" "Mean dep. var." "Observations" "$ R^2$") ///
fmt(0 0 3 0 3)) noconstant compress starlevels(* 0.1 ** 0.05 *** 0.01) ///
nolines prehead(\hline\hline) posthead(\hline) replace
		
					*              Plots               *
					* -------------------------------- *	
* Partial Regression Plot
avplot male, title("Partial Regression Plot of Wages")
graph export "partial.png", as(png) name("Graph") replace

* Predicted vs. Actual plot
predict wages_hat
graph twoway (lfitci wages_hat wages) (scatter wages_hat wages ) if e(sample)==1, ///
title("Regression Plot") ytitle("Predicted Values of Wages")
graph export "reg_plot.png", as(png) name("Graph") replace

					
					*        Summary Statistics        *
					* -------------------------------- *		
eststo esample: estpost tabstat wages ///
male edu_cat age if e(sample)==1, ///
statistics(mean sd p10 p25 p50 p75 p90) columns(statistics)

* For Latex
esttab esample using "desc.tex", ///
cells("mean(pattern(1) fmt(3)) sd(pattern(1) fmt(3)) p10(pattern(1) fmt(3)) p25(pattern(1) fmt(3)) p50(pattern(1) fmt(3)) p75(pattern(1)fmt(3)) p90(pattern(1) fmt(3))") nonumber label ///
noobs replace

					
	
					

