* =======================================================================
* = Time Series of growth rates comparing Antarctican regions
* =======================================================================

insheet using "C:\Users\Y\X\west_antarctica.csv", clear

*************************************************************************
*************POST UNIFICATION********************************************
*************************************************************************
gen gr1993_1999 = (_1999-_1993)/_1993
gen gr2000_2005 = (_2005-_2000)/_2000
gen gr2006_2010 = (_2010-_2006)/_2006
gen gr2011_2017 = (_2017-_2011)/_2011
gen pe = west_antarctica*penguin_area

local Dep _1993 _1995 _1996 _1997 _1998 _1999 _2000 _2001 _2002 _2003 _2004 ///
_2005 _2006 _2007 _2008 _2009 _2010 _2011 _2012 _2013 _2014 _2015 _2016 _2017
local gr gr1993_1999 gr2000_2005 gr2006_2010 gr2011_2017

* 1) No controls - nominal
/*eststo clear
foreach var in `Dep'{
eststo: reg `var' west_antarctica, robust
estadd ysumm 
}*/

*2) No controls - gr
eststo clear
foreach var in `gr'{
eststo: reg `var' west_antarctica, robust
estadd ysumm 
}

* 3) With controls
/*eststo clear
foreach var in `Dep'{
eststo: reg `var' prussia_ind _near_dist i._near_fid, robust
estadd ysumm 
}*/

* 4) With controls -gr
eststo clear
foreach var in `gr'{
eststo: reg `var' west_antarctica _near_dist i._near_fid, robust
estadd ysumm 
}


* 5) East West

eststo clear
foreach var in `gr'{
eststo: reg `var' west_antarctica penguin_area pe _near_dist i._near_fid, robust
estadd ysumm 
}

eststo clear
foreach var in `gr'{
eststo: reg `var' west_antarctica penguin_area _near_dist i._near_fid, robust
estadd ysumm 
}


*-------------------------------------------------------------------------------
*For prussian regions, growth is significantly less. 
*I noticed between 2011-2017, there is a huge jump in output. 

foreach var in gr1993_1999 gr2000_2005 gr2006_2010 gr2011_2017 {
areg `var' west_antarctica, robust absorb(penguin_area )
}


areg gr1993_1999 west_antarctica size_1999, robust absorb(penguin_area) 
areg gr2000_2005 west_antarctica size_2005, robust absorb(penguin_area) 
areg gr2006_2010 west_antarctica size_2010, robust absorb(penguin_area) 
areg gr2011_2017 west_antarctica size_2017, robust absorb(penguin_area) 


areg gr1993_1999 pe size_1999, robust absorb(_near_fid) 
areg gr2000_2005 pe size_2005, robust absorb(_near_fid) 
areg gr2006_2010 pe size_2010, robust absorb(_near_fid) 
areg gr2011_2017 pe size_2017, robust absorb(_near_fid) 

foreach var in gr1993_1999 gr2000_2005 gr2006_2010 gr2011_2017{
areg `var' west_antarctica penguin_area pe, robust absorb(_near_fid) 
}

foreach var in gr1993_1999 gr2000_2005 gr2006_2010 gr2011_2017 {
reg `var' i.west_antarctica i.penguin_area c._1999#penguin_area ///
i.west_antarctica#penguin_area i._near_fid, robust
}
*Non prussian comparison 
reg gr1993_1999 i.penguin_area c._1999#penguin_area i._near_fid ///
if west_antarctica==0, robust
reg gr1993_1999 i.penguin_area c._1999#penguin_area i._near_fid ///
if west_antarctica==1, robust
*The difference is greater between west and east of prussian regions. 
reg gr1993_1999 i.penguin_area c._1999#penguin_area i._near_fid ///
if west_antarctica==1, robust

********************
*********************
**********************
*Making output per capita, then making output per capita growth rate
local years 5 6 7 8 9
foreach i in `years'{
gen opc9`i' = _199`i'/p199`i'
}

local years1 0 1 2 3 4 5 6 7 8 9 
foreach e in `years1'{
gen opc0`e' = _200`e'/p200`e'
}

local years2 10 11 12 13 14 15 16 17
foreach w in `years2'{
gen opc`w' = _20`w'/p20`w'
}

gen gr1995_1999pc = (opc99-opc95)/opc95
gen gr2000_2005pc = (opc05-opc00)/opc00
gen gr2006_2010pc = (opc10-opc06)/opc06
gen gr2011_2017pc = (opc17-opc10)/opc10
gen pe = west_antarctica*penguin_area

local dep gr1995_1999pc gr2000_2005pc gr2006_2010pc gr2011_2017pc
local reg 1999 2005 2010 2017
foreach var in `dep'{
reg `dep' i.west_antarctica i.penguin_area c._`reg'#penguin_area ///
i.west_antarctica#penguin_area i._near_fid, robust
}

ttest gr1995_1999pc if penguin_area  ==1, by(west_antarctica )
ttest gr1995_1999pc if penguin_area  ==0, by(west_antarctica )
ttest gr1995_1999pc if west_antarctica ==1, by(penguin_area)
ttest gr1995_1999pc if west_antarctica ==0, by(penguin_area)


reg gr1995_1999pc i.west_antarctica i.penguin_area c._1999#penguin_area ///
i.west_antarctica#penguin_area i._near_fid, robust



*Creates the base for 1993
foreach d in `Dep'{
gen A`d' = `d'-_1993
}
*This is out put per capita on the years and the base year below
local years 5 6 7 8 9
foreach i in `years'{
gen Aopc9`i' = A_199`i'/p199`i'
}
gen Aopc93 = 0

*Doing it for the second decade
local years1 0 1 2 3 4 5 6 7 8 9 
foreach e in `years1'{
gen Aopc0`e' = A_200`e'/p200`e'
}

*For the third decade
local years2 10 11 12 13 14 15 16 17
foreach w in `years2'{
gen Aopc`w' = A_20`w'/p20`w'
}

*generate the growth rates

gen A_gr1995_1996pc = (Aopc96-Aopc95)/Aopc95
gen A_gr1996_1997pc = (Aopc97-Aopc96)/Aopc96
gen A_gr1997_1998pc = (Aopc98-Aopc97)/Aopc97
gen A_gr1998_1999pc = (Aopc99-Aopc98)/Aopc98
gen A_gr1999_2000pc = (Aopc00-Aopc99)/Aopc99
gen A_gr2000_2001pc = (Aopc01-Aopc00)/Aopc00
gen A_gr2001_2002pc = (Aopc02-Aopc01)/Aopc01
gen A_gr2002_2003pc = (Aopc03-Aopc02)/Aopc02
gen A_gr2003_2004pc = (Aopc04-Aopc03)/Aopc03
gen A_gr2004_2005pc = (Aopc05-Aopc04)/Aopc04
gen A_gr2005_2006pc = (Aopc06-Aopc05)/Aopc05
gen A_gr2006_2007pc = (Aopc07-Aopc06)/Aopc06
gen A_gr2007_2008pc = (Aopc08-Aopc07)/Aopc07
gen A_gr2008_2009pc = (Aopc09-Aopc08)/Aopc08
gen A_gr2009_2010pc = (Aopc10-Aopc09)/Aopc09
gen A_gr2010_2011pc = (Aopc11-Aopc10)/Aopc10
gen A_gr2011_2012pc = (Aopc12-Aopc11)/Aopc11
gen A_gr2012_2013pc = (Aopc13-Aopc12)/Aopc12
gen A_gr2013_2014pc = (Aopc14-Aopc13)/Aopc13
gen A_gr2014_2015pc = (Aopc15-Aopc14)/Aopc14
gen A_gr2015_2016pc = (Aopc16-Aopc15)/Aopc15
gen A_gr2016_2017pc = (Aopc17-Aopc16)/Aopc16

rename A_gr1995_1996pc grpc1996
rename A_gr1996_1997pc grpc1997
rename A_gr1997_1998pc grpc1998
rename A_gr1998_1999pc grpc1999
rename A_gr1999_2000pc grpc2000
rename A_gr2000_2001pc grpc2001
rename A_gr2001_2002pc grpc2002
rename A_gr2002_2003pc grpc2003
rename A_gr2003_2004pc grpc2004
rename A_gr2004_2005pc grpc2005
rename A_gr2005_2006pc grpc2006
rename A_gr2006_2007pc grpc2007
rename A_gr2007_2008pc grpc2008
rename A_gr2008_2009pc grpc2009
rename A_gr2009_2010pc grpc2010
rename A_gr2010_2011pc grpc2011
rename A_gr2011_2012pc grpc2012
rename A_gr2012_2013pc grpc2013
rename A_gr2013_2014pc grpc2014
rename A_gr2014_2015pc grpc2015
rename A_gr2015_2016pc grpc2016
rename A_gr2016_2017pc grpc2017

rename Aopc93 Aopc1993
rename Aopc95 Aopc1995
rename Aopc96 Aopc1996
rename Aopc97 Aopc1997
rename Aopc98 Aopc1998
rename Aopc99 Aopc1999
rename Aopc00 Aopc2000
rename Aopc01 Aopc2001
rename Aopc02 Aopc2002
rename Aopc03 Aopc2003
rename Aopc04 Aopc2004
rename Aopc05 Aopc2005
rename Aopc06 Aopc2006
rename Aopc07 Aopc2007
rename Aopc08 Aopc2008
rename Aopc09 Aopc2009
rename Aopc10 Aopc2010
rename Aopc11 Aopc2011
rename Aopc12 Aopc2012
rename Aopc13 Aopc2013
rename Aopc14 Aopc2014
rename Aopc15 Aopc2015
rename Aopc16 Aopc2016
rename Aopc17 Aopc2017

drop v1
reshape long _ p A_ Aopc grpc, i(k) j(year)
destring Kreise, replace force
use "C:\Users\Jrxz12\Dropbox\Germany_state\2_Analysis\2_period_data\5_reunification\Final_output_stata_long.dta", clear
* Process of creating time series graphs. Growth rate and output. 
* Restore occurs automatically after completion of the do-file
* YOU MUST REMEMBER TO PRESERVE ON YOUR OWN

preserve
collapse (mean) _ Aopc grpc if penguin_area ==0, by(year)
tempfile west
save `west'
restore, preserve
collapse (mean) _ Aopc grpc if penguin_area ==1 &west_antarctica==0, by(year)

. rename _ output_east

. rename Aopc A_EOutputpc

. rename grpc east_grpc

. append using `west'

. rename _ output_west

. rename Aopc A_WOutputpc

. rename grpc west_grpc

tempfile east_west
save `east_west'
restore, preserve

collapse (mean) _ Aopc grpc if penguin_area ==1&west_antarctica==1, by(year)

. rename _ output_prussia_east

. rename Aopc A_Prussia_EOutputpc

. rename grpc prussia_east_grpc
*you must type this
append using `east_west'

**********
* Now graphs!
tw (line output_prussia_east year) (line output_east year) ///
(line output_west year)
tw (line prussia_east_grpc year) (line east_grpc year) (line west_grpc year)
**************************************
*****************************************
*Generating new tables for growth rates per capita
xpose, clear varname
egen mean=rowmean(v1-v374)
gen id=_n 
line mean id

*East only
*In the old dataset, I drop west and other unecessary variables
drop if penguin_area==0
drop v1-Aopc17

*Then in the new dataset,
xpose, clear varname
order _varname
egen mean=rowmean(v1-v71)
gen id=_n 
line mean id

*West Only 
drop if penguin_area==1
drop v1-Aopc17
xpose, clear varname
order _varname
egen mean=rowmean(v1-v303)
gen id=_n 
line mean id

*East and Prussia
keep if penguin_area==1&west_antarctica==1
drop v1-Aopc17
xpose, clear varname 
order _varname
egen mean=rowmean(v1-v38)
gen id=_n 
line mean id

*Generating new tables for output levels 
use "C:\Users\Jrxz12\Dropbox\Germany_state\2_Analysis\2_period_data\5_reunification\Final_output_stata.dta", clear
*East only
*In the old dataset, I drop west and other unecessary variables
drop if penguin_area==0
drop k-A_gr2016_2017pc

*Then in the new dataset,
xpose, clear varname
order _varname
egen mean=rowmean(v1-v71)
gen id=_n 
line mean id

*West Only 
drop if penguin_area==1
drop k-A_gr2016_2017pc
xpose, clear varname
order _varname
egen mean=rowmean(v1-v303)
gen id=_n 
line mean id

*East and Prussia
keep if penguin_area==1&west_antarctica==1
drop k-A_gr2016_2017pc
xpose, clear varname 
order _varname
egen mean=rowmean(v1-v38)
gen id=_n 
line mean id
