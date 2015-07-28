/* Moe_prop.sas - UISUG SAS Macro Library
 
  Autocall macro to calculate margins of error for derived proportions.
  NB: The numerator of a proportion is a subset of the denominator 
  (e.g., the proportion of single person households that are female).
  
  Method based on 
  http://www.census.gov/acs/www/Downloads/handbooks/ACSResearch.pdf
  pp. A-14 - A-15.
 
  NB:  Program written for SAS Version 9.1
 
  06/28/11  Peter A. Tatian
  09/23/11  PAT Updated header note.
****************************************************************************/

/** Macro moe_prop - Start Definition **/

%macro moe_prop( 
  num=,       /** Proportion numerator value **/
  den=,       /** Proportion denominator value **/
  num_moe=,   /** Numerator margin of error **/
  den_moe=    /** Denominator margin of error **/
  );

  %local prop;
  
  %let prop = ((&num)/(&den));
  
  (sqrt( ((&num_moe)*(&num_moe)) - ((&prop*&prop) * ((&den_moe)*(&den_moe))) ) / (&den));

%mend moe_prop;

/** End Macro Definition **/
