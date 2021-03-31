**************Swimmers plot*************;
/*get data*/
proc import datafile="H:\GTL paper\Input_data.xlsx" out=swim2_ dbms=xlsx replace;
	sheet="9.Swimmerplot";
run;

proc format;
	value $res
	'SD'='Stable Disease'
	'PR'='Partial Response'
	'CR'='Complete Response'
	'PD'= 'Progressive Disease'
	;
run;

data swim2;
	set swim2_;
	format resp $res.;
run;

proc template;
  define statgraph swimmer;
  begingraph;
		discreteattrmap name='restype';
			value 'Stable Disease' / markerattrs=(symbol=squarefilled color=blue size=10);
			value 'Partial Response' / markerattrs=(symbol=squarefilled color=yellow size=10);
			value 'Complete Response' / markerattrs=(symbol=squarefilled color=green size=10);
			value 'Progressive Disease' / markerattrs=(symbol=squarefilled color=red size=10);
		enddiscreteattrmap;
		discreteattrvar attrvar=resp_map var=resp attrmap='restype';
    entrytitle "Overall Response by Recist and Tumor type";
    layout overlay/ xaxisopts=(label='Duration in Weeks' offsetmin=0
								linearopts=(tickvaluesequence=(start=0 end=50 increment=10) viewmin=0 viewmax=50))
                yaxisopts=(label='Subject' offsetmax=0.25); 
            barchart category=id1 response=tot_dur1/ group=tumor_type1 orient=horizontal barwidth=0.2 name='bar' fillattrs= (transparency=0.2)
					  INCLUDEMISSINGGROUP=FALSE;
			scatterplot X=resp_dur  Y=id/group=resp_map name="res";
			scatterplot x=ongdur y=id / markerattrs=(symbol=trianglerightfilled color=orange size=13) name='ongo' legendlabel="Ongoing";
			discreteLegend "bar"  "res" "ongo"/across=1 autoalign=(topright) 
				location=inside valueattrs=(size=8pt) border=false;
    endlayout;
  endgraph;
  end;
run;

%let gpathname=H:\GTL paper;

options orientation=landscape nodate nonumber;
ods rtf file = "&gpathname\swimmer.rtf" image_dpi=200 ;
ods graphics on/reset=all height=5.5in width=7in imagename="swimmer" imagefmt=png noborder  ; 

proc sgrender data=swim2 template=swimmer;
run;
ods rtf close;
ods listing;
