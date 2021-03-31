***graph procedures;
ods path show;
ods path work.testtemp(update) sashelp.tmplmst(read);

*******************;
proc template;   
	define statgraph histogram/store=work.testtemp; 
    	begingraph; 
			entrytitle textattrs=(size=11pt weight=bold) halign = center 'Histogram for systolic BP'; 
         	layout overlay/ xaxisopts=(offsetmin=0.05 linearopts=(viewmin=50 viewmax=350) display= (ticks tickvalues))
						   Yaxisopts=(offsetmax=0.05 linearopts=(viewmin=0 viewmax=1000) label= "Frequency" display= (ticks tickvalues label));
				histogram  systolic/ scale=count binwidth= 7 fillattrs=(color=CX8A2BE2 transparency=0.3 ) ;
       		endlayout; 
     	endgraph; 
   end;
run; 

%let gpathname=H:\GTL paper;

options orientation=landscape ;
ods listing close;
ODS RTF FILE="&gpathname.\hist.rtf" ;
ods graphics on/reset=all height=5.5in width=6.5in imagename="hist" imagefmt=png noborder ; 
proc sgrender data=sashelp.heart template=histogram;
run;
ods _all_ close;
ods listing;

