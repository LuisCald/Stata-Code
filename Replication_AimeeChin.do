import delimited C:\Users\Jrxz12\Desktop\Stata\psam_husa.
*I dropped variables from both housingA and housing B. Bifurcation by states
drop puma adjhsg ags mrgi mrgx srnt faccessp facrp fagsp fbathp
drop fbdsp-fyblp
drop type compothx fulp gasp hfl hotwat insp mhp othsvcex rntm rwatpr smp vacs 
drop grntp multg nr ocpip partner plmprp resmode smocp smx sval

*This is dealing with the personA and personB dataset. This code was ran individually (thus on each dataset)
drop fagep-fyoep
drop rt division puma hins7 intp jwrip mig mlpi mlpj mlpk nwab nwre oip wkl wrk anc drivesp indp naicsp
drop paoc powpuma powsp qtrbir rac2p rac3p rc sciengp sciengrlp
drop sfn sfr mlpa mlpb mlpcd mlpe mlpfg mlph

*To simplify the data, I will focus on individuals who are between the ages of 25-38
*possible question to ask is analyzing when the older immigrants arrive, 
*what is their fate compared to the control? 
gen Age_of_Arrival = agep-(2017-yoep) // At what age did they emmigrate their home
drop if Age_of_Arrival>17 
drop if Age_of_Arrival <0
sort agep
drop if agep<25 
drop if agep >38 
*The reason for this focus is to capture individuals with the same potential earnings
*profiles/same part of their lives. 
*Now we look at place of birth. We drop all US natives. The purpose is bifurcate the data:
*We want an English speaking group where individuals from these countries speak English 
*in their homes and a non-English speaking group, where individuals from these countries 
*have another language besides English as their National tongue.
*There some countries that list English as an official language, but it is not 
*first choice at home
rename pobp POB
rename wagp wages
rename racasn Asian
rename racblk Black
rename racwht White
rename schl EducationalAttainment
gen lnWage = ln(wages)

drop if POB<60 
drop if POB==233
drop if POB==209
drop if POB==210
drop if POB==66
drop if POB==231
drop if POB==440
drop if POB==60
drop if POB==508
drop if POB==328
drop if POB==427
drop if POB==523
drop if POB==236
drop if POB==457
drop if POB==453
drop if POB==421
drop if POB==512
drop if POB==447
drop if POB==511
drop if POB==460
drop if POB==420
drop if POB==444

*Generating the treatment group. NES = non-english speaking country. I simply
*labeled NES=0 for control group (from English speaking countries)
gen NES =1
replace NES=0 if POB==301
replace NES=0 if POB==138
replace NES=0 if POB==139
replace NES=0 if POB==333
replace NES=0 if POB==341
replace NES=0 if POB==140
replace NES=0 if POB==368
replace NES=0 if POB==501
replace NES=0 if POB==119
replace NES=0 if POB==300
replace NES=0 if POB==324
replace NES=0 if POB==323
replace NES=0 if POB==310
replace NES=0 if POB==449
replace NES=0 if POB==78
replace NES=0 if POB==515
replace NES=0 if POB==330
replace NES=0 if POB==429
replace NES=0 if POB==321
replace NES=0 if POB==340
replace NES=0 if POB==339
replace NES=0 if POB==461
replace NES=0 if POB==343

*Creating the Latin American group
gen Hisp = 0
replace Hisp =1 if hisp >1
replace sex=0 if sex==1 // Male
replace sex=1 if sex==2 // Female
*Creating English ability variable, where 3 means very well English ability
gen EngA=0
replace EngA=3 if eng==1
replace EngA=2 if eng==2
replace EngA=1 if eng==3
replace EngA=0 if eng==4
replace EngA=. if eng==.
*Creating Dichotomous variable DAoA = Dichotomous age of arrival - to bifurcate
*those that arrived before age 12 and from 12-17. 

gen DAoA = 0
replace DAoA = 1 if Age_of_Arrival <12
sort DAoA
*Creating and moving variables "Speaks English - not well, well, speaks no english
gen SENW =0
gen SEW =0
gen SEVW =0
gen SNE =0
replace SENW = 1 if EngA == 1
replace SENW=. if EngA==.

replace SEW = 1 if EngA == 2
replace SEW=. if EngA==.

replace SEVW = 1 if EngA == 3
replace SEVW=. if EngA==.

replace SNE = 1 if EngA == 0
replace SNE=. if EngA==.
*_______________________________________________________________________________

*_______________________________________________________________________________
** the above was the data cleaning and structuring of the data. 
use "C:\Users\Jrxz12\Desktop\Stata\Datasets\Merged data of A1-B1.dta", clear
rename wagp wages
gen lnWage = ln(wages)
la var lnWage "Log Annual Wages"
la var EducationalAttainment "Educational Attainment"
la var EngA "Ordinal English Ability"
la var DAoA "Age of Arrival Dummy" 
*This is for NES==1


*Checking Descriptive statistics to check for anomalies in the data
*This one tells me that of those non-english speaking countries, 
*the immigrants that arrive young earn higher wages, attain more education 
*and have greater English ability.
eststo clear
sort DAoA 

eststo count: estpost tabstat lnWage EducationalAttainment EngA, ///
statistics(count) columns(statistics)

eststo ES: estpost tabstat lnWage EducationalAttainment EngA if NES==0, ///
statistics(mean sd) columns(statistics)

eststo NES: estpost tabstat lnWage EducationalAttainment EngA if NES==1, ///
statistics(mean sd) columns(statistics)

eststo diff: estpost ttest lnWage EducationalAttainment EngA, by(NES) unequal
*neat fact: its 0 0 1 because it ignores the first two eststo's and pulls "x" from last eststo

esttab count ES NES diff using "Table_1.tex", ///
cells("count(pattern(1 0 0 0) fmt(0)) mean(pattern(0 1 1 0) fmt(1)) sd(pattern(0 1 1 0) fmt(1)) b(pattern(0 0 0 1) fmt(2)) t(star pattern(0 0 0 1) fmt(2))") nonumber label ///
mtitles("\underline{}" "\underline{English-Speaking Countries}" "\underline{Non-English Speaking Countries}" "\underline{Significance of the difference}") noobs replace

*The old are more likely to speak English well, but this could be because 
*the young are in the better English speaking group - or measurement error
*since people tend to overestimate their abilities.
la var SEVW "Speaks English Very Well"
la var SEW "Speaks English Well"
la var SENW "Speaks English Not Well"
la var SNE "Does not Speak English"
eststo clear 

eststo count: estpost tabstat SEVW SEW SENW SNE, ///
statistics(count) columns(statistics)

eststo ES: estpost tabstat SEVW SEW SENW SNE if NES==0, ///
statistics(mean sd) columns(statistics)

eststo NES: estpost tabstat SEVW SEW SENW SNE if NES==1, ///
statistics(mean sd) columns(statistics)

eststo diff: estpost ttest SEVW SEW SENW SNE, by(NES) unequal
*neat fact: its 0 0 1 because it ignores the first two eststo's and pulls "x" from last eststo

esttab count ES NES diff using "Table_2.tex", ///
cells("count(pattern(1 0 0 0) fmt(0)) mean(pattern(0 1 1 0) fmt(2)) sd(pattern(0 1 1 0) fmt(2)) b(pattern(0 0 0 1) fmt(2)) t(star pattern(0 0 0 1) fmt(2))") nonumber label ///
mtitles("\underline{}" "\underline{English-Speaking Countries}" "\underline{Non-English Speaking Countries}" "\underline{Significance of the difference}") noobs replace

*Now looking at differences if arrived young

eststo clear
sort DAoA 

eststo count: estpost tabstat lnWage EducationalAttainment EngA, ///
statistics(count) columns(statistics)

eststo ES: estpost tabstat lnWage EducationalAttainment EngA if NES==0&DAoA==1, ///
statistics(mean sd) columns(statistics)

eststo NES: estpost tabstat lnWage EducationalAttainment EngA if NES==1&DAoA==1, ///
statistics(mean sd) columns(statistics)

eststo diff: estpost ttest lnWage EducationalAttainment EngA if DAoA==1, by(NES) unequal
*neat fact: its 0 0 1 because it ignores the first two eststo's and pulls "x" from last eststo

esttab count ES NES diff using "Table_3.tex", ///
cells("count(pattern(1 0 0 0) fmt(0)) mean(pattern(0 1 1 0) fmt(1)) sd(pattern(0 1 1 0) fmt(1)) b(pattern(0 0 0 1) fmt(2)) t(star pattern(0 0 0 1) fmt(2))") nonumber label ///
mtitles("\underline{}" "\underline{English-Speaking Countries}" "\underline{Non-English Speaking Countries}" "\underline{Significance of the difference}") noobs replace

eststo clear
eststo count: estpost tabstat SEVW SEW SENW SNE, ///
statistics(count) columns(statistics)

eststo ES: estpost tabstat SEVW SEW SENW SNE if NES==0&DAoA==1, ///
statistics(mean sd) columns(statistics)

eststo NES: estpost tabstat SEVW SEW SENW SNE if NES==1&DAoA==1, ///
statistics(mean sd) columns(statistics)

eststo diff: estpost ttest SEVW SEW SENW SNE if DAoA==1, by(NES) unequal
*neat fact: its 0 0 1 because it ignores the first two eststo's and pulls "x" from last eststo

esttab count ES NES diff using "Table_4.tex", ///
cells("count(pattern(1 0 0 0) fmt(0)) mean(pattern(0 1 1 0) fmt(2)) sd(pattern(0 1 1 0) fmt(2)) b(pattern(0 0 0 1) fmt(2)) t(star pattern(0 0 0 1) fmt(2))") nonumber label ///
mtitles("\underline{}" "\underline{English-Speaking Countries}" "\underline{Non-English Speaking Countries}" "\underline{Significance of the difference}") noobs replace

***********************************************************

*Of significance, hispanics tend to bring their children when they are
*older, a 12% difference
tabstat Age_of_Arrival agep White Black Asian Hisp sex if NES==1, by(DAoA)

sort DAoA
*High School Diploma Achieved. 
by DAoA: count if EducationalAttainment==16 & NES==1
*Bachelor or greater
by DAoA: count if EducationalAttainment>20 & NES==1

*This is for NES==0

tabstat lnEarnings EducationalAttainment EngA if NES==0, by(DAoA)
*Oddly, those immigrants who arrive young from English speaking countries
*have a significantly less English ability than those that arrive late
tabstat EngA if NES==0, by( DAoA )
*Virtually, zero people speak not well
tabstat SENW if NES==0, by( DAoA )
*The rest is consistent with Aimee Chin's paper
tabstat SEW if NES==0, by( DAoA )
tabstat SEVW if NES==0, by( DAoA )

tabstat Age_of_Arrival agep White Black Asian Hisp sex if NES==0, by(DAoA)
tabstat EducationalAttainment if NES==0, by(DAoA)

*Those that arrive young attain more education
by DAoA: count if EducationalAttainment==16 & NES==0
by DAoA: count if EducationalAttainment>20 & NES==0

*Appending the other dataset
append using "C:\Users\Jrxz12\Desktop\Stata\Datasets\PersonB1-after all variable 
additions 14782.dta"

*Creating the interaction variable 'Arrived Young from Non-English' Speaking country
gen AYNE = DAoA*NES


gen max = max(0, Age_of_Arrival-11)

gen ME = max*NES

gen SE1 = 0
gen SE2 = 0

replace SE1=1 if SENW==1 | SEW==1 | SEVW==1
replace SE1=. if EngA==.
replace SE2=1 if SEW ==1 | SEVW==1
replace SE2=. if EngA==.
* ==============================================================================
* Saved data
use "C:\Users\Jrxz12\Desktop\Stata\Datasets\September20", clear


*Creating the survey set, so when regressions are ran, the standard errors are 
*precise; given the regression is being ran through 80 replicate weights
svyset[pweight= pwgtp], vce(brr) brrweight(pwgtp1-pwgtp80) fay(.5)mse

svy: reg lnWage EngA ME White Black Asian sex

**Table 1 needed of descriptive stats
la var SE1 "Speaks English not well, well or very well"
la var SE2 "Speaks English well or very well"
la var AYNE "Arrived young*non-English-speaking country of birth"
la var DAoA "Arrived young"
la var NES "non-English speaking country of birth"
la var EngA "Ordinal English Ability"
** Table 2** 
*Speaks English not well, well or very well
svy: reg SE1 AYNE DAoA NES agep White Black Asian Hisp sex
estadd ysumm
est sto T1
*Speaks English well, very well
svy: reg SE2 AYNE DAoA NES agep White Black Asian Hisp sex
estadd ysumm
est sto T2
*Speaks English very well
svy: reg SEVW AYNE DAoA NES agep White Black Asian Hisp sex
estadd ysumm
est sto T3

svy: reg EngA i.AYNE DAoA NES agep White Black Asian Hisp sex
estadd ysumm
est sto T4

svy: reg lnWage AYNE DAoA NES agep White Black Asian Hisp sex
estadd ysumm
est sto T5

esttab T1 T2 T3 T4 T5 using "Table_main.tex", keep (AYNE DAoA NES) ///
b(4) se stats(ymean N r2, labels( "Mean dep. var." "Observations" "$ R^2$") fmt(4 0 3)) ///
noconstant compress starlevels(* 0.1 ** 0.05 *** 0.01) ///
nolines prehead(\hline\hline) posthead(\hline) label replace

*Using logistical Regression
eststo clear
svy: logi SE1 i.AYNE i.DAoA i.NES agep White Black Asian Hisp sex
eststo: estpost margins, dydx(AYNE DAoA NES)

svy: logi SE2 i.AYNE i.DAoA i.NES agep White Black Asian Hisp sex
eststo: estpost margins, dydx(AYNE DAoA NES)

*Speaks English very well
svy: logi SEVW i.AYNE i.DAoA i.NES agep White Black Asian Hisp sex
eststo: estpost margins, dydx(AYNE DAoA NES)


svy: ologit EngA i.AYNE i.DAoA i.NES agep White Black Asian Hisp sex
eststo: estpost margins, dydx(AYNE DAoA NES)

esttab using "Table_main_robustness.tex", keep (1.AYNE 1.DAoA 1.NES) ///
b(4) se ///
noconstant compress starlevels(* 0.1 ** 0.05 *** 0.01) ///
nolines prehead(\hline\hline) posthead(\hline) label replace



*Table 3, 4 linear regressions and two 2sls. The ivregress is necessary since 
*English ability is endogenous. I suspect ME to be exogenous and correlated with EngA

*With no age at arrival dummy, yes NES dummy
la var ME "max (0, age at arrival - 11)*non-English speaking place of birth"
la var max "max (0, age at arrival - 11)"

program define makedum1
	local i = 0
	while `i' <= 17 {
		gen Age_of_Arrival`i' = Age_of_Arrival == `i'
	local i = `i' + 1
	}
end
makedum1;
eststo clear
svy: reg EngA ME max sex agep White Black Asian Hisp i.POB  
estadd local control1 "No", replace
estadd local control2 "Yes", replace
estadd ysumm
est sto A

local control1 Age_of_Arrival_dummies
local control2 birth_place_dummies
svy: reg EngA ME sex agep White Black Asian Hisp Age_of_Arrival0-Age_of_Arrival17 i.POB 
estadd local control1 "Yes", replace
estadd local control2 "Yes", replace
estadd ysumm
est sto B

svy: reg lnWage EngA max sex agep White Black Asian Hisp i.POB 
estadd local control1 "No", replace
estadd local control2 "Yes", replace
estadd ysumm
est sto C

svy: reg lnWage EngA sex agep White Black Asian Hisp Age_of_Arrival0-Age_of_Arrival17 i.POB 
estadd local control1 "Yes", replace
estadd local control2 "Yes", replace
estadd ysumm
est sto D

ivregress 2sls lnWage max sex agep Asian Black White Hisp i.POB (EngA = ME) 
estadd local control1 "No", replace
estadd local control2 "Yes", replace
estadd ysumm
est sto E

ivregress 2sls lnWage agep sex Asian Black White Hisp ///
Age_of_Arrival0-Age_of_Arrival17 i.POB (EngA = ME) ///
estadd local control1 "Yes", replace
estadd local control2 "Yes", replace
estadd ysumm
est sto F

esttab A B C D E F using "a.tex", keep (EngA ME max) ///
b(4) se stats(control1 control2 ymean N r2, ///
labels("\hspace{2mm} Age at Arrival dummies" "\hspace{2mm} Country of Birth dummies" "Mean dep. var." "Observations" "$ R^2$") ///
fmt(0 0 3 0 3)) noconstant compress starlevels(* 0.1 ** 0.05 *** 0.01) ///
nolines prehead(\hline\hline) posthead(\hline) label replace
*So far i am seeing that coming from an Non english speaking country young
*can have positive effects on your wages

*Creating a fourth table to illustrate differences between regions/countries
*NC means analysis with "No Canada"
gen NC =1
replace NC =0 if POB==301
*NCESWAN means no Canada, England, Scotland, Wales, Australia and New Zealand
gen NCESWAN = 1
replace NCESWAN =0 if POB==301
replace NCESWAN =0 if POB==139
replace NCESWAN =0 if POB==138
replace NCESWAN =0 if POB==140
replace NCESWAN =0 if POB==501
replace NCESWAN =0 if POB==515

*CC means Caribbean Countries only, hence CC=0
gen CC=0
replace CC=1 if POB==321
replace CC=1 if POB==323
replace CC=1 if POB==324
replace CC=1 if POB==327
replace CC=1 if POB==328
replace CC=1 if POB==329
replace CC=1 if POB==330
replace CC=1 if POB==332
replace CC=1 if POB==333
replace CC=1 if POB==339
replace CC=1 if POB==340
replace CC=1 if POB==341
*ALL
eststo clear
svy: reg lnWage EngA Age_of_Arrival0-Age_of_Arrival17 i.POB ///
sex agep White Black Asian Hisp  
estadd ysumm
eststo T12

ivregress 2sls lnWage Age_of_Arrival0-Age_of_Arrival17 i.POB ///
sex agep White Black Asian Hisp (EngA = ME)
estadd ysumm
eststo T13

svy: reg EducationalAttainment EngA Age_of_Arrival0-Age_of_Arrival17 i.POB ///
sex agep White Black Asian Hisp  
estadd ysumm
eststo T14

ivregress 2sls EducationalAttainment Age_of_Arrival0-Age_of_Arrival17 i.POB ///
sex agep White Black Asian Hisp (EngA = ME)
estadd ysumm
eststo T15

esttab T12 T13 T14 T15 using "c.tex", keep (EngA) ///
b(4) se stats(ymean N r2, ///
labels("Mean dep. var." "Observations" "$ R^2$") ///
fmt(3 0 3)) noconstant compress starlevels(* 0.1 ** 0.05 *** 0.01) ///
nolines prehead(\hline\hline) posthead(\hline) label replace
*No Canada
eststo clear
svy: reg lnWage EngA Age_of_Arrival0-Age_of_Arrival17 i.POB ///
sex agep White Black Asian Hisp if NC==1
estadd ysumm
est sto T16

ivregress 2sls lnWage Age_of_Arrival0-Age_of_Arrival17 i.POB ///
sex agep White Black Asian Hisp (EngA = ME) if NC==1
estadd ysumm
est sto T17

svy: reg EducationalAttainment EngA Age_of_Arrival0-Age_of_Arrival17 i.POB ///
sex agep White Black Asian Hisp if NC==1
estadd ysumm
est sto T18

ivregress 2sls EducationalAttainment Age_of_Arrival0-Age_of_Arrival17 i.POB ///
sex agep White Black Asian Hisp (EngA = ME) if NC==1
estadd ysumm
est sto T19

esttab T16 T17 T18 T19 using "d.tex", keep (EngA) ///
b(4) se stats(ymean N r2, ///
labels("Mean dep. var." "Observations" "$ R^2$") ///
fmt(3 0 3)) noconstant compress starlevels(* 0.1 ** 0.05 *** 0.01) ///
nolines prehead(\hline\hline) posthead(\hline) label replace
* no Canada, England, Scotland, Wales, Australia and New Zealand
eststo clear

svy: reg lnWage EngA Age_of_Arrival0-Age_of_Arrival17 i.POB ///
sex agep White Black Asian Hisp   if NCESWAN==1
estadd ysumm
est sto T20

ivregress 2sls lnWage Age_of_Arrival0-Age_of_Arrival17 i.POB ///
sex agep White Black Asian Hisp (EngA = ME) if NCESWAN==1
estadd ysumm
est sto T21

svy: reg EducationalAttainment EngA Age_of_Arrival0-Age_of_Arrival17 i.POB ///
sex agep White Black Asian Hisp if NCESWAN==1
estadd ysumm
est sto T22

ivregress 2sls EducationalAttainment Age_of_Arrival0-Age_of_Arrival17 i.POB ///
sex agep White Black Asian Hisp (EngA = ME) if NCESWAN==1
estadd ysumm
est sto T23

esttab T20 T21 T22 T23 using "e.tex", keep (EngA) ///
b(4) se stats(ymean N r2, ///
labels("Mean dep. var." "Observations" "$ R^2$") ///
fmt(3 0 3)) noconstant compress starlevels(* 0.1 ** 0.05 *** 0.01) ///
nolines prehead(\hline\hline) posthead(\hline) label replace
*CC means Caribbean Countries only, hence CC=0
eststo clear

svy: reg lnWage EngA Age_of_Arrival0-Age_of_Arrival17 i.POB ///
sex agep White Black Asian Hisp  if CC==1
estadd ysumm
est sto T24

ivregress 2sls lnWage Age_of_Arrival0-Age_of_Arrival17 i.POB ///
sex agep White Black Asian Hisp (EngA = ME)if CC==1
estadd ysumm
est sto T25

svy: reg EducationalAttainment EngA Age_of_Arrival0-Age_of_Arrival17 i.POB ///
sex agep White Black Asian Hisp if CC==1
estadd ysumm
est sto T26

ivregress 2sls EducationalAttainment Age_of_Arrival0-Age_of_Arrival17 i.POB ///
sex agep White Black Asian Hisp (EngA = ME) if CC==1
estadd ysumm
est sto T27

esttab T24 T25 T26 T27 using "f.tex", keep (EngA) ///
b(4) se stats(ymean N r2, ///
labels("Mean dep. var." "Observations" "$ R^2$") ///
fmt(3 0 3)) noconstant compress starlevels(* 0.1 ** 0.05 *** 0.01) ///
nolines prehead(\hline\hline) posthead(\hline) label replace

*I believe clustering is the better method
eststo clear
eststo: ivregress 2sls lnWage Age_of_Arrival0-Age_of_Arrival17  ///
sex agep White Black Asian Hisp (EngA = ME), cluster(POB)
estadd ysumm


eststo: ivregress 2sls EducationalAttainment Age_of_Arrival0-Age_of_Arrival17  ///
sex agep White Black Asian Hisp (EngA = ME), cluster(POB)
estadd ysumm

esttab using "g.tex", keep (EngA) ///
b(4) se stats(ymean N r2, ///
labels("Mean dep. var." "Observations" "$ R^2$") ///
fmt(3 0 3)) noconstant compress starlevels(* 0.1 ** 0.05 *** 0.01) ///
nolines prehead(\hline\hline) posthead(\hline) label replace

eststo clear

eststo: ivregress 2sls lnWage Age_of_Arrival0-Age_of_Arrival17 ///
sex agep White Black Asian Hisp (EngA = ME) if NC==1, cluster(POB)
estadd ysumm


eststo: ivregress 2sls EducationalAttainment Age_of_Arrival0-Age_of_Arrival17  ///
sex agep White Black Asian Hisp (EngA = ME) if NC==1, cluster(POB)
estadd ysumm

esttab using "h.tex", keep (EngA) ///
b(4) se stats(ymean N r2, ///
labels("Mean dep. var." "Observations" "$ R^2$") ///
fmt(3 0 3)) noconstant compress starlevels(* 0.1 ** 0.05 *** 0.01) ///
nolines prehead(\hline\hline) posthead(\hline) label replace

eststo clear

eststo: ivregress 2sls lnWage Age_of_Arrival0-Age_of_Arrival17  ///
sex agep White Black Asian Hisp (EngA = ME) if NCESWAN==1, cluster(POB)
estadd ysumm


eststo: ivregress 2sls EducationalAttainment Age_of_Arrival0-Age_of_Arrival17  ///
sex agep White Black Asian Hisp (EngA = ME) if NCESWAN==1, cluster(POB)
estadd ysumm

esttab using "i.tex", keep (EngA) ///
b(4) se stats(ymean N r2, ///
labels("Mean dep. var." "Observations" "$ R^2$") ///
fmt(3 0 3)) noconstant compress starlevels(* 0.1 ** 0.05 *** 0.01) ///
nolines prehead(\hline\hline) posthead(\hline) label replace

eststo clear

eststo: ivregress 2sls lnWage Age_of_Arrival0-Age_of_Arrival17  ///
sex agep White Black Asian Hisp (EngA = ME) if CC==1, cluster(POB)
estadd ysumm


eststo: ivregress 2sls EducationalAttainment Age_of_Arrival0-Age_of_Arrival17  ///
sex agep White Black Asian Hisp (EngA = ME) if CC==1, cluster(POB)
estadd ysumm

esttab using "j.tex", keep (EngA) ///
b(4) se stats(ymean N r2, ///
labels("Mean dep. var." "Observations" "$ R^2$") ///
fmt(3 0 3)) noconstant compress starlevels(* 0.1 ** 0.05 *** 0.01) ///
nolines prehead(\hline\hline) posthead(\hline) label replace
**************************************************************************
















****************************************************************************
*Holding educational attaintment fixed at certain levels
constraint define 1 EducationalAttainment =.06
svy: cnsreg lnWage EngA NES Age_of_Arrival EducationalAttainment agep sex White Black Asian Hisp, constraint (1)
est sto T28

constraint define 1 EducationalAttainment =.07
svy: cnsreg lnWage EngA NES Age_of_Arrival EducationalAttainment agep sex White Black Asian Hisp, constraint (1)
est sto T29

constraint define 1 EducationalAttainment =.08
svy: cnsreg lnWage EngA NES Age_of_Arrival EducationalAttainment agep sex White Black Asian Hisp, constraint (1)
est sto T30

constraint define 1 EducationalAttainment =.09
svy: cnsreg lnWage EngA NES Age_of_Arrival EducationalAttainment agep sex White Black Asian Hisp, constraint (1)
est sto T31

svy: ivregress 2sls lnWage NES Age_of_Arrival max EducationalAttainment agep sex White Black Asian Hisp (EngA = ME) 
est sto T32

esttab T28 T29 T30 T31 T32 


