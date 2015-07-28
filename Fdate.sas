/************************************************************************
 * Program:  Fdate.sas
 * Project:  UI SAS Macro Library
 * Author:   P. Tatian
 * Updated:  9/22/04
 * Version:  SAS 8.12
 * Environment:  Windows or Alpha
 * Use in:  Open code
 * 
 * Description:  Autocall macro to put a formatted version of 
 * a date value into a macro variable.
 *
 * 03-17-06  Added DATE= and QUIET= parameters.
 ************************************************************************/

%macro fdate(
  fmt=mmddyy10.,  /* SAS date format to use for formatting date */
  mvar=fdate,     /* Name of macro variable to store formatted date */
  date="&sysdate9"d,   /* Date to reformat (default is system date) */
  quiet=Y              /* Suppress message in log (Y/N) */
  );

   %global &mvar;
   
   data _null_;
      call symput("&mvar",left(put(&date,&fmt)));
   run;
   
   %if %upcase( &quiet ) = N %then %do;
     %note_mput( macro=FDATE, msg=Macro variable %upcase(&mvar) set to &&&mvar. )
   %end;

%mend fdate;

