/* DSLibOnly.sas - UI SAS Macro Library
 *
 * Autocall macro that returns the library name portion of a
 * libname.dataset specification.
 *
 * NB:  Program written for SAS Version 9.1
 *
 * 08/27/06  Peter A. Tatian
 ****************************************************************************/

/** Macro DSLibOnly - Start Definition **/

%macro DSLibOnly( LibDataSpec );

  %let dot = %sysfunc( indexc( &LibDataSpec, '.' ) );
  
  %if &dot > 0 %then %do;
    %let Ret = %sysfunc( substr( &LibDataSpec, 1, &dot - 1 ) );
    &Ret
  %end;
  %else %do;
    %** No library, return WORK **;
    WORK
  %end;

%mend DSLibOnly;

/** End Macro Definition **/

/*******  UNCOMMENT TO TEST MACRO *******

options mprint symbolgen mlogic;

%let test1 = Libname.DataSet;
%let test1_ds = %DSLibOnly( &test1 );
%put test1=&test1 test1_ds=&test1_ds;

%let test2 = DataSet;
%let test2_ds = %DSLibOnly( &test2 );
%put test2=&test2 test2_ds=&test2_ds;

/****************************************/

