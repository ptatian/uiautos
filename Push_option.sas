/******************* URBAN INSTITUTE MACRO LIBRARY *********************
 
 Macro: Push_option

 Description: Push specified SAS system option unto top of stack for later
 recovery through %Pop_option macro.
 
 Use: Open code
 
 Author: Peter Tatian
 
***********************************************************************/

%macro Push_option( 
  option, 
  quiet=N 
  );

  /*************************** USAGE NOTES *****************************
   
   SAMPLE CALL: 
     %Push_option( obs )

  *********************************************************************/

  /*************************** UPDATE NOTES ****************************

   09/06/05  Peter A. Tatian

  *********************************************************************/

  %***** ***** ***** MACRO SET UP ***** ***** *****;
   
  %local option_val;
    
    
  %***** ***** ***** ERROR CHECKS ***** ***** *****;



  %***** ***** ***** MACRO BODY ***** ***** *****;

  %let option_val = %sysfunc(getoption(&option,keyword));
  
  %if &option_val = %then %do;
    %err_mput( macro=Push_option, msg=%upcase(&option) is not a valid SAS system option. )
    %goto exit_macro;
  %end;
  
  %global _&option._stack;

  %let _&option._stack=&option_val &&&_&option._stack;
  
  %* %put _&option._stack=&&&_&option._stack;
  
  %if not %mparam_is_yes( &quiet ) %then %do;
    %note_mput( macro=Push_option, msg=System option %upcase(&option_val) saved. )
  %end;
  
  %exit_macro:
  

  %***** ***** ***** CLEAN UP ***** ***** *****;

%mend Push_option;


/************************ UNCOMMENT TO TEST ***************************

filename uiautos "K:\Metro\PTatian\UISUG\Uiautos";
options sasautos=(uiautos sasautos);

options mprint;

%Push_option( mprint )
%put _user_;

%Push_option( obs )
%put _user_;

options obs=10;
%Push_option( obs, quiet=y )
%put _user_;

options obs=0;
%Push_option( obs )
%put _user_;

%Push_option( invalidoption )
%put _user_;

options nomprint;
%Push_option( mprint )
%put _user_;

/**********************************************************************/
