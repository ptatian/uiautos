/* DSNameOnly.sas - UI SAS Macro Library
 *
 * Autocall macro that returns the data set name portion of a
 * libname.dataset specification.
 *
 * NB:  Program written for SAS Version 9.1
 *
 * 08/27/06  Peter A. Tatian
 ****************************************************************************/

/** Macro DSNameOnly - Start Definition **/

%macro DSNameOnly( LibDataSpec );

  %let dot = %sysfunc( indexc( &LibDataSpec, '.' ) );
  
  %let Ret = %sysfunc( substr( &LibDataSpec, &dot + 1 ) );
  &Ret

%mend DSNameOnly;

/** End Macro Definition **/

/*******  UNCOMMENT TO TEST MACRO *******

options mprint symbolgen mlogic;

%let test1 = Libname.DataSet;
%let test1_ds = %DSNameOnly( &test1 );
%put test1=&test1 test1_ds=&test1_ds;

%let test2 = DataSet;
%let test2_ds = %DSNameOnly( &test2 );
%put test2=&test2 test2_ds=&test2_ds;

/****************************************/

