/******************* URBAN INSTITUTE MACRO LIBRARY *********************
 
 Macro: Compare_file_struct

 Description: Compares the file structure of two or more data sets.
 
 Use: Open code
 
 Author: Peter Tatian
 
***********************************************************************/

%macro Compare_file_struct( 
  file_list=,      /** List of data sets to compare **/
  lib=work,        /** Library for input data sets **/
  out=,            /** Output data set (optional) **/
  prefix=,         /** Prefix for input data set names (optional) **/
  suffix=,         /** Suffix for input data set names (optional) **/
  print=Y,         /** Print results to output destination (Y/N) **/
  csv_out=         /** Pathname for CSV file for results (optional) **/
);

  /*************************** USAGE NOTES *****************************
   
   SAMPLE CALL: 
     %{macro name}(  )

  *********************************************************************/

  /*************************** UPDATE NOTES ****************************


  *********************************************************************/

  %***** ***** ***** MACRO SET UP ***** ***** *****;
   
  %local i file;
    
  %note_mput( macro=Compare_file_struct, msg=Macro starting. )
  
  %if &lib = %then %let lib = work;

    
  %***** ***** ***** ERROR CHECKS ***** ***** *****;

  %let i = 1;
  %let file = %scan( &file_list, &i );
  
  %do %while( &file ~= );

    %if not %dataset_exists( &lib..&prefix.&file.&suffix ) %then %do;
      %err_mput( macro=Compare_file_struct, msg=Data set &lib..&prefix.&file.&suffix does not exist. )
      %goto exit;
    %end;
  
    %let i = %eval( &i + 1 );
    %let file = %scan( &file_list, &i );
  
  %end;
  
  %if &i < 3 %then %do;
    %err_mput( macro=Compare_file_struct, msg=File_list= must have at least two files to compare. )
    %goto exit;
  %end;
  

  %***** ***** ***** MACRO BODY ***** ***** *****;

  %let i = 1;
  %let file = %scan( &file_list, &i );
  
  %do %while( &file ~= );

    proc contents noprint
      data=&lib..&prefix.&file.&suffix
      out=_Cts_&prefix.&file.&suffix (keep=name type length compress=no);

    data _Cts_&prefix.&file.&suffix (compress=no);
    
      set _Cts_&prefix.&file.&suffix;
    
      name = lowcase( name );
      
      if type = 1 then
        typlen_&file = 'N' || left( put( length, 7. ) );
      else
        typlen_&file = 'C' || left( put( length, 7. ) );
      
      label typlen_&file = "&file";
      
      drop type length;

    run;

    proc sort data=_Cts_&prefix.&file.&suffix out=_Cts_&prefix.&file.&suffix (compress=no);
      by name;
      
    run;
    
    %let i = %eval( &i + 1 );
    %let file = %scan( &file_list, &i );
  
  %end;
  
  data _Compare_file_struct (compress=no);

    merge

      %let i = 1;
      %let file = %scan( &file_list, &i );
      
      %do %while( &file ~= );
      
        _Cts_&prefix.&file.&suffix
        
        %let i = %eval( &i + 1 );
        %let file = %scan( &file_list, &i );
      
      %end;
      
      ;
  
    by name;

  run;

  %if %mparam_is_yes( &print ) %then %do;

    proc print data=_Compare_file_struct noobs label;
      id name;
    run;

  %end;

  %if &csv_out ~= %then %do;

    filename fexport "&csv_out" lrecl=5000;

    proc export data=_Compare_file_struct
        outfile=fexport
        dbms=csv replace;
    run;

    filename fexport clear;

  %end;

  %if &out ~= %then %do;
    data &out;
      set _Compare_file_struct;
    run;
  %end;

  %exit:


  %***** ***** ***** CLEAN UP ***** ***** *****;

  proc datasets library=work memtype=(data) nolist nowarn;
    delete _Compare_file_struct _Cts_: ;
  quit;


  %note_mput( macro=Compare_file_struct, msg=Macro exiting. )  

%mend Compare_file_struct;


/************************ UNCOMMENT TO TEST ***************************/

  ** Locations of SAS autocall macro libraries **;

  filename uiautos  "K:\Metro\PTatian\UISUG\Uiautos";
  options sasautos=(uiautos sasautos);
  
  options mprint nosymbolgen nomlogic;

  data A;
    length x $ 1 y 8 z 4;
  run;

  data B;
    length y 8 z 6;
  run;

  data C;
    length x $ 1 y 8 z 4 xx $ 50;
  run;
  
  %Compare_file_struct( file_list=A B C, print=n )
  
  proc datasets library=work memtype=(data);
  quit;

/**********************************************************************/
