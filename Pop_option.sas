/******************* URBAN INSTITUTE MACRO LIBRARY *********************
 
 Macro: Pop_option

 Description: Pop specified SAS system option from top of stack and 
 restore as current option value.
 
 Use: Open code
 
 Author: Peter Tatian
 
***********************************************************************/

%macro Pop_option( 
  option,    /** Name of option value to restore **/
  quiet=N    /** QUIET=Y to suppress LOG messages **/
  );

  /*************************** USAGE NOTES *****************************
   
   SAMPLE CALL: 
     %Pop_option( obs )
       restores the most recently saved obs= option value

  *********************************************************************/

  /*************************** UPDATE NOTES ****************************


  *********************************************************************/

  %***** ***** ***** MACRO SET UP ***** ***** *****;
   
  %global _&option._stack;
  %local new_stack i opt;

   
  %***** ***** ***** ERROR CHECKS ***** ***** *****;



  %***** ***** ***** MACRO BODY ***** ***** *****;

  %let option_val = %scan( &&&_&option._stack, 1 );
  
  %if &option_val = %then %do;
    %err_mput( macro=Pop_option, msg=No value of %upcase(&option) was saved with the Push_option() macro. )
    %goto exit_macro;
  %end;
  
  %** Restore saved system option value **;
  
  options &option_val;
  
  %if not %mparam_is_yes( &quiet ) %then %do;
    %note_mput( macro=Pop_option, msg=System option %upcase(&option_val) restored. )
  %end;
  
  %** Remove top option value from stack **;
  
  %let new_stack = ;
  %let i = 2;
  %let opt = %scan( &&&_&option._stack, &i );
  
  %do %while ( &opt ~= );
  
    %let new_stack = &new_stack &opt;
    
    %let i = %eval( &i + 1 );
    %let opt = %scan( &&&_&option._stack, &i );
  
  %end;

  %let _&option._stack=&new_stack;
  
  %* %put _&option._stack=&&&_&option._stack;
  
  %exit_macro:
  
  %**put _user_;


  %***** ***** ***** CLEAN UP ***** ***** *****;

%mend Pop_option;


/************************ UNCOMMENT TO TEST ***************************


filename uiautos "K:\Metro\PTatian\UISUG\Uiautos";
options sasautos=(uiautos sasautos);

*options mprint symbolgen mlogic;
options nomprint;

%Push_option( mprint )

options mprint;

%Push_option( obs )

options obs=10;
%Push_option( obs, quiet=y )

options obs=0;
%Push_option( obs )

%Pop_option( obs )
%Pop_option( obs )
%Pop_option( obs )

%Pop_option( mprint )

%Pop_option( orientation )

/**********************************************************************/
