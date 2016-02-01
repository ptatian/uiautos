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
  
  02-01-16 PAT Corrected error when list has more than 2 duplicates of
               same item.

  *********************************************************************/

  %***** ***** ***** MACRO SET UP ***** ***** *****;
   
  %local ListNoDup scanlist target i v;
    
    
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
  %let target = %scan( &scanlist, 2, &delim );

  %do %while ( %length( &target ) > 0 and &target ~= {{eol}} );
  
    %** Add item to unduplicated list **;
    %if %length( &ListNoDup ) = 0 %then
      %let ListNoDup = &target;
    %else
      %let ListNoDup = &ListNoDup&delim&target;
      
    %** Remove all other occurances of item **;

    %let i = 1;
    %let v = %scan( &scanlist, &i, &delim );
    %let newscanlist = ;

    %do %until ( &v = );

      %if &v ~= &target %then %do;
        %if %length( &newscanlist ) = 0 %then
          %let newscanlist = &v;
        %else 
          %let newscanlist = &newscanlist&delim&v;
      %end;

      %let i = %eval( &i + 1 );
      %let v = %scan( &scanlist, &i, &delim );

    %end;

    %let scanlist = &newscanlist;
    %let target = %scan( &scanlist, 2, &delim );

  %end;

  %let ListNoDup = %unquote( &ListNoDup );
  &ListNoDup

  %exit:


  %***** ***** ***** CLEAN UP ***** ***** *****;

%mend ListNoDup;


/************************ UNCOMMENT TO TEST ***************************

*options mprint symbolgen mlogic;

filename uiautos "K:\Metro\PTatian\UISUG\Uiautos";
options sasautos=(uiautos sasautos);

%** This test generates an error **;
%let list = A{B{C{D{E{B{F{A{C{G;
%let undup = [%ListNoDup( &list, delim={ )];
%put _user_;

%** This test generates an error **;
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

%let list = A B C AA AAA D E B AA F A AA C G AAAA;
%let undup = [%ListNoDup( &list )];
%put _user_;

%let list = 0001 0001 0002 0002 0002 0002 0002 0002 0002 0100;
%let undup = [%ListNoDup( &list )];
%put _user_;

/**********************************************************************/

