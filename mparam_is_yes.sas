/******************* URBAN INSTITUTE MACRO LIBRARY *********************
 
 Macro: mparam_is_yes

 Description: Returns 1 if the macro parameter value is "Yes" 
 (could be "y", "Y", "Yes", "YE", etc.)
 
 Use: Function
 
 Author: Peter Tatian
 
***********************************************************************/

%macro mparam_is_yes( 
  param   /** Macro parameter value to test (must resolve to a single value) **/
  );

  /*************************** USAGE NOTES *****************************
   
   SAMPLE CALL: 
     %mparam_is_yes( &quiet )

  *********************************************************************/

  /*************************** UPDATE NOTES ****************************


  *********************************************************************/

  %***** ***** ***** MACRO SET UP ***** ***** *****;
   
    %local ;
    
    
  %***** ***** ***** ERROR CHECKS ***** ***** *****;

  

  %***** ***** ***** MACRO BODY ***** ***** *****;
  
  %if %quote(%upcase((&param))) = %quote((Y)) or
      %quote(%upcase((&param))) = %quote((YE)) or
      %quote(%upcase((&param))) = %quote((YES)) %then %do;
    1
  %end;
  %else %do;
    0
  %end;
  
  %***** ***** ***** CLEAN UP ***** ***** *****;

  
  
%mend mparam_is_yes;


/************************ UNCOMMENT TO TEST ***************************

  %let p = Y;
  %let result = %mparam_is_yes( &p );
  %put p=&p result=&result;
  
  %let p = Ye;
  %let result = %mparam_is_yes( &p );
  %put p=&p result=&result;

  %let p = yEs;
  %let result = %mparam_is_yes( &p );
  %put p=&p result=&result;
  
  %let p = No;
  %let result = %mparam_is_yes( &p );
  %put p=&p result=&result;
  
  %let p = ;
  %let result = %mparam_is_yes( &p );
  %put p=&p result=&result;

/**********************************************************************/

