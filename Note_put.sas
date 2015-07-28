/************************************************************************
* Program:  Note_put.sas
* Project:  UI SAS Macro Library
* Author:   P. Tatian
* Updated:  10/28/04
* Version:  SAS 8.2
* 
* Description:  Write a macro-generated note to the SAS LOG.
*               Uses PUT
*
* Modifications:
*  11/07/04 - If Macro= parameter blank, does not include [macroname] in
*             message.  Reformatted to hide resolved NOTE label in LOG.
*  09/07/05 - Reformatted so that message will be displayed in color
*             in SAS Enhanced Editor.
************************************************************************/

/** Macro Note_put - Start Definition **/

%macro Note_put( 
  Macro=,    /* Macro name */
  Msg=       /* Note message */
  );

  %let SYL1 = "NO";
  
  %if %length( &macro ) = 0 %then %do;
    %let SYL2 = "TE:";
  %end;
  %else %do;
    %let SYL2 = "TE: [&Macro]";
  %end;
  
  put &SYL1 &SYL2 " " &Msg;

%mend Note_put;

/** End Macro Definition **/

