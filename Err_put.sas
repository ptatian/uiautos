/******************* URBAN INSTITUTE MACRO LIBRARY *********************
 
 Macro: Err_put

 Description: Write a macro-generated error message to the SAS LOG
 using PUT.
 
 Use: Within data step
 
 Author: Peter Tatian
 
***********************************************************************/

%macro Err_put( 
  Macro=,    /* Macro name */
  Msg=       /* Error message (space-separated character values) */
  );

  /*************************** USAGE NOTES *****************************
   
   SAMPLE CALL: 
     %Err_put( macro=MyMacro, Msg="Invalid parameter." )

  *********************************************************************/

  /*************************** UPDATE NOTES ****************************

  11/07/04 - If Macro= parameter blank, does not include [macroname] in
             message.  Reformatted to hide resolved ERROR label in LOG.
  09/06/05 - Reformatted so that message will be displayed in color
             in SAS Enhanced Editor.

  *********************************************************************/

  %***** ***** ***** MACRO SET UP ***** ***** *****;
   
  %local ERR1 ERR2;
    
    
  %***** ***** ***** ERROR CHECKS ***** ***** *****;



  %***** ***** ***** MACRO BODY ***** ***** *****;

  %let ERR1 = "ER";
  
  %if %length( &macro ) = 0 %then %do;
    %let ERR2 = "ROR:";
  %end;
  %else %do;
    %let ERR2 = "ROR: [&Macro]";
  %end;
  
  put &ERR1 &ERR2 " " &Msg;


  %***** ***** ***** CLEAN UP ***** ***** *****;

%mend Err_put;


/************************ UNCOMMENT TO TEST ***************************

data _null_;

  %Err_put( macro=MyMacro, Msg="Invalid parameter." )

run;

/**********************************************************************/

