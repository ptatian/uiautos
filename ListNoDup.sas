/************************************************************************
 * Program:  ListNoDup.sas
 * Project:  UI SAS Macro Library
 * Author:   P. Tatian
 * Updated:  8/23/04
 * Version:  SAS 8.12
 * Environment:  Windows or Alpha
 * Use:      Within statement
 * 
 * Description:  Autocall macro to remove duplicate entries 
 * from a list of items.
 *
 ************************************************************************/

/** Macro ListNoDup - Start Definition **/

%macro ListNoDup(
  list,           /* List of items */
  delim=%str( )   /* Delimiter for list (def. blank char) */
  );

  %if &delim = { or &delim = } %then %do;
    %let Err1 = ER;
    %let Err2 = ROR;
    %put &Err1&Err2[ListNoDup]:  Curly braces { } cannot be used as list delimit
ers.;
    %goto exit;
  %end;

  %if %index( &list, {{bol}} ) > 0 or %index( &list, {{eol}} ) > 0 %then %do;
    %let Err1 = ER;
    %let Err2 = ROR;
    %put &Err1&Err2[ListNoDup]:  The text "{{bol}}" or "{{eol}}" must not appear
 in the list.;
    %goto exit;
  %end;

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

%mend ListNoDup;

/** End Macro Definition **/

/****** UNCOMMENT TO TEST MACRO ******

options mprint symbolgen mlogic;

%let list = A{B{C{D{E{B{F{A{C{G;
%let undup = z%ListNoDup( &list, delim={ )z;
%put _user_;

%let list = A B {{bol}} C D;
%let undup = z%ListNoDup( &list )z;
%put _user_;

%let list = A.B.C.D.E.B.F.A.C.G;
%let undup = z%ListNoDup( &list, delim=. )z;
%put _user_;

%let list = .A.B.C.D.E.B.F.A.C.G.;
%let undup = z%ListNoDup( &list, delim=. )z;
%put _user_;

%let list = ..A...B.C..D.E.B.F.A.C.G;
%let undup = z%ListNoDup( &list, delim=. )z;
%put _user_;

%let list = A B C D E B F A C G;
%let undup = z%ListNoDup( &list )z;
%put _user_;

%let list = %str(   A   B   C   D E B    F A  C   G   );
%let undup = z%ListNoDup( &list )z;
%put _user_;

%let list = A B C AA AAA D E B AA F A C G AAAA;
%let undup = z%ListNoDup( &list )z;
%put _user_;

/***********************************************/

