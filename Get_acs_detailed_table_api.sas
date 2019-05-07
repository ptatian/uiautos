/******************* URBAN INSTITUTE MACRO LIBRARY *********************
 
 Macro: Get_acs_detailed_table_api

 Description: Read Census ACS data for detailed summary table through 
 JSON API service into a SAS data set. Variables are labeled and 
 reformatted at numeric. Requires SAS 9.4M4 or later.
 
 Use: Open code
 
 Author: Peter Tatian
 
***********************************************************************/

%macro Get_acs_detailed_table_api( 
  table=, 
  year=, 
  sample=, 
  for=, 
  in=, 
  key=
);

  /*************************** USAGE NOTES *****************************
   
   SAMPLE CALL: 
    %Get_acs_detailed_table_api( 
      table=B01001, 
      year=2017, 
      sample=acs1, 
      for=county:*, 
      in=%nrstr(state:24)
    )

       Reads summary table B01001, 2017 1-year data, all counties in MD,
       to SAS data set work.B01001.

  *********************************************************************/

  /*************************** UPDATE NOTES ****************************
  

  *********************************************************************/


  %***** ***** ***** MACRO SET UP ***** ***** *****;
   
  %note_mput( macro=Get_acs_detailed_table_api, msg=Macro starting. )
  
  %local 
    for_keyword geo_vars tablefiles i j n orig_vars vars_sub file_list api_url
    orig_estimate orig_moe estimate_labels moe_labels estimate_convert moe_convert;

  %let table = %upcase( &table );
  %let for = %lowcase( &for );

  %let for_keyword = %scan( &for, 1, : );

    
  %***** ***** ***** ERROR CHECKS ***** ***** *****;

  %if %length( &table ) = 0 %then %do;
    %err_mput( macro=Get_acs_detailed_table_api, msg=Must provide an TABLE= value. )
    %goto exit;
  %end;


  %***** ***** ***** MACRO BODY ***** ***** *****;
  
  %if &for_keyword = tract %then %let geo_vars = state county tract;
  %else %if &for_keyword = county %then %let geo_vars = state county;

  filename in url "https://api.census.gov/data/&year./acs/&sample./variables.json" debug;
  /*filename map 'snap.map';*/
  libname in json /*map=map automap=replace*/;

  /*%File_info( data=IN.VARIABLES_B01001_001E )*/

  proc sql noprint;
    /***describe table dictionary.tables;***/
    select 'IN.' || left( memname ) into :tablefiles separated by ' ' from dictionary.tables
    /***select substr( memname, length( 'VARIABLES_' ) + 1 ) into :vars separated by ',' from dictionary.tables***/
    /***select libname, memname from dictionary.tables***/
    where libname='IN' and memname like "VARIABLES\_&table.\_%" escape '\'
    order by memname;
  quit;

  data tableinfo;

    length label estimate_label moe_label $ 250;
    length rootvar table orig_estimate orig_moe estimate moe $ 40;

    set &tablefiles;
    
    rootvar = left( scan( attributes, 1, ',' ) );
    
    do until ( indexc( substr( left( reverse( rootvar ) ), 1, 1 ), '0123456789' ) or rootvar = '' );
      rootvar = substr( rootvar, 1, length( rootvar ) - 1 );
    end;
    
    orig_estimate = trim( rootvar ) || 'E';
    orig_moe = trim( rootvar ) || 'M';;
    
    table = left( scan( rootvar, 1, '_' ) );
    cellnum = input( left( scan( rootvar, 2, '_' ) ), 12. );
    
    estimate = trim( table ) || 'e' || left( put( cellnum, 12. ) );
    moe = trim( table ) || 'm' || left( put( cellnum, 12. ) );
    
    i = index( label, '!!' );
    
    estimate_label = tranwrd( substr( label, i + 2 ), '!!', ': ' );
    moe_label = trim( estimate_label ) || " (margin of error)";
    
    keep orig_estimate orig_moe estimate moe estimate_label moe_label label table cellnum;
    
  run;

  PROC PRINT;

  /**proc contents data=in._all_; run;***/

  proc sql noprint;
    select orig_estimate into :orig_estimate separated by ' ' from tableinfo;
    select orig_moe into :orig_moe separated by ' ' from tableinfo;
    select trim(estimate)||'="'||trim(estimate_label)||'"' into :estimate_labels separated by '0d0a'x from tableinfo;
    select trim(moe)||'="'||trim(moe_label)||'"' into :moe_labels separated by '0d0a'x from tableinfo;
    select trim(estimate)||'=input('||trim(orig_estimate)||',best32.);' into :estimate_convert separated by '0d0a'x from tableinfo;
    select trim(moe)||'=input('||trim(orig_moe)||',best32.);' into :moe_convert separated by '0d0a'x from tableinfo;
  quit;

  %let orig_vars = &orig_estimate &orig_moe;

  %PUT ORIG_VARS=&ORIG_VARS;
  %PUT ESTIMATE_LABELS=&ESTIMATE_LABELS;
  %PUT MOE_LABELS=&MOE_LABELS;

  ***ENDSAS;

  **options mprint symbolgen mlogic;


  %let file_list = ;
  %let i = 1;
  %let n = 1;

  %do %while ( %length( %scan( &orig_vars, &i, ' ' ) ) > 0 );

    %let vars_sub = ;
    %let j = 1;

    %do %while ( &j <= 50 and %length( %scan( &orig_vars, &i, ' ' ) ) > 0 );

      %if &vars_sub = %then 
        %let vars_sub = %scan( &orig_vars, &i, ' ' );
      %else
        %let vars_sub = &vars_sub,%scan( &orig_vars, &i, ' ' );
      
      %let i = %eval( &i + 1 );
      %let j = %eval( &j + 1 );
      
    %end;
    
    %** Build API URL **;
    
    %let api_url = https://api.census.gov/data/&year./acs/&sample.?get=&vars_sub.%nrstr(&for)=&for.%nrstr(&in)=&in.;
    
    %if %length( &key ) > 0 %then
      %let api_url = &api_url.%nrstr(&key)=&key;

    %PUT API_URL=&API_URL;

    %Get_census_api(
      out=&table._&n,
      /**api="https://api.census.gov/data/2017/acs/acs5?get=B01001_001E&for=tract:*&in=state:01&in=county:*&key=32fb30e46892b2858b58fb5531cb53bf51c90cdf"**/
      /**api="https://api.census.gov/data/2017/acs/acs5?get=&vars_sub&for=tract:*&in=state:11&in=county:*&key=32fb30e46892b2858b58fb5531cb53bf51c90cdf"**/
      api="&api_url"
      
    )
    
    %let file_list = &file_list &table._&n;
    
    proc sort data=&table._&n (drop=ordinal_root);
      by &geo_vars.;
    run;
    
    %File_info( data=&table._&n, stats= )

    %let n = %eval( &n + 1 );

  %end;

  ** Combine all variables into single data set **;

  data &table; 

    merge &file_list;
    by &geo_vars.;
    
    &estimate_convert
    &moe_convert
    
    label 
      &estimate_labels
      &moe_labels
    ;
    
    drop &orig_vars;

  run;


  %***** ***** ***** CLEAN UP ***** ***** *****;


  %exit:

  %note_mput( macro=Get_acs_detailed_table_api, msg=Macro exiting. )  
  

%mend Get_acs_detailed_table_api;


/************************ UNCOMMENT TO TEST ***************************/

  ** Locations of SAS autocall macro libraries **;

  filename uiautos  "K:\Metro\PTatian\UISUG\Uiautos";
  options sasautos=(uiautos sasautos);
  
  %include "D:\Projects\UISUG\Uiautos\Get_census_api.sas";
  
  options mprint nosymbolgen nomlogic;

  ** Check error handling **;
  %Get_acs_detailed_table_api( )

  ** Check reading API: Summary table B01001, 2017 1-year data, all counties in MD **;
  %Get_acs_detailed_table_api( table=B01001, year=2017, sample=acs1, for=county:*, in=state:24, key=32fb30e46892b2858b58fb5531cb53bf51c90cdf )

  %File_info( data=B01001, printobs=0 )

  ** Check reading API: Summary table B01001, 2017 5-year data, all tracts in DC **;
  %Get_acs_detailed_table_api( table=B01001, year=2017, sample=acs5, for=tract:*, in=%nrstr(state:11&in=county:*), key=32fb30e46892b2858b58fb5531cb53bf51c90cdf )

  %File_info( data=B01001, printobs=0 )

  run;
    
/**********************************************************************/
