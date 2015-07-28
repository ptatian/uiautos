/************************************************************************
 * Program:  ListDelete.sas
 * Project:  UI SAS Macro Library
 * Author:   P. Tatian
 * Updated:  8/23/04
 * Version:  SAS 8.12
 * Environment:  Windows or Alpha
 * Use:      Within statement
 * 
 * Description:  Autocall macro to remove entries from a list of items.
 *
   Modifications:
   02/23/11  PAT  Added declaration for local macro vars.
 ************************************************************************/

/** Macro ListDelete - Start Definition **/

%macro ListDelete(
  list1,           /* List of items */
  list2,           /* Items to remove from list */
  delim=%str( )    /* Delimiter for list (def. blank char) */
  );

  %local Err1 Err2 ListDelete scanlist1 scanlist2 i item;

  %if &delim = { or &delim = } %then %do;
    %let Err1 = ER;
    %let Err2 = ROR;
    %put &Err1&Err2[ListDelete]:  Curly braces { } cannot be used as list delimiters.;
    %goto exit;
  %end;

  %if %index( &list1, {{bol}} ) > 0 or %index( &list1, {{eol}} ) > 0 or 
      %index( &list2, {{bol}} ) > 0 or %index( &list2, {{eol}} ) > 0 %then %do;
    %let Err1 = ER;
    %let Err2 = ROR;
    %put &Err1&Err2[ListDelete]:  The text "{{bol}}" or "{{eol}}" must not appear in either list.;
    %goto exit;
  %end;

  %let ListDelete = ;
  %let scanlist1 = {{bol}}&delim&list1&delim{{eol}};
  %let scanlist2 = {{bol}}&delim&list2&delim{{eol}};
  
  %let i = 2;
  %let item = %scan( &scanlist1, &i, &delim );

  %do %while ( %length( &item ) > 0 and &item ~= {{eol}} );
    %if %index( &scanlist2, &delim&item&delim ) = 0 %then %do;
      %if %length( &ListDelete ) = 0 %then
        %let ListDelete = &item;
      %else
        %let ListDelete = &ListDelete&delim&item;
    %end;
    %let i = %eval( &i + 1 );
    %let item = %scan( &scanlist1, &i, &delim );
  %end;

  %let ListDelete = %unquote( &ListDelete );
  &ListDelete

  %exit:

%mend ListDelete;

/** End Macro Definition **/


/****** UNCOMMENT TO TEST MACRO ******

options mprint nosymbolgen nomlogic;

%let list1 = Z A B C X D Y E Y Z F G X;
%let list2 = X Y Z;
%let del = z%ListDelete( &list1, &list2 )z;
%put _user_;

%let list1 = Z A B C X D Y E Y Z F G X;
%let list2 = XX Y Z;
%let del = z%ListDelete( &list1, &list2 )z;
%put _user_;

%let list1 = Z A B C XX D Y E Y Z F G X;
%let list2 = X Y Z;
%let del = z%ListDelete( &list1, &list2 )z;
%put _user_;

%let list1 = A B C;
%let list2 = X Y Z;
%let del = z%ListDelete( &list1, &list2 )z;
%put _user_;

%let list1 = A B C;
%let list2 = A B C;
%let del = z%ListDelete( &list1, &list2 )z;
%put _user_;

%let list1 = Z.A.B.C.X.D.Y.E.Y.Z.F.G.X;
%let list2 = X.Y.Z;
%let del = z%ListDelete( &list1, &list2, delim=. )z;
%put _user_;

/***********************************************/

