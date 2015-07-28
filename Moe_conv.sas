/* Moe_conv.sas - UISUG SAS Macro Library
 
  Autocall macro to change confidence level for margin of error value.  
  
  Method based on 
  http://www.census.gov/acs/www/Downloads/handbooks/ACSResearch.pdf
  p. A-12.
 
  NB:  Program written for SAS Version 9.1
 
  06/28/11  Peter A. Tatian
****************************************************************************/

/** Macro moe_conv - Start Definition **/

%macro moe_conv( 
  moe=,            /** Original margin of error value **/
  conf_new=,       /** New confidence level (values: 0 to 1) **/
  conf_def=0.90,   /** Original confidence level (values: 0 to 1) **/
  df=100000        /** Degrees of freedom for calculating inverse t value **/
  );

  ( ( tinv( (1-((1-(&conf_new))/2)), (&df) ) / tinv( (1-((1-(&conf_def))/2)), (&df) ) ) * (&moe) )

%mend moe_conv;

/** End Macro Definition **/

