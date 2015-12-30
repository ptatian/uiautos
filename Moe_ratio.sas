/******************* URBAN INSTITUTE MACRO LIBRARY *********************
 
 Macro: Moe_ratio

 Description: Autocall macro that returns a calculation for a margin of error 
 for a derived ratio based on the values and margins of error of the 
 proportion numerator and denominator.

 The numerator of a ratio is NOT a subset of the denominator
 (e.g., the ratio of females living alone to males living alone).
 
 Use: Function
 
 Author: Peter Tatian
 
***********************************************************************/

%macro Moe_ratio( 
  num=,       /** Ratio numerator value **/
  den=,       /** Ratio denominator value **/
  num_moe=,   /** Numerator margin of error **/
  den_moe=    /** Denominator margin of error **/
  );

  /*************************** USAGE NOTES *****************************
   
   SAMPLE CALL: 
     %moe_ratio( num=female, den=male, num_moe=female_moe, den_moe=male_moe )
       returns calculation for margin of error for ratio female/male

  *********************************************************************/

  /*************************** UPDATE NOTES ****************************

   09/23/11  Peter A. Tatian

  *********************************************************************/

  %***** ***** ***** MACRO SET UP ***** ***** *****;
   
  %local ratio;
    
    
  %***** ***** ***** ERROR CHECKS ***** ***** *****;



  %***** ***** ***** MACRO BODY ***** ***** *****;
  
  %let ratio = ((&num)/(&den));
  
  (sqrt( ((&num_moe)*(&num_moe)) + ((&ratio*&ratio) * ((&den_moe)*(&den_moe))) ) / (&den))


  %***** ***** ***** CLEAN UP ***** ***** *****;

%mend Moe_ratio;


/************************ UNCOMMENT TO TEST ***************************

options mprint;

data _null_;

  ratio = 45/55;
  moe = %moe_ratio( num=45, den=55, num_moe=10, den_moe=8 );
  put ratio= moe=;

run;

/**********************************************************************/

