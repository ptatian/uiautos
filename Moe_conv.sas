/******************* URBAN INSTITUTE MACRO LIBRARY *********************
 
 Macro: Moe_conv

 Description: Autocall macro that returns a recalculated margin of error 
 based on a new confidence level.
 
 Method based on 
 http://www.census.gov/acs/www/Downloads/handbooks/ACSResearch.pdf
 p. A-12.
 
 Use: Function
 
 Author: Peter Tatian
 
***********************************************************************/

%macro moe_conv( 
  moe=,            /** Original margin of error value **/
  conf_new=,       /** New confidence level (values: >0 and <1) **/
  conf_def=0.90,   /** Original confidence level (values: >0 and <1) **/
  df=100000        /** Degrees of freedom for calculating inverse t value **/
  );

  /*************************** USAGE NOTES *****************************
   
   SAMPLE CALL: 
     %moe_conv( moe=x_moe, conf_new=0.95 )
       returns new margin of error calculation for 0.95 confidence level 
       for a margin of error x_moe at 0.90 confidence level (default)

  *********************************************************************/

  /*************************** UPDATE NOTES ****************************


  *********************************************************************/

  %***** ***** ***** MACRO SET UP ***** ***** *****;
   

    
  %***** ***** ***** ERROR CHECKS ***** ***** *****;



  %***** ***** ***** MACRO BODY ***** ***** *****;

  ( ( tinv( (1-((1-(&conf_new))/2)), (&df) ) / tinv( (1-((1-(&conf_def))/2)), (&df) ) ) * (&moe) )

%mend moe_conv;


/************************ UNCOMMENT TO TEST ***************************

options mprint;

data _null_;

  new = %moe_conv( moe=100, conf_new=0.95 );
  put new=;

  new = %moe_conv( moe=100, conf_new=0.80 );
  put new=;

run;

/**********************************************************************/

