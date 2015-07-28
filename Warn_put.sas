/************************************************************************
* Program:  Warn_put.sas
* Project:  UI SAS Macro Library
* Author:   P. Tatian
* Updated:  10/28/04
* Version:  SAS 8.2
* 
* Description:  Write a macro-generated warning message to the SAS LOG.
*               Uses PUT
*
* Modifications:
*  11/07/04 - If Macro= parameter blank, does not include [macroname] in
*             message.  Reformatted to hide resolved WARNING label in LOG.
*  09/06/05 - Reformatted so that message will be displayed in color
*             in SAS Enhanced Editor.
************************************************************************/

/** Macro Warn_put - Start Definition **/

%macro Warn_put( 
  Macro=,    /* Macro name */
  Msg=       /* Error message (space-separated character values) */
  );

  %let SYL1 = "WARN";
  
  %if %length( &macro ) = 0 %then %do;
    %let SYL2 = "ING:";
  %end;
  %else %do;
    %let SYL2 = "ING: [&Macro]";
  %end;
  
  put &SYL1 &SYL2 " " &Msg;

%mend Warn_put;

/** End Macro Definition **/

