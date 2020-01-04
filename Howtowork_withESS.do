********************************************************************************
* HOW TO USE EUROPEAN VALUE SURVEY (ESS) ***************************************
********************************************************************************

* Import dataset from correct directory/path. We will be working with ESS8 data
cd "C:\Users\Jrxz12\Desktop"
use ESS8.dta

* How to survey set: tells Stata that you are working with a survey
* psu: primary sampling unit. Standard errors are clustered at this level. 
* strata: contain primary sampling units, typically based on some information 
** The exact information used to make the strata can be found on the ESS website
* pweight: for the ESS8, IF you are doing analysis on ONE country at a time, 
** use pweight only (population weight).
	** IF you are deriving any inferences from multiple countries (maybe some 
	** generalized effect, an average over some countries, regression analysis), 
	** please multiply pweight with either a design weight or post stratification 
	** weight. 
* svydescribe: tells you what you have specified plus the defaults
gen weight = pspwght*pweight
svyset psu [pweight=weight], strata(stratum) single(cen) 
svydescribe 

* When creating variables, be wary (concerned) with missings 
** Most variables have this missings formatting (a,b,c,d). Double check.

* Create politically-left variable as dichotomous (1=lrscale<4, 0=EVERYTHING else)
gen left = (lrscale<4)

* Correct missings 
foreach var in left{
replace `var'=. if lrscale==.a|lrscale==.b|lrscale==.c|lrscale==.d
}

* Derive descriptive statistics
** svy: mean will give you mean, obs (unweighted and weighted), psu count, 
**** strata count 
** estat sd will return the mean and standard deviation in one table
svy: mean left
estat sd

* This says: This will list the groups of polintr and see, per group, what is 
** the average of left. 
svy: mean left, over(polintr)

* svy: tab will show the relative frequency (proportion) of each option in a var
* There are many options, and you can specify two variables.

svy: tab polintr

gen male = gndr
replace male=0 if gndr==2
foreach var in male{
replace `var'=. if gndr==.d| gndr==.c| gndr==.b| gndr==.a
}
* Looking at the proportion of political interest and gender
svy: tab polintr male

* You can also specify a subpopulation instead of using the 'if' conditional
* As a matter of fact, this is best practice for standard error estimation
svy, subpop(male): mean polintr

* Regression analysis
** svy carries all the necessary information to make a regression. 
svy: reg left male
linktest 
* Some typical postestimation commands might not work, but a workaround is:
reg left male [pweight=weight], robust

* This will generate the same estimate and the same s.e. Then you can run:
** estat ovtest: provides evidence of mis-specification, not necessarily O.V.Bias
** estat vif checks for multi-collinearity (above 10 means you should be concerned)
** dfbeta looks for influential observations
estat ovtest 
estat vif
dfbeta

* For residual analysis:
svy: reg trstep ppltrst

predict r, resid
predict y_hat
scatter r y_hat

* To check normality of residuals (for proper inference)
kdensity r, norm 
swilk r
* for deviation in the mid-distribution
pnorm r

* for deviation in the tails of the distribution
qnorm r




