/************************************************************************
 * Program:  GetProgDrive.sas
 * Project:  UI SAS Macro Library
 * Author:   P. Tatian
 * Updated:  7/28/15
 * Version:  SAS 9.2 (Windows version)
 * 
 * Description:  Autocall macro to return the drive letter of the currently 
 *   submitted SAS program to the global macro variable given by VAR.  
 *   If running in interactive mode, macro returns blank. 
 *
 * Updated:
 ************************************************************************/

** Macro GetProgDrive - Start Definition **;

%macro GetProgDrive( var );

  %global &var;

  %let FullName = %sysfunc( getoption( sysin ) );
  
  %if %length( &FullName ) > 0 %then %do;
    %let &var = %upcase(%substr( &FullName, 1, 1 ));
  %end;
  %else %do;
    %let &var = ;
  %end;

%mend GetProgDrive;

** End Macro Definition **;


/************** UNCOMMENT TO TEST ****************

%GetProgDrive( _pdrive )

%put _user_;

/**************************************************/
