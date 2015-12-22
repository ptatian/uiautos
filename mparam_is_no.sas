/******************* URBAN INSTITUTE MACRO LIBRARY *********************
 
 Macro: mparam_is_no

 Description: Returns 1 if the macro parameter value is "No" 
 (could be "n", "N", "nO", etc.)
 
 Use: Function
 
 Author: Peter Tatian
 
***********************************************************************/

%macro mparam_is_no( 
  param   /** Macro parameter value to test (must resolve to a single value) **/
  );

  /*************************** USAGE NOTES *****************************
   
   SAMPLE CALL: 
     %mparam_is_no( &quiet )

  *********************************************************************/

  /*************************** UPDATE NOTES ****************************


  *********************************************************************/

  %***** ***** ***** MACRO SET UP ***** ***** *****;
   
    %local ;
    
    
  %***** ***** ***** ERROR CHECKS ***** ***** *****;

  

  %***** ***** ***** MACRO BODY ***** ***** *****;
  
  %if %quote(%upcase((&param))) = %quote((N)) or
      %quote(%upcase((&param))) = %quote((NO)) %then %do;
    1
  %end;
  %else %do;
    0
  %end;
  
  %***** ***** ***** CLEAN UP ***** ***** *****;

  
  
%mend mparam_is_no;


/************************ UNCOMMENT TO TEST ***************************

  *options mprint symbolgen mlogic;

  %let p = n;
  %let result = %mparam_is_no( &p );
  %put p=&p result=&result;

  %let p = No;
  %let result = %mparam_is_no( &p );
  %put p=&p result=&result;
  
  %let p = Not;
  %let result = %mparam_is_no( &p );
  %put p=&p result=&result;
  
  %let p = Y;
  %let result = %mparam_is_no( &p );
  %put p=&p result=&result;
  
  %let p = ;
  %let result = %mparam_is_no( &p );
  %put p=&p result=&result;

/**********************************************************************/

