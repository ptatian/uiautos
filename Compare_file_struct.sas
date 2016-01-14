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
  csv_out=         /** Pathname for CSV file for results, in quotes (optional) **/
);

  /*************************** USAGE NOTES *****************************
   
   SAMPLE CALL: 
     %Compare_file_struct( file_list=A B C )
       compares file structures of WORK library data sets A, B, and C
       and prints results to output destination.

  *********************************************************************/

  /*************************** UPDATE NOTES ****************************


  *********************************************************************/

  %***** ***** ***** MACRO SET UP ***** ***** *****;
   
  %local i file merge_list;
    
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
  
  %let merge_list = ;

  %let i = 1;
  %let file = %scan( &file_list, &i );
  
  %do %while( &file ~= );

    proc contents noprint
      data=&lib..&prefix.&file.&suffix
      out=_Cts_&i (keep=name type length compress=no);
    run;

    data _Cts_&i (compress=no);
    
      set _Cts_&i;
    
      name = lowcase( name );
      
      if type = 1 then
        typlen_&file = 'N' || left( put( length, 7. ) );
      else
        typlen_&file = 'C' || left( put( length, 7. ) );
      
      label typlen_&file = "&file";
      
      drop type length;

    run;

    proc sort data=_Cts_&i out=_Cts_&i (compress=no);
      by name;
    run;
    
    %let merge_list = &merge_list _Cts_&i;
    
    %let i = %eval( &i + 1 );
    %let file = %scan( &file_list, &i );
  
  %end;
  
  data _Compare_file_struct (compress=no);

    merge &merge_list;
    by name;

  run;

  %if %mparam_is_yes( &print ) %then %do;

    proc print data=_Compare_file_struct noobs label;
      id name;
    run;

  %end;

  %if &csv_out ~= %then %do;

    filename fexport &csv_out lrecl=5000;

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


  %***** ***** ***** CLEAN UP ***** ***** *****;

  proc datasets library=work memtype=(data) nolist nowarn;
    delete _Compare_file_struct _Cts_: ;
  quit;


  %exit:

  %note_mput( macro=Compare_file_struct, msg=Macro exiting. )  
  

%mend Compare_file_struct;


/************************ UNCOMMENT TO TEST ***************************

  ** Locations of SAS autocall macro libraries **;

  filename uiautos  "K:\Metro\PTatian\UISUG\Uiautos";
  options sasautos=(uiautos sasautos);
  
  options mprint nosymbolgen nomlogic;
  
  ** Create test data sets **;

  data A;
    length x $ 1 y 8 z 4;
  run;

  data B;
    length y 8 z 6;
  run;

  data C;
    length x $ 1 y 8 z 4 xx $ 50;
  run;

  ** Check error handling **;
  
  %Compare_file_struct( file_list=A )
  %Compare_file_struct( file_list=A XXX )
  
  ** First test **;

  %Compare_file_struct( file_list=A B C, print=y, out=Results, csv_out="D:\Projects\UISUG\Uiautos\Compare_file_struct_results.csv" )
  
  %File_info( data=Results, stats= )

  proc datasets library=work memtype=(data);
  quit;
  
  %put _user_;
  
  ** Second test **;
  
  libname rp 'L:\Libraries\RealProp\Data';
  
  %Compare_file_struct(
    lib=rp,
    file_list=
      2001_04 2001_10a 2001_10b 
      2002_05 2002_09 2002_11 
      2003_01 2003_07 
      2004_01 2004_07 2004_12 
      2005_03 2005_05 2005_06 2005_11 2005_12
      2006_03 2006_07 2006_09 2006_12 
      2007_05 2007_09 2007_11
      2008_01 2008_06 2008_11
      2009_01 2009_04 2009_06 2009_09 2009_11,
    prefix=Ownerpt_
  )
  
  
/**********************************************************************/
