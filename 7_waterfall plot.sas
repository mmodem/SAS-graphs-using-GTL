*****************Waterfall plot******************;
/*get data*/
proc import datafile="H:\GTL paper\Input_data.xlsx" out=wf2 dbms=xlsx replace;
	sheet="7.Waterfallplot";
run;

proc sort data=wf2;
	by descending pchg;
run;

proc template;
	define statgraph waterfall;
 		begingraph;
			entrytitle "Best % change in tumor size from baseline";
			symbolchar name=rightarrow char='2192'x;
			layout overlay/xaxisopts=( label = "Subject" type=discrete)
										yaxisopts =(label = "Best % change in tumor size from baseline" 
											LINEAROPTS=(tickvaluepriority=true tickvaluesequence=(start=-100 end=100 increment=20)));
				referenceline y=20 / lineattrs=(thickness=1.5);
				referenceline y=-30 / lineattrs=(thickness=1.5);
				barchart x=subjid y=pchg/ group=response barlabelattrs=(size=6pt)  barwidth=0.25 name="BAR";
				scatterplot x=subjid y=marker / markerattrs=(symbol=rightarrow color=black size=30 weight=bold); 
				discreteLegend "BAR"/ across=2 autoalign=(topright) location=inside titleattrs=(size=10pt) 
							valueattrs=(size=8pt) border=true borderattrs=(color=black) title="Response";
				drawtext textattrs=(size=15pt color=black weight=bold) {unicode "2192"x} / anchor=bottomright width=9 widthunit=percent xspace=wallpercent yspace=wallpercent x=86 y=4.75 justify=center ;
				drawtext textattrs=(size=8pt) "Ongoing" / anchor=bottomright width=12 widthunit=percent xspace=wallpercent yspace=wallpercent x=95 y=5.35 justify=center ;
			endlayout;
		endgraph;
	end;
run;

%let gpathname=H:\GTL paper;

options orientation=landscape ;
ods rtf file = "&gpathname\waterfall_plot.rtf" image_dpi=200 ;
ods graphics on/reset=all height=5.5in width=6in imagename="waterfall" imagefmt=png noborder  ; 
proc sgrender data=wf2 template=waterfall; 
run;
ods _all_ close;
ods listing;
