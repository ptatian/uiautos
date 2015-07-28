/************************************************************************
 * Program:  ListIntersect.sas
 * Project:  UI SAS Macro Library
 * Author:   P. Tatian
 * Updated:  8/23/04
 * Version:  SAS 8.12
 * Environment:  Windows or Alpha
 * Use:      Within statement
 * 
 * Description:  Autocall macro to intersect entries from two lists.
 *
   Modifications:
   02/23/11  PAT  Added declaration for local macro vars.
 ************************************************************************/

/** Macro ListIntersect - Start Definition **/

%macro ListIntersect(
  list1,           /* List of items #1 */
  list2,           /* List of items #2 */
  delim=%str( )    /* Delimiter for list (def. blank char) */
  );
  
  %local ListIntersect scanlist1 scanlist2 i item;
  
  %let list1 = %ListNoDup( &list1, delim=&delim );
  %let list2 = %ListNoDup( &list2, delim=&delim );

  %let ListIntersect = ;
  %let scanlist1 = {{bol}}&delim&list1&delim{{eol}};
  %let scanlist2 = {{bol}}&delim&list2&delim{{eol}};
  
  %let i = 2;
  %let item = %scan( &scanlist1, &i, &delim );

  %do %while ( %length( &item ) > 0 and &item ~= {{eol}} );
    %if %index( &scanlist2, &delim&item&delim ) > 0 %then %do;
      %if %length( &ListIntersect ) = 0 %then
        %let ListIntersect = &item;
      %else
        %let ListIntersect = &ListIntersect&delim&item;
    %end;
    %let i = %eval( &i + 1 );
    %let item = %scan( &scanlist1, &i, &delim );
  %end;

  %let ListIntersect = %unquote( &ListIntersect );
  &ListIntersect

  %exit:

%mend ListIntersect;

/** End Macro Definition **/


/****** UNCOMMENT TO TEST MACRO ******

options mprint nosymbolgen nomlogic;

** Autocall macros **;

filename automac "K:\Metro\PTatian\UISUG\Uiautos\";
options sasautos=(automac sasautos);

%let list1 = Z A B C X Y E Y Z F G X;
%let list2 = A B C D W X Y Z;
%let result = z%ListIntersect( &list1, &list2 )z;
%put _user_;

%let list1 = A B C D E F G;
%let list2 = W X Y Z;
%let result = z%ListIntersect( &list1, &list2 )z;
%put _user_;

/***********************************************/

