********************************************************************************
** PROJECT *********************************************************************
********************************************************************************

* ------------------------------------------------------------------------------
* data - handling
* ------------------------------------------------------------------------------
use "C:\Users\Jrxz12\Desktop\School\Research_Module\Datasets_RM\ESS8e02_1.dta", clear
merge 1:1 cntry idno using "C:\Users\Jrxz12\Desktop\School\Research_Module\Datasets_RM\ESS8_psustuff.dta", force


* Variables of interest 

* Trust and believers
gen people_trust_exp = (ppltrst==10|ppltrst==9) 
gen climate_believers = (impenv ==1|impenv ==2) 


* Generate variables  
gen age2 = agea*agea
gen male = gndr
replace male=0 if gndr==2
gen farm = (domicil==4|domicil==5)
egen edu_cat = cut(eduyrs), at(6, 9, 12, 16, 20, 54)
replace edu_cat=1 if edu_cat==6
replace edu_cat=2 if edu_cat==9
replace edu_cat=3 if edu_cat==12
replace edu_cat=4 if edu_cat==16
replace edu_cat=5 if edu_cat==20

* survey weight
gen weight = pspwght*pweight

* VCE is linearized. Without surveyset, we assume simple random sampling. 
* generate cstrata = floor(sqrt(2*stratum-1))
* egen upsu = group(stratum psu)
svyset psu [pweight=weight], strata(stratum) single(cen) 
svydescribe 


* channels for PEB: country, left, child at home, trust in gov
encode(cntry), gen(country)
gen left = (lrscale<4)
gen child_home = (chldhm==1)
gen un_trust = (trstun==10)
gen prl_trust = (trstprl==10)
gen eu_trust = (trstep==10)
di "World Risk Index"
di "trust in institutions"

gen religious = (rlgdgr>=8)
gen worried = (wrclmch>=4)
replace worried=. if wrclmch==.d|wrclmch==.c|wrclmch==.b|wrclmch==.a
* dependent variables to consider: PEB, * Constructing index 
gen country_action = (gvsrdcc>=8)
gen ind_coop = (lklmten>7)
replace ind_coop=. if lklmten==.

gen responsibility = (ccrdprs==10|ccrdprs==9)
gen energy_reduce = (rdcenr==4|rdcenr==5|rdcenr==6)
gen buy_eco = (eneffap==8|eneffap==9|eneffap==10)

replace rdcenr=. if rdcenr==55
foreach var in responsibility{
replace `var'=. if ccrdprs==.d
replace `var'=. if ccrdprs==.c
replace `var'=. if ccrdprs==.b
replace `var'=. if ccrdprs==.a
}

foreach var in energy_reduce{
replace `var'=. if rdcenr==.a
replace `var'=. if rdcenr==.b
replace `var'=. if rdcenr==.c
replace `var'=. if rdcenr==.d
replace `var'=. if rdcenr==55
}

foreach var in buy_eco{
replace `var'=. if eneffap==.a
replace `var'=. if eneffap==.b
replace `var'=. if eneffap==.c
replace `var'=. if eneffap==.d
}


* Make PEB index #1
svy: mean energy_reduce buy_eco responsibility
estat sd

gen z_energy_reduce = (energy_reduce - .6986119)/.4588665
gen z_buy_eco = (buy_eco - .620314)/.4853146
gen z_responsibility = (responsibility - .1210004)/.3261317

gen z_proxysum = z_energy_reduce + z_buy_eco + z_responsibility
svy: mean z_proxysum
estat sd

gen z_proxy_PEB = z_proxysum/2.05121

gen string_z_proxy_PEB = string(z_proxy_PEB)
gen PEB1 = .
replace PEB1=1 if string_z_proxy_PEB=="-1.546238"
replace PEB1=2 if string_z_proxy_PEB=="-.5416996"
replace PEB1=2 if string_z_proxy_PEB=="-.4838002"
replace PEB1=3 if string_z_proxy_PEB=="-.0513906"
replace PEB1=4 if string_z_proxy_PEB==".5207381"
replace PEB1=5 if string_z_proxy_PEB==".9531478"
replace PEB1=5 if string_z_proxy_PEB=="1.011047"
replace PEB1=6 if string_z_proxy_PEB=="2.015586"


* Make PEB index #2
gen fossil_fuel_tax = (inctxff==1)
gen subsidy_renewal = (sbsrnen==1)
gen ban_appliance = (banhhap==1)

foreach var in fossil_fuel_tax{
replace `var'=. if isco08==.d
replace `var'=. if isco08==.c
replace `var'=. if isco08==.b
replace `var'=. if isco08==.a
}

foreach var in subsidy_renewal{
replace `var'=. if isco08==.d
replace `var'=. if isco08==.c
replace `var'=. if isco08==.b
replace `var'=. if isco08==.a
}

foreach var in ban_appliance{
replace `var'=. if isco08==.d
replace `var'=. if isco08==.c
replace `var'=. if isco08==.b
replace `var'=. if isco08==.a
}

svy: mean fossil_fuel_tax subsidy_renewal ban_appliance
estat sd

gen z_fossil_fuel_tax = (fossil_fuel_tax - .0613681)/.2400072
gen z_subsidy_renewal = (subsidy_renewal - .29955)/.4580666
gen z_ban_appliance = (ban_appliance - .2157133)/.4113214

gen z_proxysum2 = z_fossil_fuel_tax + z_subsidy_renewal + z_ban_appliance
svy: mean z_proxysum2
estat sd

gen z_proxy_PEB2 = z_proxysum2/2.094415


******************************************************************************
gen pol_intr = (polintr==1)
gen climate_awareness = (clmthgt2==4| clmthgt2==5)

* Label Variables 

la var agea "Age"
la var age2 "Age-squared"
la var people_trust_exp "Generalized Trust"
la var country "Country"
la var male "Male"
la var hinctnta "Household Income"
la var eduyrs "Years of Education"
la var edu_cat "Categorical Education"

la var child_home "Child at home"
la var left "Politically Left"
la var un_trust "Trust in the U.N."
la var prl_trust "Trust in the Country's Parliament"
la var eu_trust "Trust in the European Parliament"
la var farm "Living on a farm"
la var climate_believers "Climate Believers"
la var country_action "Belief in Government Cooperation"


* science and engineering professional, physicists, chemists, geologists and geophysicists, biologists botanists zoologists,  science an engineering associate professional, chemical and physical science technicians, chemical engineering technicians
gen science_job = (isco08==2100|isco08==2111|isco08==2113|isco08==2114|isco08==2131|isco08==2132|isco08==2133|isco08==2143|isco08==3100|isco08==3111|isco08==3116|isco08==3119|isco08==3142|isco08==3143|isco08==3257)
foreach var in science_job{
replace `var'=. if isco08==.d
replace `var'=. if isco08==.c
replace `var'=. if isco08==.b
replace `var'=. if isco08==.a
}

gen scientists = (nacer2==72|science_job==1)
gen gov_empl = (tporgwk==1)

* To account for missing


foreach var in pol_intr{
replace `var'=. if polintr==.d
replace `var'=. if polintr==.c
replace `var'=. if polintr==.b
replace `var'=. if polintr==.a
}

foreach var in gov_empl{
replace `var'=. if tporgwk==.d
replace `var'=. if tporgwk==.c
replace `var'=. if tporgwk==.b
replace `var'=. if tporgwk==.a
}


foreach var in agricultural_job{
replace `var'=. if isco08==.d
replace `var'=. if isco08==.c
replace `var'=. if isco08==.b
replace `var'=. if isco08==.a
}

foreach var in scientists{
replace `var'=. if nacer2==.d
replace `var'=. if nacer2==.c
replace `var'=. if nacer2==.b
replace `var'=. if nacer2==.a
}

foreach var in people_trust_exp{
replace `var'=. if ppltrst==.d
replace `var'=. if ppltrst==.c
replace `var'=. if ppltrst==.b
replace `var'=. if ppltrst==.a
}

foreach var in climate_believers{
replace `var'=. if impenv==.d
replace `var'=. if impenv==.c
replace `var'=. if impenv==.b
replace `var'=. if impenv==.a
}

foreach var in left{
replace `var'=. if lrscale==.d
replace `var'=. if lrscale==.c
replace `var'=. if lrscale==.b
replace `var'=. if lrscale==.a
}

foreach var in child_home{
replace `var'=. if chldhm==.d
replace `var'=. if chldhm==.c
replace `var'=. if chldhm==.b
replace `var'=. if chldhm==.a
}

foreach var in eduyrs{
replace `var'=. if eduyrs==.d
replace `var'=. if eduyrs==.c
replace `var'=. if eduyrs==.b
replace `var'=. if eduyrs==.a
} 

foreach var in edu_cat{
replace `var'=. if eduyrs==.d
replace `var'=. if eduyrs==.c
replace `var'=. if eduyrs==.b
replace `var'=. if eduyrs==.a
}


foreach var in age2{
replace `var'=. if agea==.d
replace `var'=. if agea==.c
replace `var'=. if agea==.b
replace `var'=. if agea==.a
}

foreach var in agea{
replace `var'=. if agea==.d
replace `var'=. if agea==.c
replace `var'=. if agea==.b
replace `var'=. if agea==.a
}

foreach var in male{
replace `var'=. if gndr==.d
replace `var'=. if gndr==.c
replace `var'=. if gndr==.b
replace `var'=. if gndr==.a
}

foreach var in hinctnta{
replace `var'=. if hinctnta==.d
replace `var'=. if hinctnta==.c
replace `var'=. if hinctnta==.b
replace `var'=. if hinctnta==.a
}

foreach var in un_trust{
replace `var'=. if trstun==.d
replace `var'=. if trstun==.c
replace `var'=. if trstun==.b
replace `var'=. if trstun==.a
}

foreach var in prl_trust{
replace `var'=. if trstprl==.d
replace `var'=. if trstprl==.c
replace `var'=. if trstprl==.b
replace `var'=. if trstprl==.a
}

foreach var in eu_trust{
replace `var'=. if trstep==.d
replace `var'=. if trstep==.c
replace `var'=. if trstep==.b
replace `var'=. if trstep==.a
}

foreach var in farm{
replace `var'=. if domicil==.d
replace `var'=. if domicil==.c
replace `var'=. if domicil==.b
replace `var'=. if domicil==.a
}

foreach var in climate_awareness{
replace `var'=. if clmthgt2==.d
replace `var'=. if clmthgt2==.c
replace `var'=. if clmthgt2==.b
replace `var'=. if clmthgt2==.a
}

foreach var in country_action{
replace `var'=. if gvsrdcc==.d
replace `var'=. if gvsrdcc==.c
replace `var'=. if gvsrdcc==.b
replace `var'=. if gvsrdcc==.a
}

foreach var in religious{
replace `var'=. if rlgdgr==.d
replace `var'=. if rlgdgr==.c
replace `var'=. if rlgdgr==.b
replace `var'=. if rlgdgr==.a
}

* ------------------------------------------------------------------------------
* descriptive statistics
* ------------------------------------------------------------------------------
* Looking at differences in means

table trusting_group [pweight=weight], contents(mean z45)
table coop_climate_believer [pweight=weight], contents(mean z45)
table govcoop_climate_believer [pweight=weight], contents(mean z45)

eststo clear
eststo: svy: reg z45 trusting_group
estadd ysumm
eststo: svy: reg z45 coop_climate_believer
estadd ysumm
eststo: svy: reg z45 govcoop_climate_believer
estadd ysumm

esttab using "z45_dstats.tex", label b(3) /// 
se stats(ymean N r2, labels("Mean dep. var." "Observations" "$ R^2$") ///
fmt(3 0 3)) noconstant compress starlevels(* 0.1 ** 0.05 *** 0.01) ///
nolines prehead(\hline\hline) posthead(\hline) replace

********************************************************************************
** APPENDIX ********************************************************************
********************************************************************************
* Demographics 
eststo clear
foreach var in agea male edu_cat hinctnta{
eststo: svy: mean `var'
esttab using "dstats_base.tex", cells("_N(pattern(1 1) fmt(0)) b(pattern(1 1) fmt(3))") wide append noobs
}

* Variables of interest
eststo clear
foreach var in people_trust_exp climate_believers trusting_group{
eststo: svy: mean `var'
esttab using "dstats_IV.tex", cells("_N(pattern(1 1) fmt(0)) b(pattern(1 1) fmt(3))") wide append noobs
}

* Channels, out: country 
eststo clear 
foreach var in farm left child_home un_trust prl_trust eu_trust climate_awareness scientists rlgdgr ind_coop country_action stfgov stfdem{
eststo `var'_e: svy: mean `var'
esttab using "dstats_channels.tex", cells("_N(pattern(1 1) fmt(0)) b(pattern(1 1) fmt(3))") wide append noobs

}

* Dependent Variables
eststo clear
foreach var in z45	z46 ind_coop country_action{
eststo: svy: mean `var'
esttab using "dstats_DV.tex", cells("_N(pattern(1 1) fmt(0)) b(pattern(1 1) fmt(3))") wide append noobs
}

* ------------------------------------------------------------------------------
* Regression Analysis
* ------------------------------------------------------------------------------
cd "C:\Users\Jrxz12\Desktop\School\Research_Module\Code"
do Country_level_controls.do


* regressions on Pro-Environmental Behavior
* z_proxy_PEB is an index of PEB: responsibility, buy_eco, energy_reduce
* people_trust_exp is 1 if you believe most people can be trusted or 9 
* climate_believers is 1 if you believe in climate change 

** i.country are the country fixed effects
** agea is age of respondent
** age2 is agea squared
** male is 1, female 0
** edu_cat is years of full time education
** hinctnta is income broken into 10 categories

**** child_home is 1 if a child lives in the household
**** left is 1 for being politically left
**** un_trust is 1 if you have complete trust in the UN
**** prl_trust is 1 if you have complete trust in country's parliament
**** eu_trust is 1 if you have complete trust in the EU
**** farm is 1 if you live on a farm or country side
**** climate_awareness is 1 if you have given a great deal of thought to climate change before today
**** gov_empl is 1 if you work in the central or local government
**** pol_intr is 1 if you are very interested in politics

global xbase i.country agea age2 male edu_cat hinctnta
global channel_1 $xbase i.child_home i.farm i.scientists
global channel_2 $xbase i.left i.climate_awareness i.religious ind_coop country_action worried 
global channel_3 $xbase i.un_trust i.prl_trust i.eu_trust 
global all_channels $xbase i.child_home i.left i.un_trust i.prl_trust ///
i.eu_trust i.farm i.climate_awareness i.religious ind_coop country_action i.scientists worried

local base base_variables
local control1 livelihood	
local control2 knowledge_beliefs
local control3 institutions 
local control4 allcontrols 

********************************************************************************
** PEB OLS RESULTS *************************************************************
******************************************************************************** 
* TRUST
gen trusting_group = .
foreach var in trusting_group{
replace `var'=. if people_trust_exp==.|climate_believers==.
replace `var'=0 if people_trust_exp==0 & climate_believers==1
replace `var'=1 if people_trust_exp==1 & climate_believers==1
}
eststo clear
foreach var in z45{ 
eststo: svy: reg `var' trusting_group  $xbase
estadd local base "Yes", replace
estadd ysumm

eststo: svy: reg `var' trusting_group $channel_1
estadd local base "Yes", replace
estadd local control1 "Yes", replace
estadd ysumm

eststo: svy: reg `var' trusting_group $channel_2
estadd local base "Yes", replace
estadd local control2 "Yes", replace
estadd ysumm

eststo: svy: reg `var' trusting_group $channel_3
estadd local base "Yes", replace
estadd local control3 "Yes", replace
estadd ysumm

eststo: svy: reg `var' trusting_group $all_channels
estadd local base "Yes", replace
estadd local control4 "Yes", replace
estadd ysumm
}

esttab using "PEB_trust.tex", label b(3) /// 
se stats(base control1 control2 control3 control4 ymean N r2, labels("\hspace{2mm} Base Controls" "\hspace{2mm} Livelihood" "\hspace{2mm} Knowledge and Beliefs" "\hspace{2mm} Institutional Trust" "\hspace{2mm} All Channels" "Mean dep. var." "Observations" "$ R^2$") ///
fmt(0 0 0 0 0 3 0 3)) noconstant compress starlevels(* 0.1 ** 0.05 *** 0.01) ///
nolines prehead(\hline\hline) posthead(\hline) replace

* COOPERATIVE 

global channel_4 $xbase i.child_home i.farm i.scientists
global channel_5 $xbase i.left i.climate_awareness i.religious country_action worried 
global channel_6 $xbase i.un_trust i.prl_trust i.eu_trust 
global channels456 $xbase i.child_home i.left i.un_trust i.prl_trust ///
i.eu_trust i.farm i.climate_awareness i.religious country_action i.scientists worried 

gen coop_climate_believer = .
replace coop_climate_believer=1 if ind_coop==1 & climate_believers==1
replace coop_climate_believer=0 if ind_coop==0 & climate_believers==1

gen govcoop_climate_believer = .
replace govcoop_climate_believer=1 if country_action==1 & climate_believers==1
replace govcoop_climate_believer=0 if country_action==0 & climate_believers==1

eststo clear
foreach var in z45{ 
eststo: svy: reg `var' coop_climate_believer  $xbase
estadd local base "Yes", replace
estadd ysumm

eststo: svy: reg `var' coop_climate_believer $channel_4
estadd local base "Yes", replace
estadd local control1 "Yes", replace
estadd ysumm

eststo: svy: reg `var' coop_climate_believer $channel_5
estadd local base "Yes", replace
estadd local control2 "Yes", replace
estadd ysumm

eststo: svy: reg `var' coop_climate_believer $channel_6
estadd local base "Yes", replace
estadd local control3 "Yes", replace
estadd ysumm

eststo: svy: reg `var' coop_climate_believer $channels456
estadd local base "Yes", replace
estadd local control4 "Yes", replace
estadd ysumm
}

esttab using "indcoop_OLS.tex", label b(3) /// 
se stats(base control1 control2 control3 control4 ymean N r2, labels("\hspace{2mm} Base Controls" "\hspace{2mm} Livelihood" "\hspace{2mm} Knowledge and Beliefs" "\hspace{2mm} Institutional Trust" "\hspace{2mm} All Channels" "Mean dep. var." "Observations" "$ R^2$") ///
fmt(0 0 0 0 0 3 0 3)) noconstant compress starlevels(* 0.1 ** 0.05 *** 0.01) ///
nolines prehead(\hline\hline) posthead(\hline) replace

suest est1 est2 est3 est4 est5, vce(robust) coefl

global channel_7 $xbase i.child_home i.farm i.scientists
global channel_8 $xbase i.left i.climate_awareness i.religious ind_coop worried 
global channel_9 $xbase i.un_trust i.prl_trust i.eu_trust 
global channels_789 $xbase i.child_home i.left i.un_trust i.prl_trust ///
i.eu_trust i.farm i.climate_awareness i.religious ind_coop i.scientists worried 


eststo clear
foreach var in z45{ 
eststo: svy: reg `var' govcoop_climate_believer  $xbase
estadd local base "Yes", replace
estadd ysumm

eststo: svy: reg `var' govcoop_climate_believer $channel_7
estadd local base "Yes", replace
estadd local control1 "Yes", replace
estadd ysumm

eststo: svy: reg `var' govcoop_climate_believer $channel_8
estadd local base "Yes", replace
estadd local control2 "Yes", replace
estadd ysumm

eststo: svy: reg `var' govcoop_climate_believer $channel_9
estadd local base "Yes", replace
estadd local control3 "Yes", replace
estadd ysumm

eststo: svy: reg `var' govcoop_climate_believer $channels_789
estadd local base "Yes", replace
estadd local control4 "Yes", replace
estadd ysumm
}

esttab using "govcoop_OLS.tex", label b(3) /// 
se stats(base control1 control2 control3 control4 ymean N r2, labels("\hspace{2mm} Base Controls" "\hspace{2mm} Livelihood" "\hspace{2mm} Knowledge and Beliefs" "\hspace{2mm} Institutional Trust" "\hspace{2mm} All Channels" "Mean dep. var." "Observations" "$ R^2$") ///
fmt(0 0 0 0 0 3 0 3)) noconstant compress starlevels(* 0.1 ** 0.05 *** 0.01) ///
nolines prehead(\hline\hline) posthead(\hline) replace

suest est1 est2 est3 est4 est5, vce(robust) coefl

********************************************************************************
** EMPIRICALLY TESTING TRUST AND COOPERATION ***********************************
********************************************************************************
* To note: logit is done in this fashion to extract individual and interaction
* marginal effects 

* evidence that more trusting people believe in individual and country level 
* cooperation 
local control7 gov_satisfaction
local control8 democracy_satisfaction

eststo clear
foreach var in ind_coop{
eststo: svy: reg `var' trusting_group stfgov  $xbase
estadd ysumm 
estadd local base "Yes", replace
estadd local control8 "Yes", replace
estadd local control7 "No", replace
}

esttab using "ind_cooperation.tex", label b(3) /// 
se stats(base control8 control7 ymean N r2, labels("\hspace{2mm} Base Controls" "\hspace{2mm} Satisfaction with democracy" "\hspace{2mm} Government Satisfaction" "Mean dep. var." "Observations" "$ R^2$") ///
fmt(0 0 0 3 0 3)) noconstant compress starlevels(* 0.1 ** 0.05 *** 0.01) ///
nolines prehead(\hline\hline) posthead(\hline) replace


eststo clear
foreach var in country_action{
eststo: svy: reg `var' trusting_group stfdem stfgov  $xbase
estadd ysumm
estadd local base "Yes", replace
estadd local control8 "Yes", replace
estadd local control7 "Yes", replace
}

esttab using "country_cooperation.tex", label b(3) /// 
se stats(base control8 control7 ymean N r2, labels("\hspace{2mm} Base Controls" "\hspace{2mm} Satisfaction with democracy" "\hspace{2mm} Government Satisfaction" "Mean dep. var." "Observations" "$ R^2$") ///
fmt(0 0 0 3 0 3)) noconstant compress starlevels(* 0.1 ** 0.05 *** 0.01) ///
nolines prehead(\hline\hline) posthead(\hline) replace


********************************************************************************
** Country Level Analysis ******************************************************
********************************************************************************
* make sure to preserve first manually
collapse (mean) intercept uai_15 ind_15 future_15 wri_16 people_trust_exp log_GDP_pc climate_believers, by(country)

********************************************************************************
** FACTOR ANALYSIS *************************************************************
********************************************************************************
* factor analysis: looking for uni-dimensionality and internal consistency * measure- omega
factor rdcenr eneffap ccrdprs, pcf 
* omega coef
di (.7490+.7466+.6128)^2/((.4390+.4425+.6245)+(.7490+.7466+.6128)^2)
di ".7469482"
estat kmo 
di "0.5879" 

factor inctxff sbsrnen banhhap, pcf 
estat kmo
di "0.6058"
di (.6706+.7319+.7211)^2/((.5503+.4643+.4800)+(.6706+.7319+.7211)^2)
di ".75107744"

* running a factor analysis on all 6 measures reveals that 2 factors are
* generated and thus, a good reason to separate them 

********************************************************************************
** SECOND PEB ON POLICY ********************************************************
********************************************************************************
eststo clear
foreach var in z46{ 
eststo: svy: reg `var' 1.climate_believers#1.  $xbase
estadd local base "Yes", replace
estadd ysumm

eststo: svy: reg `var' ind_coop $channel_1
estadd local base "Yes", replace
estadd local control1 "Yes", replace
estadd ysumm

eststo: svy: reg `var' ind_coop $channel_2
estadd local base "Yes", replace
estadd local control2 "Yes", replace
estadd ysumm

eststo: svy: reg `var' ind_coop $channel_3
estadd local base "Yes", replace
estadd local control3 "Yes", replace
estadd ysumm

eststo: svy: reg `var' ind_coop $all_channels
estadd local base "Yes", replace
estadd local control11 "Yes", replace
estadd ysumm
}

esttab using "PEB2_OLS.tex", label b(3) /// 
se stats(base control1 control2 control3 control4 control5 control11 ymean N r2, labels("\hspace{2mm} Base Controls" "\hspace{2mm} Child at home" "\hspace{2mm} Politically Left" "\hspace{2mm} Trust in Political Institutions" "\hspace{2mm} Living on a farm" "\hspace{2mm} Climate Awareness" "\hspace{2mm} All Channels" "Mean dep. var." "Observations" "$ R^2$") ///
fmt(0 0 0 0 0 0 0 3 0 3)) noconstant compress starlevels(* 0.1 ** 0.05 *** 0.01) ///
nolines prehead(\hline\hline) posthead(\hline) replace

* ------------------------------------------------------------------------------
* Model Analysis
* ------------------------------------------------------------------------------

********************************************************************************
** Performing tests on model specification *************************************
********************************************************************************

*-------------------------------------------------------------------------------
* To check: (1) heteroskedasticity (2) specification error (3) multicollinearity
*-------------------------------------------------------------------------------
* (1) 
* Using the svy functionality, this is covered 

* (2)
* The linktest for "link-error" - to see if a link function is needed 
* can be ran with svy 
** result: passes, no non-linearities
linktest 

* omitted variable bias test 
* cannot be ran with svy
* ran with [pweight=weight], robust
foreach var in z45{
quietly reg `var' trusting_group  $xbase [pweight=weight], robust
ovtest
quietly reg `var' trusting_group  $all_channels [pweight=weight], robust
ovtest 
quietly reg `var' coop_climate_believer $xbase [pweight=weight], robust
ovtest
quietly reg `var' coop_climate_believer $channels456 [pweight=weight], robust
ovtest 
quietly reg `var' govcoop_climate_believer $xbase [pweight=weight], robust
ovtest
quietly reg `var' govcoop_climate_believer $channels_789 [pweight=weight], robust
ovtest 
}

* (3)
* result: shows no signs of multicollinearity (except for age, but thats obvious)
estat vif 

*-------------------------------------------------------------------------------
* To check: (4) Normality of errors (5) Independence of errors 
*-------------------------------------------------------------------------------

* (4)
* generate full model
svy: reg z45 trusting_group $all_channels
predict z45_residual, resid
predict z45_hat

* results on normality: visually ok, tails deviate slightly on qnorm, midrange 
* deviates slightly for pnorm 
kdensity z45_residual, norm
pnorm z45_residual
qnorm z45_residual

* iqr stands for inter-quartile range and assumes the symmetry of the distribution
* 3 inter-quartile-ranges below the first quartile or 3 inter-quartile-ranges above the third quartile
* get more info on the symmetry component of iqr
* reveals there are 11 severe outliers, but will not be removed since we lose 
* information and there's a reason why they are there.
iqr z45_residual

* (5)
* we cluster at the PSU given some indvidual level information

