/******************* URBAN INSTITUTE MACRO LIBRARY *********************
 
 Macro: Dataset_exists

 Description: Returns TRUE (1) if a data set exists, FALSE (0) if not.
 
 Use: Function
 
 Author: Peter Tatian
 
***********************************************************************/

%macro Dataset_exists( 
  dsn,     /* Macro name */
  quiet=Y,  /* Suppress log messages (Y/N) */
  memtype=data  /* SAS file type (def. data set) */
  );

  /*************************** USAGE NOTES *****************************
   
   SAMPLE CALL: 
     %Dataset_exists( Dat.MyFile, Quiet=N )

  *********************************************************************/

  /*************************** UPDATE NOTES ****************************

   11/15/04  Added MEMTYPE= option to specify type of file (ACCESS, 
             CATALOG, DATA (def.), or VIEW).

  *********************************************************************/

  %***** ***** ***** MACRO SET UP ***** ***** *****;
   
    
  %***** ***** ***** ERROR CHECKS ***** ***** *****;


  %***** ***** ***** MACRO BODY ***** ***** *****;

  %if %sysfunc(exist(&dsn,&memtype)) %then %do;
    1
    %if %mparam_is_no( &quiet ) %then %do;
      %Note_mput( macro=Dataset_exists, msg=The data set &dsn (%upcase(&memtype)) exists. )
    %end;
  %end;
  %else %do;
    0
    %if %mparam_is_no( &quiet ) %then %do;
      %Note_mput( macro=Dataset_exists, msg=The data set &dsn (%upcase(&memtype)) does not exist. )
    %end;
  %end;

  %***** ***** ***** CLEAN UP ***** ***** *****;

%mend Dataset_exists;


/************************ UNCOMMENT TO TEST ***************************

options mprint nosymbolgen nomlogic;

** Autocall macros **;

filename uiautos "K:\Metro\PTatian\UISUG\Uiautos";
options sasautos=(uiautos sasautos);

data Exists;

run;

data _null_;

  x = %Dataset_exists( Exists, Quiet=n );
  y = %Dataset_exists( NoExist, Quiet=n );
  
  put x= y=;
  
run;

/**********************************************************************/
