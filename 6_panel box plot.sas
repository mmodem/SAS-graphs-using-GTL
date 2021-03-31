/*get data*/
proc import datafile="H:\GTL paper\Input_data.xlsx" out=boxd5 dbms=xlsx replace;
	sheet="6.Panel_Boxplot";
run;

proc format;
	value byval
	1 = "Systolic blood pressure in mmHg"
	2 = "Diastolic blood pressure in mmHg" 
	;
run;

proc template;
	define statgraph box_panel;
	dynamic _BYVAL_ _ylabel _ticks _pg;
	begingraph;
	discreteattrmap name='Sex';
		value 'Female' /markerattrs=(color=black) textattrs= (color=green) fillattrs= (color=green transparency=0.4) lineattrs=(color=black);
		value 'Male' / markerattrs=(color=black) textattrs= (color=red ) fillattrs= (color= red transparency=0.4) lineattrs=(color=black);
	enddiscreteattrmap;
	discreteattrvar attrvar=sex_map1 var=sex_a1  attrmap='Sex';
	discreteattrvar attrvar=sex_map2 var=sex_a2 attrmap='Sex';
	entrytitle textattrs=(size=11pt weight=bold ) halign = center 'Boxplot ';  
	entrytitle textattrs=(size=11pt weight=bold) halign = center _BYVAL_;
	entrytitle textattrs=(size=11pt weight=bold) halign = center _pg;
		layout lattice / columns=2 rows=2 columndatarange=unionall rowdatarange=unionall rowweights= (0.9 0.1) columnweights=(0.5 0.5);
		rowaxes;
			rowaxis / offsetmin=0.1 offsetmax=0.1 griddisplay=on display=(ticks tickvalues label) label=_ylabel type=linear 
						linearopts=(tickvaluelist=_ticks tickvaluepriority=true) ;
			rowaxis / display=none ;
		endrowaxes;
		column2headers;
			entry textattrs=graphlabeltext(weight=normal) 'STUDY: A001';
			entry textattrs=graphlabeltext(weight=normal) 'STUDY: A002';
		endcolumn2headers;
			layout overlay / xaxisopts=(display=(ticks tickvalues)) 
							 x2axisopts=(display=(label) );
				boxplot x=race_a1 y=aval_a1/group=sex_map1 groupdisplay=cluster ;
			endlayout;
			layout overlay / xaxisopts=(display=(ticks tickvalues)) ;
				boxplot  x=race_a2 y=aval_a2  /group=sex_map2 groupdisplay=cluster;
			endlayout;
			Layout Overlay / walldisplay=none xaxisopts=(display=none griddisplay=off displaySecondary=none) 
					x2axisopts=(display=none griddisplay=off displaySecondary=none);
				AxisTable Value=nsubj_a1 X=race_a1 /class=sex_a1 labelPosition=min  ValueAttrs=(size=9 ) Display=(Label );
			endlayout;
			Layout Overlay / walldisplay=none xaxisopts=(display=none griddisplay=off displaySecondary=none) 
					x2axisopts=(display=none griddisplay=off displaySecondary=none);
				AxisTable Value=nsubj_a2 X=race_a2/class=sex_a2  labelposition=max labelattrs= (color=white size=0) ValueAttrs=(size=9 );
			endlayout;
		endlayout;
	endgraph;
	end;
run;

%let gpathname=H:\GTL paper;

ods listing close;
%macro boxp;
ods rtf file="&gpathname\panel_box_plot.rtf" ;
options orientation=landscape ;
%do i = 1 %to 2;
ods graphics on/reset=all height=6.5in width=8.5in imagename="boxpanel" imagefmt=png noborder; 
proc sgrender data=boxd5 template=box_panel;
	dynamic %if &i=1 %then %do;
				%str(_ylabel= "Systolic BP in mmHg")
				%str(_ticks="100 120 140 160 ")
				%str(_pg="Page 1 of 2");
			%end;
		   %else %if &i=2 %then %do;
				%str(_ylabel= "Diastolic BP in mmHg")
				 %str(_ticks="60 80 100 120 ")
				 %str(_pg="Page 2 of 2");
			%end;
	format  pg byval.;
	where pg = &i;
	by pg;
run;
%end;
%mend;
%boxp
ods _all_ close;
ods listing;
