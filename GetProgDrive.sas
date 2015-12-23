/******************* URBAN INSTITUTE MACRO LIBRARY *********************
 
 Macro: GetProgDrive

 Description: Autocall macro to return the drive letter of the currently 
 submitted SAS program to the global macro variable given by VAR.  
 If running in interactive mode, macro returns blank. 
 
 Use: Function
 
 Author: Peter Tatian
 
***********************************************************************/

%macro GetProgDrive( var );

  /*************************** USAGE NOTES *****************************
   
   SAMPLE CALL: 
     %GetProgDrive( _pdrive )
       saves drive letter of current program to macro var _pdrive

  *********************************************************************/

  /*************************** UPDATE NOTES ****************************

  7/28/15  Program created

  *********************************************************************/

  %***** ***** ***** MACRO SET UP ***** ***** *****;
   
  %global &var;
  %local FullName;
    
    
  %***** ***** ***** ERROR CHECKS ***** ***** *****;



  %***** ***** ***** MACRO BODY ***** ***** *****;

  %let FullName = %sysfunc( getoption( sysin ) );
  
  %if %length( &FullName ) > 0 %then %do;
    %let &var = %upcase(%substr( &FullName, 1, 1 ));
  %end;
  %else %do;
    %let &var = ;
  %end;


  %***** ***** ***** CLEAN UP ***** ***** *****;

%mend GetProgDrive;


/************************ UNCOMMENT TO TEST ***************************

%GetProgDrive( _pdrive )

%put _user_;

/**********************************************************************/
