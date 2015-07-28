/* Moe_ratio.sas - UISUG SAS Macro Library
 
  Autocall macro to calculate margins of error for derived ratios.
  NB: The numerator of a ratio is NOT a subset of the denominator
  (e.g., the ratio of females living alone to males living alone).
  
  Method based on 
  http://www.census.gov/acs/www/Downloads/handbooks/ACSResearch.pdf
  pp. A-15 - A-16.
 
  NB:  Program written for SAS Version 9.1
 
  09/23/11  Peter A. Tatian
****************************************************************************/

/** Macro Moe_ratio - Start Definition **/

%macro Moe_ratio( 
  num=,       /** Ratio numerator value **/
  den=,       /** Ratio denominator value **/
  num_moe=,   /** Numerator margin of error **/
  den_moe=    /** Denominator margin of error **/
  );

  %local ratio;
  
  %let ratio = ((&num)/(&den));
  
  (sqrt( ((&num_moe)*(&num_moe)) + ((&ratio*&ratio) * ((&den_moe)*(&den_moe))) ) / (&den));

%mend Moe_ratio;

/** End Macro Definition **/
