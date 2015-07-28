/************************************************************************
 * Program:  ListUnion.sas
 * Project:  UI SAS Macro Library
 * Author:   P. Tatian
 * Updated:  8/23/04
 * Version:  SAS 8.12
 * Environment:  Windows or Alpha
 * Use:      Within statement
 * 
 * Description:  Autocall macro to create a union of items between
 * two lists.  All duplicates are removed.
 *
 ************************************************************************/

/** Macro ListUnion - Start Definition **/

%macro ListUnion(
  list1,           /* List of items #1 */
  list2,           /* List of items #2 */
  delim=%str( )    /* Delimiter for list (def. blank char) */
  );

  %let ListUnion = %ListNoDup( %unquote( &list1&delim&list2 ), delim=&delim );
  &ListUnion

  %exit:

%mend ListUnion;

/** End Macro Definition **/

/****** UNCOMMENT TO TEST MACRO ******

options mprint symbolgen mlogic;

** Autocall macros **;

filename automac "K:\Metro\PTatian\UISUG\Uiautos\";
options sasautos=(automac sasautos);

%let list1 = A B C D;
%let list2 = E F G;
%let union = z%ListUnion( &list1, &list2 )z;
%put _user_;

%let list1 = A B C D;
%let list2 = A B E F D G;
%let union = z%ListUnion( &list1, &list2 )z;
%put _user_;

/***********************************************/

