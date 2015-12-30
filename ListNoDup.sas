/******************* URBAN INSTITUTE MACRO LIBRARY *********************
 
 Macro: ListNoDup

 Description: Autocall macro returns list with duplicate entries 
 removed.
 
 Use: Function
 
 Author: Peter Tatian
 
***********************************************************************/

%macro ListNoDup(
  list,           /* List of items */
  delim=%str( )   /* Delimiter for list (def. blank char) */
  );

  /*************************** USAGE NOTES *****************************
   
   SAMPLE CALL: 
     %ListNoDup( A.B.C.D.E.B.F.A.C.G, delim=. )
       returns unduplicated list A.B.C.D.E.F.G

  *********************************************************************/

  /*************************** UPDATE NOTES ****************************


  *********************************************************************/

  %***** ***** ***** MACRO SET UP ***** ***** *****;
   
  %local ListNoDup scanlist item;
    
    
  %***** ***** ***** ERROR CHECKS ***** ***** *****;

  %if &delim = { or &delim = } %then %do;
    %err_mput( macro=ListNoDup, msg=Curly braces { } cannot be used as list delimiters. )
    %goto exit;
  %end;

  %if %index( &list, {{bol}} ) > 0 or %index( &list, {{eol}} ) > 0 %then %do;
    %err_mput( macro=ListNoDup, msg=The text "{{bol}}" or "{{eol}}" must not appear in the list. )
    %goto exit;
  %end;

  %***** ***** ***** MACRO BODY ***** ***** *****;

  %let ListNoDup = ;
  %let scanlist = {{bol}}&delim&list&delim{{eol}};
  %let item = %scan( &scanlist, 2, &delim );

  %do %while ( %length( &item ) > 0 and &item ~= {{eol}} );
    %if %length( &ListNoDup ) = 0 %then
      %let ListNoDup = &item;
    %else
      %let ListNoDup = &ListNoDup&delim&item;
    %let scanlist = %sysfunc( tranwrd( &scanlist, &delim&item&delim, &delim ) );
    %let item = %scan( &scanlist, 2, &delim );
  %end;

  %let ListNoDup = %unquote( &ListNoDup );
  &ListNoDup

  %exit:


  %***** ***** ***** CLEAN UP ***** ***** *****;

%mend ListNoDup;


/************************ UNCOMMENT TO TEST ***************************

**options mprint symbolgen mlogic;

filename uiautos "K:\Metro\PTatian\UISUG\Uiautos";
options sasautos=(uiautos sasautos);

%let list = A{B{C{D{E{B{F{A{C{G;
%let undup = [%ListNoDup( &list, delim={ )];
%put _user_;

%let list = A B {{bol}} C D;
%let undup = [%ListNoDup( &list )];
%put _user_;

%let list = A.B.C.D.E.B.F.A.C.G;
%let undup = [%ListNoDup( &list, delim=. )];
%put _user_;

%let list = .A.B.C.D.E.B.F.A.C.G.;
%let undup = [%ListNoDup( &list, delim=. )];
%put _user_;

%let list = ..A...B.C..D.E.B.F.A.C.G;
%let undup = [%ListNoDup( &list, delim=. )];
%put _user_;

%let list = A B C D E B F A C G;
%let undup = [%ListNoDup( &list )];
%put _user_;

%let list = %str(   A   B   C   D E B    F A  C   G   );
%let undup = [%ListNoDup( &list )];
%put _user_;

%let list = A B C AA AAA D E B AA F A C G AAAA;
%let undup = [%ListNoDup( &list )];
%put _user_;

/**********************************************************************/

