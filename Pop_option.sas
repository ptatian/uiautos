/* Pop_option.sas - UI SAS Autocall Macro Library
 *
 * Pop specified SAS system option from top of stack and restore as
 * current option value.
 *
 * NB:  Program written for SAS Version 8.2
 *
 * 09/06/05  Peter A. Tatian
   02/23/11  PAT  Added declaration for local macro vars.
 ****************************************************************************/

/** Macro Pop_option - Start Definition **/

%macro Pop_option( option, quiet=N );

  %**put _user_;
  
  %let quiet = %upcase(&quiet);
  
  %global _&option._stack;
  %local new_stack i opt;

  %let option_val = %scan( &&&_&option._stack, 1 );
  
  %if &option_val = %then %do;
    %err_mput( macro=Pop_option, msg=No value of %upcase(&option) was saved with the Push_option() macro. )
    %goto exit_macro;
  %end;
  
  %** Restore saved system option value **;
  
  options &option_val;
  
  %if &quiet = N %then %do;
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

%mend Pop_option;

/** End Macro Definition **/


/********** UNCOMMENT TO TEST **************************

filename uidev "D:\Projects\UISUG\MacroDev";
filename uiautos "K:\Metro\PTatian\UISUG\Uiautos";
options sasautos=(uidev uiautos sasautos);

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

/********************************************************/

