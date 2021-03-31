/*get data*/
proc import datafile="H:\GTL paper\Input_data.xlsx" out=heart2 dbms=xlsx replace;
	sheet="1.Scatter";
run;

proc format;
	value trt 
	0 = "Placebo"
	1 = "Active";
run;

proc template;   
	define statgraph scat; 
    begingraph; 	 
		entrytitle "Systolic BP over time" ;
		entryfootnote halign=left "          Note: Systolic BP >120mmHg indicates elevated BP"; 
		layout overlay/ xaxisopts=(offsetmin=0.1 offsetmax=0.2 label= 'Analysis day') 
						yaxisopts=(offsetmin=0.1 offsetmax=0.3 label= 'Systolic Blood Pressure');
			scatterplot x=ady y=systolic/group= trtn  name= 'treatment' /*datalabel=subject*/ ;
			referenceline y=120 /  lineattrs=(pattern=shortdash ) ;
			discretelegend 'treatment' / location= inside  halign=right valign=top border=yes;
       	endlayout; 
     endgraph; 
   end;
run; 

%let gpathname=H:\GTL paper;

options orientation=landscape ;
ods listing close;
ODS RTF FILE="&gpathname.\scatter.rtf" ;
ods graphics on/reset=all height=5.5in width=6.5in imagename="scatter" imagefmt=png noborder ; 
proc sgrender data=heart2 template=scat;
format trtn trt.;
run;
ods _all_ close;
ods listing;

