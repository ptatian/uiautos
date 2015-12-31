/******************* URBAN INSTITUTE MACRO LIBRARY *********************
 
 Macro: ListIntersect

 Description: Autocall macro returns the intersection of two lists.
 
 Use: Function
 
 Author: Peter Tatian
 
***********************************************************************/

%macro ListIntersect(
  list1,           /* List of items #1 */
  list2,           /* List of items #2 */
  delim=%str( )    /* Delimiter for list (def. blank char) */
  );
  
  /*************************** USAGE NOTES *****************************
   
   SAMPLE CALL: 
     %ListIntersect( A B C D, C D E F )
       returns C D, which is intersection of A B C D and C D E F

  *********************************************************************/

  /*************************** UPDATE NOTES ****************************

   02/23/11  PAT  Added declaration for local macro vars.

  *********************************************************************/

  %***** ***** ***** MACRO SET UP ***** ***** *****;
   
  %local ListIntersect scanlist1 scanlist2 i item;
  
   
  %***** ***** ***** ERROR CHECKS ***** ***** *****;



  %***** ***** ***** MACRO BODY ***** ***** *****;

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


  %***** ***** ***** CLEAN UP ***** ***** *****;

%mend ListIntersect;


/************************ UNCOMMENT TO TEST ***************************

options mprint nosymbolgen nomlogic;

** Autocall macros **;

filename uiautos "K:\Metro\PTatian\UISUG\Uiautos\";
options sasautos=(uiautos sasautos);

%let list1 = Z A B C X Y E Y Z F G X;
%let list2 = A B C D W X Y Z;
%let result = [%ListIntersect( &list1, &list2 )];
%put _user_;

%let list1 = A B C D E F G;
%let list2 = W X Y Z;
%let result = [%ListIntersect( &list1, &list2 )];
%put _user_;

/**********************************************************************/
