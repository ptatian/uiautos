/* MCapitalize.sas - SAS Macro
 *
 * Autocall macro to capitalize the first letter of a macro text value.
 *
 * NB:  Program written for SAS Version 8.2
 *
 * 01/02/03  Peter A. Tatian
 ****************************************************************************/

/** Macro MCapitalize - Start Definition **/

%macro MCapitalize( s );

  %upcase( %substr( &s, 1, 1 ) )%lowcase( %substr( &s, 2 ) )

%mend MCapitalize;

/** End Macro Definition **/


/***** UNCOMMENT TO TEST MACRO *****

title "MCapitalize:  SAS Macro";

** Autocall macros **;

filename uiautos "K:\Metro\PTatian\UISUG\Uiautos";
options sasautos=(uiautos sasautos);

options mprint symbolgen mlogic;

data _null_;

  length str cstr $ 30;

  input str $ 1 - 12;  

  cstr = %MCapitalize( str );
  
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
