/* Moe_prop_a.sas - UISUG SAS Macro Library
 
  Autocall macro to calculate margins of error for derived proportions.
  NB: The numerator of a proportion is a subset of the denominator 
  (e.g., the proportion of single person households that are female).
  
  Alternate version that assigns value to a specified variable (var=), 
  rather than just returning the MOE value as %Moe_prop() does. 
  This version tests whether quantity in sqrt() is negative and, if so,
  uses the %Moe_ratio() value instead, as suggested in the Census doc.

  Assigned value can be scaled by optional multiplier (mult=1).
  
  Method based on 
  http://www.census.gov/acs/www/Downloads/handbooks/ACSResearch.pdf
  pp. A-14 - A-15.
 
  NB:  Program written for SAS Version 9.1
 
  11/19/12  Peter A. Tatian
****************************************************************************/

/** Macro Moe_prop_a - Start Definition **/

%macro Moe_prop_a( 
  var=,       /** Variable to which MOE value is assigned **/
  mult=1,     /** Optional multiplier for MOE value **/
  num=,       /** Proportion numerator value **/
  den=,       /** Proportion denominator value **/
  num_moe=,   /** Numerator margin of error **/
  den_moe=    /** Denominator margin of error **/
  );

  %local prop;
  
  %let prop = ((&num)/(&den));
  
  %if &mult = %then %let mult = 1;
  
  if ( ((&num_moe)*(&num_moe)) - ((&prop*&prop) * ((&den_moe)*(&den_moe))) ) >= 0 then do;
    &var = (&mult) * %moe_prop( num=&num, den=&den, num_moe=&num_moe, den_moe=&den_moe );
  end;
  else do; 
    &var = (&mult) * %moe_ratio( num=&num, den=&den, num_moe=&num_moe, den_moe=&den_moe );
  end;

%mend Moe_prop_a;

/** End Macro Definition **/
