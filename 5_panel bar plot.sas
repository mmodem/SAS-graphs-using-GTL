******PANEL BARPLOT;
/*get data*/
proc import datafile="H:\GTL paper\Input_data.xlsx" out=barp4_ dbms=xlsx replace;
	sheet="5.Panel_Barplot";
run;

proc format;
   value bararm 1='Placebo'
                2='Active low dose'
                3='Active medium dose'
                4='Active high dose';
   value wkper 1='Week 1'
               2='Week 2'
               3='Week 3'
               4='Week 4';
   value sev    1='None'
               	2='Mild'
               	3='Moderate'
               	4='Severe'
               	5='Extreme';
run;

data barp4;
	set barp4_;
	format aesev sev.;
run;

***template;
proc template;
	define statgraph panelchart;
		begingraph;
			discreteattrmap name='Sev';
				value 'None' / fillattrs= (color=grey transparency=0.5) lineattrs=(color=white);
				value 'Mild' / fillattrs= (color= Orange transparency=0.7) lineattrs=(color=white);
				value 'Moderate' / fillattrs= (color= Orange transparency=0) lineattrs=(color=white);
				value 'Severe' / fillattrs= (color= maroon transparency=0.3) lineattrs=(color=white);
				value 'Extreme' / fillattrs= (color= red transparency=0) lineattrs=(color=white);
				enddiscreteattrmap;
			discreteattrvar attrvar=max_sev_map var=aesev attrmap='Sev';
			entrytitle 'Incidences of rash AE severity scores by week for the first 4 weeks';
			layout datapanel classvars=(avisitn) /  headerlabeldisplay= value  columns=2 columngutter=2  rowgutter=2 columndatarange=union columnweight=proportional
													columnaxisopts=(label = "Treatment"  tickvalueattrs=(size=9) )
													rowaxisopts=(display= (label ticks tickvalues) offsetmin=0 
													label = "Number of Subjects with Incidence "  tickvalueattrs=(size=9));
				layout prototype;
					barchart x=trt  y=nsubj2/ group=max_sev_map name='bar' groupdisplay =cluster grouporder=ascending;
					innermargin/align=top;
						axistable x=trt value=nsubj / display=(values); 
					endinnermargin;
				endlayout;
				sidebar ;
					discretelegend 'bar' /  title= "Severity";
				Endsidebar;
			endlayout;
		endgraph;
	end;
run;

%let gpathname=H:\GTL paper;

options orientation=landscape ;
ods rtf file="&gpathname\panel_bar_plot.rtf" ;
ods graphics on/reset=all height=6.5in width=9in imagename="bar1" imagefmt=png noborder; 
proc sgrender data=barp4 template=panelchart;
format trt bararm.  avisitn wkper.;
run;
ods _all_ close;
ods listing;
