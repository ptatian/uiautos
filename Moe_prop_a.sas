/******************* URBAN INSTITUTE MACRO LIBRARY *********************
 
 Macro: Moe_prop_a

 Description: Autocall macro that returns a calculation for a margin of error 
 for a derived proportion based on the values and margins of error of the 
 proportion numerator and denominator.

 The numerator of a proportion must be a subset of the denominator 
 (e.g., the proportion of single person households that are female).
 
 Alternate version of macro that assigns value to a specified variable
 (var=), rather than just returning the MOE value as %Moe_prop() does. 
 This version tests whether quantity in sqrt() is negative and, if so,
 uses the %Moe_ratio() value instead, as suggested in the Census doc.

 Assigned value can be scaled by optional multiplier (mult=1).
 
 Method based on 
 http://www.census.gov/acs/www/Downloads/handbooks/ACSResearch.pdf
 pp. A-14 - A-15.
 
 Use: Within data step
 
 Author: Peter Tatian
 
***********************************************************************/

%macro Moe_prop_a( 
  var=,       /** Variable to which MOE value is assigned **/
  mult=1,     /** Optional multiplier for MOE value **/
  num=,       /** Proportion numerator value **/
  den=,       /** Proportion denominator value **/
  num_moe=,   /** Numerator margin of error **/
  den_moe=,   /** Denominator margin of error **/
  label_moe=   /** Label margin of error (optional, enclose in quotes) **/
  );

  /*************************** USAGE NOTES *****************************
   
   SAMPLE CALL: 
     %moe_prop_a( var=female_prop_moe, num=female, den=total, num_moe=female_moe, den_moe=total_moe )
       Assigns margin of error for proportion female/total to var
       female_prop_moe

  *********************************************************************/

  /*************************** UPDATE NOTES ****************************

  11/19/12  Peter A. Tatian

  *********************************************************************/

  %***** ***** ***** MACRO SET UP ***** ***** *****;
   
  %local prop;
    
    
  %***** ***** ***** ERROR CHECKS ***** ***** *****;



  %***** ***** ***** MACRO BODY ***** ***** *****;
  
  %let prop = ((&num)/(&den));
  
  %if &mult = %then %let mult = 1;
  
  if ( ((&num_moe)*(&num_moe)) - ((&prop*&prop) * ((&den_moe)*(&den_moe))) ) >= 0 then do;
    &var = (&mult) * %moe_prop( num=&num, den=&den, num_moe=&num_moe, den_moe=&den_moe );
  end;
  else do; 
    &var = (&mult) * %moe_ratio( num=&num, den=&den, num_moe=&num_moe, den_moe=&den_moe );
  end;

  %if %length( &label_moe ) > 0 %then %do;
    label &var = &label_moe;
  %end;

%mend Moe_prop_a;


/************************ UNCOMMENT TO TEST ***************************

options mprint;

data A;

  prop = 45/100;
  %moe_prop_a( var=moe1, num=45, den=100, num_moe=10, den_moe=15 );
  put prop= moe1=;

  %moe_prop_a( var=moe2, num=45, den=100, num_moe=10, den_moe=0, mult=100 );
  put prop= moe2=;

  %moe_prop_a( var=moe3, num=45, den=100, num_moe=10, den_moe=15, label_moe="Margin of error" );
  put prop= moe3=;

run;

proc contents data=A;
run;

/**********************************************************************/

