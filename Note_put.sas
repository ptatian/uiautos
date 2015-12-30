/******************* URBAN INSTITUTE MACRO LIBRARY *********************
 
 Macro: Note_put

 Description: Write a macro-generated note message to the SAS LOG
 using PUT.
 
 Use: Within data step
 
 Author: Peter Tatian
 
***********************************************************************/

%macro Note_put( 
  Macro=,    /* Macro name */
  Msg=       /* Note message */
  );

  /*************************** USAGE NOTES *****************************
   
   SAMPLE CALL: 
     %Note_put( macro=MyMacro, Msg="This is a note." )

  *********************************************************************/

  /*************************** UPDATE NOTES ****************************

   11/07/04 - If Macro= parameter blank, does not include [macroname] in
              message.  Reformatted to hide resolved NOTE label in LOG.
   09/07/05 - Reformatted so that message will be displayed in color
              in SAS Enhanced Editor.

  *********************************************************************/

  %***** ***** ***** MACRO SET UP ***** ***** *****;
   
  %local SYL1 SYL2;
    
    
  %***** ***** ***** ERROR CHECKS ***** ***** *****;



  %***** ***** ***** MACRO BODY ***** ***** *****;

  %let SYL1 = "NO";
  
  %if %length( &macro ) = 0 %then %do;
    %let SYL2 = "TE:";
  %end;
  %else %do;
    %let SYL2 = "TE: [&Macro]";
  %end;
  
  put &SYL1 &SYL2 " " &Msg;

%mend Note_put;


/************************ UNCOMMENT TO TEST ***************************

data _null_;

  %Note_put( macro=MyMacro, Msg="This is a note." )

run;

/**********************************************************************/


