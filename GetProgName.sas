/******************* URBAN INSTITUTE MACRO LIBRARY *********************
 
 Macro: GetProgName

 Description: Autocall macro to return the name of the currently 
 submitted SAS program to the global macro variable given by VAR.  
 If running in interactive mode, macro returns "(Interactive)".
 
 Use: Open code
 
 Author: Peter Tatian
 
***********************************************************************/

%macro GetProgName( var );

  /*************************** USAGE NOTES *****************************
   
   SAMPLE CALL: 
     %GetProgName( prog )
       saves the name of the currently submitted SAS program to the
       macro variable PROG

  *********************************************************************/

  /*************************** UPDATE NOTES ****************************

   03/02/06  Changed %sysfunc to %qsysfunc in %let index = ... line
             to handle program names with special characters.

  *********************************************************************/

  %***** ***** ***** MACRO SET UP ***** ***** *****;
   
  %global &var;
  %local dirchar len index ProgName;
    
    
  %***** ***** ***** ERROR CHECKS ***** ***** *****;



  %***** ***** ***** MACRO BODY ***** ***** *****;

  %let FullName = %sysfunc( getoption( sysin ) );
  
  %if &SYSSCP = WIN %then
    %let dirchar = \;
  %else %do;
    %err_mput( macro=GetProgName, msg=Operating system not supported. )
    %goto exit;
  %end;
  
  %if %length( &FullName ) > 0 %then %do;
    %let len = %length( &FullName );
    %let index = %index( %qsysfunc( reverse( &FullName ) ),&dirchar );
    %let ProgName = %substr( &FullName, &len - &index + 2 );
    %let &var = &ProgName;
  %end;
  %else %do;
    %let &var = (Interactive);
  %end;
  
  %exit:


  %***** ***** ***** CLEAN UP ***** ***** *****;

%mend GetProgName;


/************************ UNCOMMENT TO TEST ***************************

%GetProgName( prog );

%put prog=&prog;

/**********************************************************************/

