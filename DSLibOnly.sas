/******************* URBAN INSTITUTE MACRO LIBRARY *********************
 
 Macro: DSLibOnly

 Description: Autocall macro that returns the library name portion of a
 libname.dataset specification.
 
 Use: Function
 
 Author: Peter Tatian
 
***********************************************************************/

%macro DSLibOnly( LibDataSpec );

  /*************************** USAGE NOTES *****************************
   
   SAMPLE CALL: 
     %{macro name}(  )

  *********************************************************************/

  /*************************** UPDATE NOTES ****************************

  08/27/06  Peter A. Tatian

  *********************************************************************/

  %***** ***** ***** MACRO SET UP ***** ***** *****;
   
  %local dot ret;
    
    
  %***** ***** ***** ERROR CHECKS ***** ***** *****;



  %***** ***** ***** MACRO BODY ***** ***** *****;

  %let dot = %sysfunc( indexc( &LibDataSpec, '.' ) );
  
  %if &dot > 0 %then %do;
    %let Ret = %sysfunc( substr( &LibDataSpec, 1, &dot - 1 ) );
    &Ret
  %end;
  %else %do;
    %** No library, return WORK **;
    WORK
  %end;


  %***** ***** ***** CLEAN UP ***** ***** *****;


%mend DSLibOnly;


/************************ UNCOMMENT TO TEST ***************************

options mprint symbolgen mlogic;

%let test1 = Libname.DataSet;
%let test1_ds = %DSLibOnly( &test1 );
%put test1=&test1 test1_ds=&test1_ds;

%let test2 = DataSet;
%let test2_ds = %DSLibOnly( &test2 );
%put test2=&test2 test2_ds=&test2_ds;

/**********************************************************************/

