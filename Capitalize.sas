/* Capitalize.sas - SAS Macro
 *
 * Autocall macro to capitalize the first letter of a text string.
 *
 * NB:  Program written for SAS Version 8.2
 *
 * 01/02/03  Peter A. Tatian
 ****************************************************************************/

/** Macro Capitalize - Start Definition **/

%macro Capitalize( s );

  ( upcase( substr( (&s), 1, 1 ) ) || lowcase( substr( (&s), 2 ) ) )

%mend Capitalize;

/** End Macro Definition **/


/***** UNCOMMENT TO TEST MACRO *****

title "Capitalize:  SAS Macro";

** Autocall macros **;

filename uiautos "K:\Metro\PTatian\UISUG\Uiautos";
options sasautos=(uiautos sasautos);

options mprint symbolgen mlogic;

data _null_;

  length str cstr $ 30;

  input str $ 1 - 12;  

  cstr = %capitalize( str );
  
  put str= cstr=;
  
  cards;
            
a           
A           
Peter Tatian
peter tatian
PETER TATIAN
pEtEr TaTiAn
  ;

run;

/***** END MACRO TEST *****/
