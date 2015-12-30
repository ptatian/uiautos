/******************* URBAN INSTITUTE MACRO LIBRARY *********************
 
 Macro: MCapitalize

 Description: Autocall macro returns macro text value with first letter 
 capitalized and the rest lowercase. 
 
 Use: Function
 
 Author: Peter Tatian
 
***********************************************************************/

%macro MCapitalize( s );

  /*************************** USAGE NOTES *****************************
   
   SAMPLE CALL: 
     %MCapitalize( aBcDE )
       Returns Abcde

  *********************************************************************/

  /*************************** UPDATE NOTES ****************************

  01/02/03  Peter A. Tatian

  *********************************************************************/

  %***** ***** ***** MACRO SET UP ***** ***** *****;
   
    
    
  %***** ***** ***** ERROR CHECKS ***** ***** *****;



  %***** ***** ***** MACRO BODY ***** ***** *****;
  
  %if %length( &s ) > 1 %then %do;
    %upcase( %substr( &s, 1, 1 ) )%lowcase( %substr( &s, 2 ) )
  %end;
  %else %do;
    %upcase( &s )
  %end;


  %***** ***** ***** CLEAN UP ***** ***** *****;

%mend MCapitalize;


/************************ UNCOMMENT TO TEST ***************************

title "MCapitalize:  SAS Macro";

** Autocall macros **;

filename uiautos "K:\Metro\PTatian\UISUG\Uiautos";
options sasautos=(uiautos sasautos);

**options mprint symbolgen mlogic;

%let str = ;
%let cstr = %MCapitalize( &str );
%put str=&str cstr=&cstr;

%let str = a;
%let cstr = %MCapitalize( &str );
%put str=&str cstr=&cstr;

%let str = Abcd Efgh;
%let cstr = %MCapitalize( &str );
%put str=&str cstr=&cstr;

%let str = abcd efgh;
%let cstr = %MCapitalize( &str );
%put str=&str cstr=&cstr;

%let str = ABCD EFGH;
%let cstr = %MCapitalize( &str );
%put str=&str cstr=&cstr;

%let str = aBcD eFgH;
%let cstr = %MCapitalize( &str );
%put str=&str cstr=&cstr;

/**********************************************************************/
