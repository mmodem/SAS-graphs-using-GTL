/*get data*/
proc import datafile="H:\GTL paper\Input_data.xlsx" out=adtte_ dbms=xlsx replace;
	sheet="10.Kmplot";
run;

proc format;
 value trt
 1 = "Placebo" 
 2 = 'Active low dose'
 3 = 'Active high dose'
 ;
run;

data adtte;
	set adtte_;
	if cnsr=0 then cnsr=1;
	else if cnsr=1 then cnsr=0;
run;

proc sort;
	by trtn id;
run;

**surviival analysis;
ods listing close;
ods graphics on;
ods output SurvivalPlot= surv_risk;
proc lifetest data= adtte plots=survival(atrisk=0 26 50 78) 
		outsurv=surv timelist=(0 26 50 78) reduceout;
	time aval*cnsr(1);
	strata trtn;
run;
ods _all_ close;
ods listing;


/*estimates data which is included as annotate dataset in the graph*/
data surv2;
	retain function 'text' x1space 'graphpercent' y1space 'graphpercent'  textsize 8 textcolor 'black' width 20 widthunit 'percent' justify 'left';
	set surv;
	length label $40 desc $80;
	format stratum trt. ;
	where timelist in (26 50 78);
	failure=1-survival;
	f_sdf_ucl = 1-sdf_lcl;
	f_sdf_lcl = 1-sdf_ucl;
	***;
	if failure = 0 then label = strip(put(failure, 8.3));
	else label = strip(put(failure, 8.3)) || ' (' || strip(put(f_sdf_lcl, 8.3)) || ', ' || strip(put(f_sdf_ucl, 8.3)) || ')'; 
	**X1 coordinates;
	if timelist = 26 then x1 = 32 ;
	else if timelist = 50 then x1 = 50.5;
	else if timelist = 78 then x1 = 68.5;
	**Y1 coordinates;
	if stratum = 1 then y1 = 76 ;
	else if stratum = 2 then y1 = 73;
	else if stratum = 3 then y1 = 70;
	**column header (desc);
	if timelist = 26 then desc = 'Estimated proportion 	at Week 26' ;
	else if timelist = 50 then desc = 'Estimated proportion	at Week 50' ;
	else if timelist = 78 then desc = 'Estimated proportion	at Week 78' ;
	keep function stratum label x1: y1: desc text: width widthunit justify timelist;
run;

/*annotation continued..*/
proc sort data= surv2 nodupkey out=est;
	by timelist;
run;

data est2;
	set est(drop=label);
	length label $100;
	y1=81;
	label = 'Estimated proportion (95% CI)';
	output;
	y1=79;
	label=substr(desc, 22);
	output;
run;


data surv3 (drop=iter );
	length label $40 ;
	y1= 67;
	do label = "Active high dose", "Active low dose", "Placebo        ";
		x1space = 'graphpercent' ; y1space = 'graphpercent'; function ='text'; textsize =8; textcolor ='black'; 
		width =20; widthunit ='percent'; anchor ='left'; x1 = 12.5; iter=3; y1 + iter ;
		output;
	end;

run;

/*final annotate dataset to be introduced in template*/
data anno;
	length x1space $30 label $100;
	set surv2
		surv3
		est2;
run;


/*event(failure) probability*/
proc sort data= surv_risk;
	by stratumnum time;
run;
data surv_risk2;
	set surv_risk;
	format stratumnum trt. ;
	by stratumnum time;
	retain survival2;
	if first.stratumnum then survival2 = survival;
	else if survival ^=. then survival2 = survival; /*survival probability*/
	failure=1-survival2;/*event probability*/
	if censored>. then f_censored = 1-censored ;
	drop stratum;
	**time is manipulated below in order to prevent each treatment step plot overlapping on each other */;
	if stratumnum =2 then time= time+1;
	if stratumnum=3 then time= time+2;
	if stratumnum =1 then time= time;
run;

/*to create wk85 and assign wk78 values to it so that step plot doesn't have veritical lines at the end*/
data dummy;
	set surv_risk2;
	by stratumnum time;
	if last.stratumnum;
	tatrisk= . ;
	atrisk = .;
	time=time+7;
run;


/*suvival results + dummy data*/
data surv_risk3;
	set surv_risk2(in=a)
		dummy;
	by stratumnum time;
run;


***graph procedures;
ods path show;
ods path work.testtemp(update) sashelp.tmplmst(read);

*******************;
proc template;   
	define statgraph km2/store=work.testtemp; 
    	begingraph;  
 			discreteattrmap name='Attr_trt';  
				value 'Placebo' / lineattrs=(color=red pattern=solid); 
				value 'Active low dose' / lineattrs=(color=blue pattern=solid);    
				value 'Active high dose' / lineattrs=(color=green pattern=solid);     
			enddiscreteattrmap;       
			discreteattrvar attrvar=Attr_trtname var=stratumnum attrmap='Attr_trt';  

			entrytitle textattrs=(size=11pt weight=bold) halign = center 'Kaplan-Meier plot of time to first abnormal RBC value';   
			entrytitle " " ;  
		   layout  lattice / columns=1 rows=2 rowweights= (0.85 0.15) columndatarange=union;
			/*step plot*/
       	layout overlay/xaxisopts=(offsetmin=0.15 offsetmax=0.1
										label = "Weeks" 
									  linearopts=(tickvaluelist= (0 26 50 78)))
						   yaxisopts=(offsetmin=0.1 offsetmax=0.38 label = 'Probability of progression'
										linearopts=(TICKVALUEPRIORITY = true tickvaluesequence=(start=0 end=0.20 increment=0.05)));
 
					stepplot x= time y= failure /group=Attr_trtname  name='step' ;  
					scatterplot x= time y= f_censored /group=Attr_trtname  name='scatter' markerattrs=(symbol=plus color=black) ;
					discretelegend 'step' /location= inside halign=right valign=bottom valueattrs=(size=8)  border= yes across=1;
       		endlayout; 
			/*no.of subjects at bottom presented as plot*/
			Layout Overlay / walldisplay=none xaxisopts=(display=none griddisplay=off displaySecondary=none) 
					x2axisopts=(display=none griddisplay=off displaySecondary=none);
				AxisTable Value=atrisk X=tatrisk /class=Attr_trtname  ValueAttrs=( Color=black size=9 ) display=(values)
						headerlabel= "Number of subjects at risk" headerlabelattrs=(size=10) valuehalign=center;
				drawtext textattrs=( size=9pt) "Placebo" /anchor=bottomleft width=18 widthunit=percent 
						 xspace=wallpercent yspace=wallpercent x=-2.7 y=39 justify=center ;
				drawtext textattrs=( size=9pt) "Active low dose" /anchor=bottomleft width=15 widthunit=percent 
						 xspace=wallpercent yspace=wallpercent x=-2.7 y=20.5 justify=center ;
				drawtext textattrs=( size=9pt) "Active high dose" /anchor=bottomleft width=18 widthunit=percent 
						 xspace=wallpercent yspace=wallpercent x=-2.7 y=1 justify=center ;
			endlayout;
		 endlayout;
		 	annotate;
	
     	endgraph; 
   end;
run; 

%let gpathname=H:\GTL paper;

options orientation=landscape ;
ods rtf file = "&gpathname\kmplot.rtf" image_dpi=200 ;
ods graphics on/reset=all height=7in width=9in imagename="kmplot" imagefmt=png noborder  ; 
proc sgrender data=surv_risk3 template=km2 sganno=anno; 
run;
ods _all_ close;
ods listing;
