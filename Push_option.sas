/* Push_option.sas - UI SAS Autocall Macro Library
 *
 * Push specified SAS system option unto top of stack for later
 * recovery through %Pop_option macro.
 *
 * NB:  Program written for SAS Version 8.2
 *
 * 09/06/05  Peter A. Tatian
 ****************************************************************************/

/** Macro Push_macro - Start Definition **/

%macro Push_option( option, quiet=N );

  %**put _user_;
  
  %let quiet = %upcase(&quiet);
  
  %let option_val = %sysfunc(getoption(&option,keyword));
  
  %if &option_val = %then %do;
    %err_mput( macro=Push_option, msg=%upcase(&option) is not a valid SAS system option. )
    %goto exit_macro;
  %end;
  
  %global _&option._stack;

  %let _&option._stack=&option_val &&&_&option._stack;
  
  %* %put _&option._stack=&&&_&option._stack;
  
  %if &quiet = N %then %do;
    %note_mput( macro=Push_option, msg=System option %upcase(&option_val) saved. )
  %end;
  
  %exit_macro:
  
  %**put _user_;

%mend Push_option;

/** End Macro Definition **/

/********** UNCOMMENT TO TEST **************************

filename uidev "D:\Projects\UISUG\MacroDev";
filename uiautos "K:\Metro\PTatian\UISUG\Uiautos";
options sasautos=(uidev uiautos sasautos);

options mprint;

%Push_option( mprint )

%Push_option( obs )
options obs=10;
%Push_option( obs, quiet=y )
options obs=0;
%Push_option( obs )

%Push_option( invalidoption )

options nomprint;

%Push_option( mprint )

/********************************************************/

