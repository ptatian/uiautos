/******************* URBAN INSTITUTE MACRO LIBRARY *********************
 
 Macro: Data_to_format

 Description: Create a format using values from a data set
 
 Use: Open code
 
 Author: Peter Tatian
 
***********************************************************************/

%macro Data_to_format( 
  FmtLib=work,    /* Optional: Format library (def. WORK) */
  FmtName=,       /* Format name (start w/$ for char format) */
  DefaultLen=.,   /* Optional: Default format length */  
  MaxLen=.,       /* Optional: Maximum format length */
  MinLen=.,       /* Optional: Minimum format length */
  InDS=,          /* Input data set */
  Data=,          /* Input data set (alias) */
  Value=,         /* Value to be formatted (num or char expression) */
  Label=,         /* Label to use for formatted value (char expression) */
  NotSorted=N,    /* Specify NOTSORTED option for format (Y/N) */
  OtherLabel=,    /* Optional: Label to use for values not in format (char string) */
  Desc=,          /* Optional: Description of format for catalog (char string) */
  Contents=N,     /* Optional: List contents of format catalog (Y/N) */
  Print=Y         /* Optional: Print resulting format (Y/N) */
  );

  /*************************** USAGE NOTES *****************************
   
   SAMPLE CALL: 
     %Data_to_format(
       FmtLib=General,
       FmtName=$anc12a,
       Data=General.ANC2012,
       Value=ANC2012,
       Label=ANC2012_name,
       OtherLabel="Not a valid ANC"
       )
       create format $anc12a in General.Formats catalog that converts
       values given by var ANC2012 to labels in var ANC2012_name from
       data set General.ANC2012.
       Values not found in ANC2012 will be labeled "Not a valid ANC"
  
  *********************************************************************/

  /*************************** UPDATE NOTES ****************************

    11/23/04  Added Data= parameter (alias for input data set name),
              check for required parameters.
    03/30/06  Added Contents= and Desc= parameters.
    10/22/06  Added NotSorted= parameter.

  *********************************************************************/

  %***** ***** ***** MACRO SET UP ***** ***** *****;
   
  %local type fmtcat;
  
  %Note_mput( macro=Data_to_format, msg=Starting macro. )

    
  %***** ***** ***** ERROR CHECKS ***** ***** *****;

  %if %length( &InDS ) = 0 %then %let InDS = &Data;
  
  %if %length( &InDS ) = 0 %then %do;
    %Err_mput( macro=Data_to_format, 
                 msg=Must provide an input data set in Data= or InDS= parameter. )
    %goto err_exit;
  %end;

  %if %length( &FmtName ) = 0 %then %do;
    %Err_mput( macro=Data_to_format, 
                 msg=Must provide a format name in FmtName= parameter. )
    %goto err_exit;
  %end;

  %if %length( &Value ) = 0 %then %do;
    %Err_mput( macro=Data_to_format, 
                 msg=Must provide a num. or char. expression in Value= parameter. )
    %goto err_exit;
  %end;

  %if %length( &Label ) = 0 %then %do;
    %Err_mput( macro=Data_to_format, 
                 msg=Must provide a char. expression in Label= parameter. )
    %goto err_exit;
  %end;


  %***** ***** ***** MACRO BODY ***** ***** *****;
  
  %** TYPE = Type of format (Character/Numeric) **;

  %if %substr( &fmtname, 1, 1 ) = $ %then 
    %let type = C;
  %else 
    %let type = N;
  
  %** FMTCAT = Full name of format catalog **;
  
  %if %sysfunc( indexc( "&fmtlib", '.' ) ) > 0 %then
    %let fmtcat = &fmtlib;
  %else
    %let fmtcat = &fmtlib..formats;
    
  data _cntlin (compress=no);
  
    length hlo $ 8;

    retain fmtname "&fmtname" type "&type" /*hlo "  " */
      default &defaultlen max &maxlen min &minlen;
    
    %if %mparam_is_yes( &NotSorted ) %then %do;
      retain hlo "s";
    %end;
    %else %do;
      retain hlo " ";
    %end;
    
    %if &maxlen > 0 %then %do;
      length label $ &maxlen;
    %end;
    
    set &InDS end=last;
    
    label = &label;
    start = &value;
    
    output;
    
    %if %length( &otherlabel ) > 0 %then %do; 
    
      if last then do;
        hlo = trim( hlo ) || 'o';
        label = &otherlabel;
        output;
      end;
      
    %end;

    keep fmtname type hlo label start default max min;

  run;
  
  proc format library=&fmtlib cntlin=_cntlin;

  run;
  
  proc datasets library=work memtype=(data) nolist;
    delete _cntlin;
  quit;
  
  %** Add format description to catalog **;
  
  %if &desc ~= %then %do;
  
    proc catalog catalog=&fmtcat;
    %if &type = C %then %do;
      modify %substr( &fmtname, 2 ) (desc=&desc) /entrytype=formatc;
    %end;
    %else %do;
      modify &fmtname (desc=&desc) /entrytype=format;
    %end;
    quit;
  
  %end;
  
  %** Print entire format to output **;
  
  %if %mparam_is_yes( &print ) %then %do; 
  
    proc format library=&fmtlib fmtlib;
      select &fmtname;

    run;
    
  %end;
  
  %** List contents of format catalog **;
  
  %if %mparam_is_yes( &contents ) %then %do;

    proc catalog catalog=&fmtcat;
      contents;
    quit;
    
  %end;  
  
  %goto exit;
  
  %err_exit:
  %Err_mput( macro=Data_to_format, msg=Format &FmtName was not created. ) 
  
  %exit:
  %Note_mput( macro=Data_to_format, msg=Exiting macro. )

  %***** ***** ***** CLEAN UP ***** ***** *****;


%mend Data_to_format;


/************************ UNCOMMENT TO TEST ***************************

filename uiautos "K:\Metro\PTatian\UISUG\Uiautos";
options sasautos=(uiautos sasautos);

options mprint nosymbolgen nomlogic;

data A;

  input v $ 1 v_lbl $ 3-9;
  
datalines;
A Label A
B Label B
C Label C
;

run;

proc print data=A;

%Data_to_format(
  FmtLib=work,
  FmtName=$test,
  Desc="Test format",
  Data=A,
  Value=v,
  Label=v_lbl,
  OtherLabel="Not a valid value",
  DefaultLen=.,
  MaxLen=.,
  MinLen=.,
  Print=Y,
  Contents=Y
  )

proc datasets library=work;
quit;

/**********************************************************************/
