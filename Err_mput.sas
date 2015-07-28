/************************************************************************
* Program:  Err_mput.sas
* Project:  UI SAS Macro Library
* Author:   P. Tatian
* Updated:  10/28/04
* Version:  SAS 8.2
* 
* Description:  Write a macro-generated error message to the SAS LOG.
*               Uses %PUT
*
* Modifications:
*  11/07/04 - If Macro= parameter blank, does not include [macroname] in
*             message.  
*  09/06/05 - Reformatted so that message will be displayed in color
*             in SAS Enhanced Editor.
************************************************************************/

/** Macro Err_mput - Start Definition **/

%macro Err_mput( 
  Macro=,    /* Macro name */
  Msg=       /* Error message */
  );

  %let SYL1 = ER;
  
  %if %length( &macro ) = 0 %then %do;
    %let SYL2 = ROR:;
  %end;
  %else %do;
    %let SYL2 = ROR: [&Macro];
  %end;
  
  %put &SYL1&SYL2 &Msg;

%mend Err_mput;

/** End Macro Definition **/

