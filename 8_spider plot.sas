********************Spider plot***************;
/*get data*/
proc import datafile="H:\GTL paper\Input_data.xlsx" out=spider2 dbms=xlsx replace;
	sheet="8.Spiderplot";
run;

proc sort data=spider2;
	by resn id avisitn;
run;

ods path show;
ods path work.testtemp(update) sashelp.tmplmst(read);

proc template; 
 define statgraph spider/store=work.testtemp; 
 	begingraph;
		discreteattrmap name='criteria';
			value 'Progressive Disease' / lineattrs=(color=red) markerattrs=(color=red);
			value 'Complete Response' / lineattrs=(color=green) markerattrs=(color=green);
			value 'Partial Response' / lineattrs=(color=yellow) markerattrs=(color=yellow);
			value 'Stable Disease' / lineattrs=(color=blue) markerattrs=(color=blue);
		enddiscreteattrmap;
		discreteattrvar attrvar=resn_map var=response attrmap='criteria';
		entrytitle "Percent change in tumor size from baseline by duration";
  	layout overlay / xaxisopts=(label='Duration in Weeks' linearopts=(tickvaluesequence=(start=0 end=20 increment=4) 
                            viewmin=0 viewmax=20) offsetmin=0.05)
                      yaxisopts=(label='% Change in Tumor Size from Baseline'
                      linearopts=(tickvaluepriority=true tickvaluesequence=(start=-100 end=100 increment=20))); 
	    referenceline y=0/ lineattrs=(thickness=1.5);
	   	referenceline y=20/ lineattrs=(thickness=1);
	   	referenceline y=-30/ lineattrs=(thickness=1);
     	seriesplot x=avisitn y=pchg/group=id linecolorgroup=resn_map 
				lineattrs=(thickness=2 pattern=solid) groupdisplay=overlay break=true;
		scatterplot x=avisitn y=pchg/ group=resn_map markerattrs=(size=6 symbol=squarefilled) groupdisplay=overlay name='a'; 
	   	discretelegend "a"/ valign=bottom across=2;
	  endlayout; 
 	endgraph;
 end; 
run; 

%let gpathname=H:\GTL paper;

options orientation=landscape ;
ods rtf file = "&gpathname\spiderplot.rtf" image_dpi=200 ;
ods graphics on/reset=all height=5.5in width=7in imagename="spiderplot" imagefmt=png noborder  ; 
proc sgrender data=spider2 template=spider;  
run;
ods _all_ close;
ods listing;
