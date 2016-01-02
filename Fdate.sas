/******************* URBAN INSTITUTE MACRO LIBRARY *********************
 
 Macro: Fdate

 Description: Autocall macro to put a formatted version of 
 a date value into a macro variable.
 
 Use: Open code
 
 Author: Peter Tatian
 
***********************************************************************/

%macro fdate(
  fmt=mmddyy10.,  /* SAS date format to use for formatting date */
  mvar=fdate,     /* Name of macro variable to store formatted date */
  date="&sysdate9"d,   /* Date to reformat (default is system date) */
  quiet=Y              /* Suppress message in log (Y/N) */
  );

  /*************************** USAGE NOTES *****************************
   
   SAMPLE CALL: 
     %fdate(  )

  *********************************************************************/

  /*************************** UPDATE NOTES ****************************

   03-17-06  Added DATE= and QUIET= parameters.

  *********************************************************************/

  %***** ***** ***** MACRO SET UP ***** ***** *****;
   
  %global &mvar;
    
    
  %***** ***** ***** ERROR CHECKS ***** ***** *****;



  %***** ***** ***** MACRO BODY ***** ***** *****;
   
   data _null_;
      call symput("&mvar",left(put(&date,&fmt)));
   run;
   
   %if %mparam_is_no( &quiet ) %then %do;
     %note_mput( macro=FDATE, msg=Macro variable %upcase(&mvar) set to &&&mvar. )
   %end;


  %***** ***** ***** CLEAN UP ***** ***** *****;

%mend fdate;


/************************ UNCOMMENT TO TEST ***************************

%fdate( quiet=n )

%fdate( mvar=month, fmt=monname9., quiet=n )

/**********************************************************************/
