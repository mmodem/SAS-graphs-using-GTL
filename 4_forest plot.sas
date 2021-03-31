/*get data*/
proc import datafile="H:\GTL paper\Input_data.xlsx" out=forr0 dbms=xlsx replace;
	sheet="4.Forestplot";
run;

data forr;
	set forr0;
	retain fmtname 'yval' type 'n' empty "aaaaaaa";
run;

proc format library=work cntlin=forr;
run;

***Graph template;
proc template;
	define statgraph forest;
 		begingraph;
			entrytitle textattrs=(size=10.9pt weight=bold) halign = center   "Forest plot of RBC adjusted mean change from baseline versus placebo at Week 20"  ;	
			entrytitle  " "  ;	
			layout overlay /walldisplay= none xaxisopts=(label="Adjusted mean change vs placebo (95% CI)" offsetmin= 0.05 offsetmax=0.05 display= (label tickvalues line)
										linearopts=(tickvaluepriority=true tickvaluesequence=(start=-2 end=2 increment=0.5)))
 							 yaxisopts=(offsetmin=0.25 offsetmax=0.33 display= (tickvalues line)  discreteopts=(colorbands=even COLORBANDSATTRS=(color=burlywood)));
 				scatterplot x=df_amean y=label /  legendlabel="Active drug"  name= "trt"  ERRORBARCAPSHAPE= NONE 
							xerrorlower=LCL xerrorupper=UCL errorbarattrs=(color=blue)	markerattrs=(symbol=circlefilled size=8 color=blue );
				referenceline x=0 / lineattrs= ( pattern=2)  ;
				innermargin /align=right;
					axistable y=start value=pdecl / valueattrs=(size=10) display=(values);    
					axistable y=start value=empty / valueattrs=(size=10 ) display=(values) DATATRANSPARENCY =1;  
					axistable y=start value=df_amean / valueattrs=(size=10) display=(values) ;  			
				endinnermargin;   
				drawtext textattrs=( size=9pt) "Favors Active" /anchor=bottomleft width=18 widthunit=percent 
						 xspace=wallpercent yspace=wallpercent x=18 y=3.5 justify=center ;
				drawtext textattrs=( size=9pt) "Favors Placebo" /anchor=bottomleft width=18 widthunit=percent 
						 xspace=wallpercent yspace=wallpercent x=44 y=3.5 justify=center ;
				drawtext textattrs=( size=9pt) "No. of subjects" /anchor=bottomleft width=18 widthunit=percent 
						 xspace=wallpercent yspace=wallpercent x=-17 y=80 justify=center ;
				drawtext textattrs=( size=9pt) "Placebo, Active" /anchor=bottomleft width=35 widthunit=percent 
						 xspace=wallpercent yspace=wallpercent x=-18 y=75 justify=center ;
				drawtext textattrs=( size=9pt) "Placebo decline" /anchor=bottomleft width=10 widthunit=percent 
						 xspace=wallpercent yspace=wallpercent x=74 y=80 justify=center ;
				drawtext textattrs=( size=9pt) "Adjusted mean change vs placebo" /anchor=bottomleft width=12 widthunit=percent 
						 xspace=wallpercent yspace=wallpercent x=90 y=80 justify=center;
				discretelegend  'trt' /pad=(left=15 ) LOCATION=INSIDE HALIGN=LEFT VALIGN= TOP  border=true;
			endlayout;
 		endgraph;
	end;
run; 

%let gpathname=H:\GTL paper;

***Render proc template;
ods listing close;
ods rtf file="&gpathname\forest.rtf"  ;
options orientation=landscape ;
ods graphics on/reset=all height=5in width=6.5in imagename="forest" imagefmt=png noborder ; 
proc sgrender data=forr template=forest;
	format start yval.;
run;
ods _all_ close;
ods listing;
