/* Moe_sum.sas - UISUG SAS Macro Library
 
  Autocall macro to calculate margins of error for summed estimates.
  
  Method based on 
  http://www.census.gov/acs/www/Downloads/handbooks/ACSResearch.pdf
  p. A-14.
 
  NB:  Program written for SAS Version 9.1
 
  06/28/11  Peter A. Tatian
****************************************************************************/

/** Macro moe_sum - Start Definition **/

%macro moe_sum( 
  var=           /** List of variables containing MOE values to sum **/
  );

  %local i calc;
  
  %let calc = sqrt( ;
  %let i = 1;
  %let v = %scan( &var, &i, %str( ) );

  %do %until ( &v = );

    %let calc = &calc (&v)*(&v);
    
    %let i = %eval( &i + 1 );
    %let v = %scan( &var, &i, %str( ) );
    
    %if &v ~= %then %let calc = &calc +;

  %end;
  
  %let calc = &calc );
  
  (&calc)

%mend moe_sum;

/** End Macro Definition **/

