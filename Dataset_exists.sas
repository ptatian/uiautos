/************************************************************************
* Program:  Dataset_exists.sas
* Project:  UI SAS Macro Library
* Author:   P. Tatian
* Updated:  10/28/04
* Version:  SAS 8.2
* 
* Description:  Returns TRUE (1) if a data set exists, FALSE (0) if not.
*
* Modifications:
*   11/15/04  Added MEMTYPE= option to specify type of file (ACCESS, 
*             CATALOG, DATA (def.), or VIEW).
************************************************************************/

/** Macro Dataset_exists - Start Definition **/

%macro Dataset_exists( 
  dsn,     /* Macro name */
  quiet=Y,  /* Suppress log messages (Y/N) */
  memtype=data  /* SAS file type (def. data set) */
  );

  %if %sysfunc(exist(&dsn,&memtype)) %then %do;
    1
    %if %upcase( &quiet ) = N %then %do;
      %Note_mput( macro=Dataset_exists, msg=The data set &dsn (%upcase(&memtype)) exists. )
    %end;
  %end;
  %else %do;
    0
    %if %upcase( &quiet ) = N %then %do;
      %Note_mput( macro=Dataset_exists, msg=The data set &dsn (%upcase(&memtype)) does not exist. )
    %end;
  %end;

%mend Dataset_exists;

/** End Macro Definition **/

/******** UNCOMMENT TO TEST **********

options mprint nosymbolgen nomlogic;

** Autocall macros **;

filename uiautos "K:\Metro\PTatian\UISUG\Uiautos";
options sasautos=(uiautos sasautos);

data Exists;

run;

data _null_;

  x = %Dataset_exists( Exists, Quiet=N );
  y = %Dataset_exists( NoExist, Quiet=N );
  
  put x= y=;
  
run;

/******** END TEST **********/
