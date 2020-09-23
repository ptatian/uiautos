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
  9/23/20  Modified to return the computer name for network pathnames. 
           Example: Return "\\SAS1" for pathname "\\sas1\DCData\Libraries".

  *********************************************************************/

  %***** ***** ***** MACRO SET UP ***** ***** *****;
   
  %global &var;
  %local FullName;
    
    
  %***** ***** ***** ERROR CHECKS ***** ***** *****;



  %***** ***** ***** MACRO BODY ***** ***** *****;

  %let FullName = %sysfunc( getoption( sysin ) );
  
  %if %length( &FullName ) > 1 %then %do;
    %if %substr( &FullName, 1, 2 ) = \\ %then %do;
      %let &var = %upcase(%substr( &Fullname, 1, %index( %substr( &Fullname, 3 ), \ ) + 1 ));
    %end;
    %else %do;
      %let &var = %upcase(%substr( &FullName, 1, 1 ));
    %end; 
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
