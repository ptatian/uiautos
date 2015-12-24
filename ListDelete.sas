/******************* URBAN INSTITUTE MACRO LIBRARY *********************
 
 Macro: ListDelete

 Description: Autocall macro to remove entries from a list of items.
 
 Use: Function
 
 Author: Peter Tatian
 
***********************************************************************/

%macro ListDelete(
  list1,           /* List of items */
  list2,           /* Items to remove from list */
  delim=%str( )    /* Delimiter for list (def. blank char) */
  );

  /*************************** USAGE NOTES *****************************
   
   SAMPLE CALL: 
     %ListDelete( &list1, &list2 )
       returns list with items in &list2 deleted from &list1

  *********************************************************************/

  /*************************** UPDATE NOTES ****************************

   02/23/11  PAT  Added declaration for local macro vars.

  *********************************************************************/

  %***** ***** ***** MACRO SET UP ***** ***** *****;
   
  %local Err1 Err2 ListDelete scanlist1 scanlist2 i item;
    
    
  %***** ***** ***** ERROR CHECKS ***** ***** *****;

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


  %***** ***** ***** MACRO BODY ***** ***** *****;

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


  %***** ***** ***** CLEAN UP ***** ***** *****;

%mend ListDelete;

/** End Macro Definition **/


/************************ UNCOMMENT TO TEST ***************************

options mprint nosymbolgen nomlogic;

%let list1 = Z A B C X D Y E Y Z F G X;
%let list2 = X Y Z;
%let del = [%ListDelete( &list1, &list2 )];
%put _user_;

%let list1 = Z A B C X D Y E Y Z F G X;
%let list2 = XX Y Z;
%let del = [%ListDelete( &list1, &list2 )];
%put _user_;

%let list1 = Z A B C XX D Y E Y Z F G X;
%let list2 = X Y Z;
%let del = [%ListDelete( &list1, &list2 )];
%put _user_;

%let list1 = A B C;
%let list2 = X Y Z;
%let del = [%ListDelete( &list1, &list2 )];
%put _user_;

%let list1 = A B C;
%let list2 = A B C;
%let del = [%ListDelete( &list1, &list2 )];
%put _user_;

%let list1 = Z.A.B.C.X.D.Y.E.Y.Z.F.G.X;
%let list2 = X.Y.Z;
%let del = [%ListDelete( &list1, &list2, delim=. )];
%put _user_;

/**********************************************************************/

