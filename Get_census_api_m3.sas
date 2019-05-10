/******************* URBAN INSTITUTE MACRO LIBRARY *********************
 
 Macro: Get_census_api

 Description: Read Census data through a JSON API service into a 
 SAS data set. Requires SAS 9.4M4 or later.
 
 Use: Open code
 
 Author: Peter Tatian
 
***********************************************************************/

%macro Get_census_api( 
  api=,      /** API path (quoted character string) **/
  out=       /** Output data set (optional) **/
);

  /*************************** USAGE NOTES *****************************
   
   SAMPLE CALL: 
     %Get_census_api( 
       api='https://api.census.gov/data/2017/acs/acs5?get=B01001_001E,NAME&for=tract:*&in=state:01&in=county:*',
       out=alabama_tracts
     )
       Reads Census API for ACS 5-year 2017 tract population for 
       Alabama and outputs to data set work.alabama_tracts.

  *********************************************************************/

  /*************************** UPDATE NOTES ****************************
  
  5/4/2019 Code adapted from https://acsdatacommunity.prb.org/acs-data-products--resources/api/f/15/t/388


  *********************************************************************/

  %***** ***** ***** MACRO SET UP ***** ***** *****;
   
  %note_mput( macro=Get_census_api, msg=Macro starting. )
  
    
  %***** ***** ***** ERROR CHECKS ***** ***** *****;

  %if %length( &api ) = 0 %then %do;
    %err_mput( macro=Get_census_api, msg=Must provide an API= value. )
    %goto exit;
  %end;


  %***** ***** ***** MACRO BODY ***** ***** *****;
  
  ** Specify the API URL for the data you want. ;
  filename _rapirsp url &api;
  filename _rapitmp temp ; ** temporary file, in which to save the census api text, after stripping the leading and closing bracket(s) on each row. ;
  
  ** strip the leading and trailing bracket(s) from each row that the api returns. that turns the file into a simple csv file. ;
  
  data _null_ ;
    length _nobrkts $ 5000. ; ** make sure that this length is long enough to capture the longest row produced by the api call. ;
    infile _rapirsp ; ** read the api output. ;
    input ; ** read in a row. ;
    PUT _INFILE_;
    /***_nobrkts = prxchange( "s/^\s*\[+|\]+\s*$//", -1, _infile_) ; ** strip the leading and trailing bracket(s) from the row. ;***/
        _nobrkts = prxchange( "s/^\s*\[+|\]+\,*\s*$//", -1, _infile_) ; ** strip the leading and trailing bracket(s) from the row. ;
    PUT _NOBRKTS /; 
    file _rapitmp ; ** direct the subsequent put to the temporary text file. ;
    put _nobrkts ; ** write the revised line to the temporary text file. ;
  run;
  
  proc import datafile=_rapitmp dbms=csv out=&out replace ; ** now just import the revised file as a .csv file. ;
   getnames=yes ; ** get the variable names from the 1st line of the file. ;
  run;
    
  
  %MACRO SKIP;
  filename _rapirsp temp;
  
  proc http
    url=&api
    method="GET"
    out=_rapirsp;
  run;
  
  /* puts the results from a responsefile into a table and 
     uses the first row from the response to create variable names */
  
  libname _rapitmp JSON fileref=_rapirsp;

  data _null_;
    set _rapitmp.root (obs=1);
    array elemCols{*} element:;
    length rename $4000;
    do i=1 to dim(elemCols);
      rename=catx(' ',rename, catx('=','element'||compress(put(i,3.)),elemCols{i}));
    end;
    call symputx('rename',rename);
  run;

  data &out;
    set _rapitmp.root (firstobs=2);
    rename &rename;
  run;
  %MEND SKIP;


  %***** ***** ***** CLEAN UP ***** ***** *****;

  /**libname _rapitmp clear;**/
  filename _rapitmp clear;
  filename _rapirsp clear;


  %exit:

  %note_mput( macro=Get_census_api, msg=Macro exiting. )  
  

%mend Get_census_api;


/************************ UNCOMMENT TO TEST ***************************

  ** Locations of SAS autocall macro libraries **;

  filename uiautos  "K:\Metro\PTatian\UISUG\Uiautos";
  options sasautos=(uiautos sasautos);
  
  options mprint nosymbolgen nomlogic;

  ** Check error handling **;
  %Get_census_api( )

  ** Check reading API: all 2017 5-year Alabama tract populations **;
  %Get_census_api( 
    api='https://api.census.gov/data/2017/acs/acs5?get=B01001_001E,NAME&for=tract:*&in=state:01&in=county:*',
    out=alabama_tracts
  )
  
  proc contents;
  
  proc print;
  
  run;
    
/**********************************************************************/
