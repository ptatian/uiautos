/******************* URBAN INSTITUTE MACRO LIBRARY *********************
 
 Macro: Err_mput

 Description: Write a macro-generated error message to the SAS LOG
 using %PUT.
 
 Use: Open code; Within macro
 
 Author: Peter Tatian
 
***********************************************************************/

%macro Err_mput( 
  Macro=,    /* Macro name */
  Msg=       /* Error message (macro string) */
  );

  /*************************** USAGE NOTES *****************************
   
   SAMPLE CALL: 
     %Err_mput( macro=MyMacro, Msg=Invalid parameter. )

  *********************************************************************/

  /*************************** UPDATE NOTES ****************************

  11/07/04 - If Macro= parameter blank, does not include [macroname] in
             message.  
  09/06/05 - Reformatted so that message will be displayed in color
             in SAS Enhanced Editor.

  *********************************************************************/

  %***** ***** ***** MACRO SET UP ***** ***** *****;
   
  %local SYL1 SYL2;
    
    
  %***** ***** ***** ERROR CHECKS ***** ***** *****;



  %***** ***** ***** MACRO BODY ***** ***** *****;

  %let SYL1 = ER;
  
  %if %length( &macro ) = 0 %then %do;
    %let SYL2 = ROR:;
  %end;
  %else %do;
    %let SYL2 = ROR: [&Macro];
  %end;
  
  %put &SYL1&SYL2 &Msg;


  %***** ***** ***** CLEAN UP ***** ***** *****;

%mend Err_mput;



/************************ UNCOMMENT TO TEST ***************************

%Err_mput( macro=MyMacro, Msg=Invalid parameter. )

/**********************************************************************/
