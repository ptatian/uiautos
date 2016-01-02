/******************* URBAN INSTITUTE MACRO LIBRARY *********************
 
 Macro: Moe_sum

 Description: Autocall macro that returns a calculation for a margin of error 
 for a derived sum of values from the individual margins of error comprising
 the sum.
 
 Use: Function
 
 Author: Peter Tatian
 
***********************************************************************/

%macro moe_sum( 
  var=           /** List of variables containing MOE values to sum **/
  );

  /*************************** USAGE NOTES *****************************
   
   SAMPLE CALL: 
     %moe_sum( var=a_moe b_moe c_moe )
       returns calculation for margin of error based on sum of the 
       margins of error for three values a_moe, b_moe, and c_moe

  *********************************************************************/

  /*************************** UPDATE NOTES ****************************


  *********************************************************************/

  %***** ***** ***** MACRO SET UP ***** ***** *****;
   
  %local i v calc;
    
    
  %***** ***** ***** ERROR CHECKS ***** ***** *****;



  %***** ***** ***** MACRO BODY ***** ***** *****;
  
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


  %***** ***** ***** CLEAN UP ***** ***** *****;

%mend moe_sum;


/************************ UNCOMMENT TO TEST ***************************

options mprint;

data _null_;

  sum = 45 + 50 + 55;
  moe = %moe_sum( var=5 4 2 );
  put sum= moe=;

run;

/**********************************************************************/


