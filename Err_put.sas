/************************************************************************
* Program:  Err_put.sas
* Project:  UI SAS Macro Library
* Author:   P. Tatian
* Updated:  10/28/04
* Version:  SAS 8.2
* 
* Description:  Write a macro-generated error message to the SAS LOG.
*               Uses PUT
*
* Modifications:
*  11/07/04 - If Macro= parameter blank, does not include [macroname] in
*             message.  Reformatted to hide resolved ERROR label in LOG.
*  09/06/05 - Reformatted so that message will be displayed in color
*             in SAS Enhanced Editor.
************************************************************************/

/** Macro Err_put - Start Definition **/

%macro Err_put( 
  Macro=,    /* Macro name */
  Msg=       /* Error message (space-separated character values) */
  );

  %let ERR1 = "ER";
  
  %if %length( &macro ) = 0 %then %do;
    %let ERR2 = "ROR:";
  %end;
  %else %do;
    %let ERR2 = "ROR: [&Macro]";
  %end;
  
  put &ERR1 &ERR2 " " &Msg;

%mend Err_put;

/** End Macro Definition **/

