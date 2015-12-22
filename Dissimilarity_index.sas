/******************* URBAN INSTITUTE MACRO LIBRARY *********************
 
 Macro: Dissimilarity_index

 Description: Autocall macro to calculate the dissimilarity index between
 two populations.
 
 Use: Open code
 
 Author: Peter Tatian
 
***********************************************************************/

/***** Macro %Dissimilarity_index() - Calculates dissimilarity index *****/

%macro Dissimilarity_index( 
  data=,        /** Input data set **/
  out=,         /** Output data set & var name (optional) **/
  varA=,        /** Population A **/
  varB=,        /** Population B **/
  by=,          /** By variable for grouping results (optional) **/
  print=y       /** Print results (Y/N) **/
  );

  /*************************** USAGE NOTES *****************************
   
   SAMPLE CALL: 
     %Dissimilarity_index( data=Test, varA=A, varB=B, by=geo, out=Result )

  *********************************************************************/

  /*************************** UPDATE NOTES ****************************

   07/01/11  Peter A. Tatian

  *********************************************************************/

  %***** ***** ***** MACRO SET UP ***** ***** *****;
   
  %local input_data varDI;

  %if &out = %then %do;
    %let out = _di_output;
    %let varDI = _DI;
  %end;
  %else %do;
    %let varDI = %DSNameOnly( &out );
  %end;
    
    
  %***** ***** ***** ERROR CHECKS ***** ***** *****;



  %***** ***** ***** MACRO BODY ***** ***** *****;

  ** Calculate total group A and B populations **;

  %if &by ~= %then %do;
    %let input_data = _di_sorted;
    proc sort data=&data out=&input_data;
      by &by;
    run;
  %end;
  %else %do;
    %let input_data = &data;
  %end;
    
  proc means data=&input_data noprint nway;
    %if &by ~= %then %do;
      class &by;
    %end;
    var &varA &varB;
    output out=_di_totals sum=&varA._s &varB._s;
  run;  
  
  /***
  proc print data=_di_totals;
    id &by;
    title3 "_di_totals";
  run;
  ***/

  ** Merge population totals to individual unit data **;
  
  data _di_calc;

    %if &by ~= %then %do;
      merge &input_data (keep=&by &varA &varB) _di_totals;
        by &by;
    %end;
    %else %do;
    
      set &input_data (keep=&varA &varB);
      
      if _n_ = 1 then set _di_totals;
    
    %end;
    
    ** Calculate dissimilarity index formula for each unit **;

    if &varA._s > 0 and &varB._s > 0 then 
      &varDI = 0.5 * abs( ( &varA / &varA._s ) - ( &varB / &varB._s ) );
    
    label &varDI = "Dissimilarity index of &varA vs. &varB";
    
  run;

  /***
  proc print data=_di_calc (obs=15);
    var &by &varA &varB &varA._s &varB._s &varDI;
    title3 "_di_calc";
  run;
  ***/

  ** Sum DI for all units **;

  proc means data=_di_calc noprint nway;
    %if &by ~= %then %do;
      class &by;
    %end;
    var &varDI;
    output out=&out (drop=_type_ _freq_) sum= ;
  run;

  %if %mparam_is_yes( &print ) %then %do;
  
    ** Print DI results **;

    proc print data=&out label noobs;
      %if &by ~= %then %do;
        id &by;
      %end;
      var &varDI;
    run;
    
  %end;
  
  
  %***** ***** ***** CLEAN UP ***** ***** *****;

  ** Cleanup temporary data sets **;

  proc datasets library=work memtype=(data) nolist nowarn;
    delete _di_:;
  quit;

%mend Dissimilarity_index;



/************************ UNCOMMENT TO TEST ***************************

** Locations of SAS autocall macro libraries **;

filename uiautos  "K:\Metro\PTatian\UISUG\Uiautos";
options sasautos=(uiautos sasautos);

options nocenter;
options mprint nosymbolgen nomlogic;

data Test;

  input id geo A B;
  
datalines;
1 1 10 20
2 1 50 0
3 1 40 40
4 1 0 20
5 2 80 40
6 2 20 90
7 2 60 50
8 2 30 0
9 2 0 0
10 2 40 60
11 3 0 50
12 3 0 70
;

run;

proc print data=Test;
  title2 'Input data set: TEST';
run;

title2;

%Dissimilarity_index( data=Test, varA=A, varB=B, by=geo, out= )
%Dissimilarity_index( data=Test, varA=A, varB=B, by=, out=work.di_out, print=n )

%File_info( data=di_out )

/**********************************************************************/
