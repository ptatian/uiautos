/************************************************************************
 * Program:  GetProgName.sas
 * Project:  UI SAS Macro Library
 * Author:   P. Tatian
 * Updated:  8/17/04
 * Version:  SAS 8.12 (Windows version)
 * 
 * Description:  Autocall macro to return the name of the currently 
 *   submitted SAS program to the global macro variable given by VAR.  
 *   If running in interactive mode, macro returns "(Interactive)".
 *
 * Updated:
 *  03/02/06  Changed %sysfunc to %qsysfunc in %let index = ... line
 *            to handle program names with special characters.
 ************************************************************************/

** Macro GetProgName - Start Definition **;

%macro GetProgName( var );

  %global &var;

  %let FullName = %sysfunc( getoption( sysin ) );
  
  %if &SYSSCP = WIN %then
    %let dirchar = \;
  %else
    %let dirchar = ];
  
  %if %length( &FullName ) > 0 %then %do;
    %let len = %length( &FullName );
    %let index = %index( %qsysfunc( reverse( &FullName ) ),&dirchar );
    %let ProgName = %substr( &FullName, &len - &index + 2 );
    %let &var = &ProgName;
  %end;
  %else %do;
    %let &var = (Interactive);
  %end;

%mend GetProgName;

** End Macro Definition **;

