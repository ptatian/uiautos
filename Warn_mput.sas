/******************* URBAN INSTITUTE MACRO LIBRARY *********************
 
 Macro: Warn_mput

 Description: Write a macro-generated warning message to the SAS LOG
 using %PUT.
 
 Use: Open code
 
 Author: Peter Tatian
 
***********************************************************************/

%macro Warn_mput( 
  Macro=,    /* Macro name */
  Msg=       /* Message */
  );

  /*************************** USAGE NOTES *****************************
   
   SAMPLE CALL: 
     %Warn_mput( macro=MyMacro, Msg=Invalid parameter. )

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

  %let SYL1 = WARN;
  
  %if %length( &macro ) = 0 %then %do;
    %let SYL2 = ING:;
  %end;
  %else %do;
    %let SYL2 = ING: [&Macro];
  %end;
  
  %put &SYL1&SYL2 &Msg;


  %***** ***** ***** CLEAN UP ***** ***** *****;

%mend Warn_mput;


/************************ UNCOMMENT TO TEST ***************************

%Warn_mput( macro=MyMacro, Msg=Test warning message. )

/**********************************************************************/
