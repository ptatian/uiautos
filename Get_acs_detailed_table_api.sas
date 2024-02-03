/******************* URBAN INSTITUTE MACRO LIBRARY *********************
 
 Macro: Get_acs_detailed_table_api

 Description: Read Census ACS data for detailed summary table through 
 JSON API service into a SAS data set. Variables are labeled and 
 reformatted at numeric. Requires SAS 9.4M4 or later.
 
 Use: Open code
 
 Author: Peter Tatian
 
***********************************************************************/

%macro Get_acs_detailed_table_api( 
  table=,      /** ACS detailed summary table ID **/
  year=,       /** 4-digit ACS data year (last year for 5-year data) **/
  sample=,     /** ACS1 (1-year) or ACS5 (5-year) data samples **/
  for=,        /** Geographic level specification (eg, tract:*) **/
  in=,         /** Selection criteria (eg, state:24) **/
  add_vars=,   /** Additional variables to include in data set (optional) **/
  out=,        /** Output data set (optional, default is table ID) **/
  key=,         /** Census API key (optional) **/
  old_var_names=n  /** Use old style variable names eg: B01001e1, B01001m1 (Yes/No) **/
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
  
  01/18/24 PAT Added support for more geographies. 
  01/20/24 PAT Added error checking for nonexistent table.
  02/03/24 PAT Added old_var_names= option and support for new var names.

  *********************************************************************/


  %***** ***** ***** MACRO SET UP ***** ***** *****;
   
  %note_mput( macro=Get_acs_detailed_table_api, msg=Macro starting. )
  
  %local 
    for_keyword geo_vars tablefiles i j n full_vars orig_vars vars_sub 
    file_list api_url out_label
    orig_estimate orig_moe estimate_labels moe_labels 
    estimate_convert moe_convert estimate_rename moe_rename;

  %let table = %upcase( &table );
  %let for = %lowcase( &for );
  %let add_vars = %upcase( &add_vars );

  %let for_keyword = %scan( &for, 1, : );
  
  %if %length( &out ) = 0 %then %let out = &table;

    
  %***** ***** ***** ERROR CHECKS ***** ***** *****;

  %if %length( &table ) = 0 %then %do;
    %err_mput( macro=Get_acs_detailed_table_api, msg=Must provide a TABLE= value (summary table ID). )
    %goto exit;
  %end;


  %***** ***** ***** MACRO BODY ***** ***** *****;
  
  %if &for_keyword = tract %then %let geo_vars = state county tract;
  %else %if &for_keyword = county %then %let geo_vars = state county;
  %else %if &for_keyword = place %then %let geo_vars = state place;
  %else %if &for_keyword = state %then %let geo_vars = state;
  %else %if &for_keyword = block%20group %then %let geo_vars = state county tract blockgroup;
  %else %do;
    %err_mput( macro=Get_acs_detailed_table_api, msg=Summary level &for_keyword not currently supported by this macro. )
    %goto exit;
  %end;

  filename in url "https://api.census.gov/data/&year./acs/&sample./variables.json" debug;
  libname in json /*map=map automap=replace*/;

  /*%File_info( data=IN.VARIABLES_B01001_001E )*/

  proc sql noprint;
    select 'IN.' || left( memname ) into :tablefiles separated by ' ' from dictionary.tables
    where libname='IN' and memname like "VARIABLES\_&table.\_%" escape '\';
  quit;
  
  %** Check whether table was in variable list **;
  
  %if %length( &tablefiles ) = 0 %then %do;
    %err_mput( macro=Get_acs_detailed_table_api, msg=%str(Table &table is not available for year=&year, sample=&sample..) )
    %goto exit;
  %end;
  
  %if %mparam_is_yes( &old_var_names ) %then %do;
  
    ** Process using old variable names **;
    
    data _tableinfo;

      length label estimate_label moe_label $ 250;
      length rootvar table orig_estimate orig_moe estimate moe $ 40;

      set &tablefiles;
      
      rootvar = left( scan( attributes, 1, ',' ) );
      
      do until ( indexc( substr( left( reverse( rootvar ) ), 1, 1 ), '0123456789' ) or rootvar = '' );
        rootvar = substr( rootvar, 1, length( rootvar ) - 1 );
      end;
      
      orig_estimate = trim( rootvar ) || 'E';
      
      table = left( scan( rootvar, 1, '_' ) );
      cellnum = input( left( scan( rootvar, 2, '_' ) ), 12. );
      
      estimate = trim( table ) || 'e' || left( put( cellnum, 12. ) );
      
      estimate_label = tranwrd( substr( label, index( label, '!!' ) + 2 ), '!!', ': ' );
      
      ** Check that variable has MOE **;
      
      orig_moe = trim( rootvar ) || 'M';;

      if findw( upcase( attributes ), trim( upcase( orig_moe ) ), ',' ) then do;
      
          moe = trim( table ) || 'm' || left( put( cellnum, 12. ) );

          moe_label = trim( estimate_label ) || " (margin of error)";
          
      end;
      else do;
      
        orig_moe = "";
        
      end;
      
      keep orig_estimate orig_moe estimate moe estimate_label moe_label label;
      
    run;
    
  %end;
  %else %do; 
  
    ** Process using new variable names **;
    
    data _tableinfo;

      length label estimate_label moe_label $ 250;
      length rootvar orig_estimate orig_moe estimate moe $ 40;

      set &tablefiles;
      
      rootvar = left( scan( attributes, 1, ',' ) );
      
      do until ( indexc( substr( left( reverse( rootvar ) ), 1, 1 ), '0123456789' ) or rootvar = '' );
        rootvar = substr( rootvar, 1, length( rootvar ) - 1 );
      end;
      
      orig_estimate = trim( rootvar ) || 'E';
      
      estimate = '_' || trim( rootvar ) || 'E';
      
      estimate_label = tranwrd( substr( label, index( label, '!!' ) + 2 ), '!!', ': ' );
      
      ** Check that variable has MOE **;
      
      orig_moe = trim( rootvar ) || 'M';

      if findw( upcase( attributes ), trim( upcase( orig_moe ) ), ',' ) then do;
      
          moe = '_' || trim( rootvar ) || 'M';

          moe_label = trim( estimate_label ) || " (margin of error)";
          
      end;
      else do;
      
        orig_moe = "";
        
      end;
      
      keep orig_estimate orig_moe estimate moe estimate_label moe_label label;
      
    run;
    
    ** Generate renaming lists **;

    proc sql noprint;
      select trim(estimate)||'='||trim(orig_estimate) into :estimate_rename separated by '0d0a'x from _tableinfo;
      select trim(moe)||'='||trim(orig_moe) into :moe_rename separated by '0d0a'x from _tableinfo where orig_moe ~= "";
    quit;
    
  %end;
  
  ** Generate macro variables with lists needed for processing **;

  proc sql noprint;
    select orig_estimate into :orig_estimate separated by ' ' from _tableinfo;
    select orig_moe into :orig_moe separated by ' ' from _tableinfo where orig_moe ~= "";
    select trim(estimate)||'="'||trim(estimate_label)||'"' into :estimate_labels separated by '0d0a'x from _tableinfo;
    select trim(moe)||'="'||trim(moe_label)||'"' into :moe_labels separated by '0d0a'x from _tableinfo where orig_moe ~= "";
    select trim(estimate)||'=input('||trim(orig_estimate)||',best32.);' into :estimate_convert separated by '0d0a'x from _tableinfo;
    select trim(moe)||'=input('||trim(orig_moe)||',best32.);' into :moe_convert separated by '0d0a'x from _tableinfo where orig_moe ~= "";
  quit;

  %let orig_vars = &orig_estimate &orig_moe;
  %let full_vars = &add_vars &orig_vars;

  ** Process API calls. Only can request 50 variables at a time **;

  %let file_list = ;
  %let i = 1;
  %let n = 1;

  %do %while ( %length( %scan( &full_vars, &i, ' ' ) ) > 0 );

    %let vars_sub = ;
    %let j = 1;

    %do %while ( &j <= 50 and %length( %scan( &full_vars, &i, ' ' ) ) > 0 );

      %if &vars_sub = %then 
        %let vars_sub = %scan( &full_vars, &i, ' ' );
      %else
        %let vars_sub = &vars_sub,%scan( &full_vars, &i, ' ' );
      
      %let i = %eval( &i + 1 );
      %let j = %eval( &j + 1 );
      
    %end;
    
    %** Build API URL **;
    
    %if %length( &in ) > 0 %then
      %let api_url = https://api.census.gov/data/&year./acs/&sample.?get=&vars_sub.%nrstr(&for)=&for.%nrstr(&in)=&in.;
    %else
      %let api_url = https://api.census.gov/data/&year./acs/&sample.?get=&vars_sub.%nrstr(&for)=&for.;
    
    %if %length( &key ) > 0 %then
      %let api_url = &api_url.%nrstr(&key)=&key;

    %put api_url=&api_url;

    %Get_census_api(
      out=_&table._&n,
      api="&api_url"
    )
    
    %let file_list = &file_list _&table._&n;
    
    proc sort data=_&table._&n (drop=ordinal_root);
      by &geo_vars.;
    run;
    
    /***%File_info( data=_&table._&n, stats= )***/

    %let n = %eval( &n + 1 );

  %end;

  ** Combine all variables into single data set **;
  
  %if &sample = acs1 %then %let out_label = "&table, ACS 1-year, &year, &for_keyword (in=&in)";
  %else %if &sample = acs5 %then %let out_label = "&table, ACS 5-year, &year, &for_keyword (in=&in)";

  data &out (label=&out_label); 

    merge &file_list;
    by &geo_vars.;
    
    &estimate_convert
    &moe_convert
    
    label 
      &estimate_labels
      &moe_labels
    ;
    
    %if %mparam_is_yes( &old_var_names ) = 0 %then %do;
      rename &estimate_rename &moe_rename;
    %end;

    drop &orig_vars;

  run;


  %***** ***** ***** CLEAN UP ***** ***** *****;

  ** Clean up temporary data sets **;
  
  proc datasets library=work /*nolist nowarn*/;
    delete _tableinfo _&table._: /memtype=data;
  quit;

  %exit:

  %note_mput( macro=Get_acs_detailed_table_api, msg=Macro exiting. )  

%mend Get_acs_detailed_table_api;


/************************ UNCOMMENT TO TEST ***************************

  ** Locations of SAS autocall macro libraries **;

  filename uiautos  "K:\Metro\PTatian\UISUG\Uiautos";
  options sasautos=(uiautos sasautos);
  
  options nocenter;
  options mprint nosymbolgen nomlogic;

  title "** Check error handling **";
  %Get_acs_detailed_table_api( )
  %Get_acs_detailed_table_api( table=B01001, out=B01001_county, year=2017, sample=acs1, for=notageo:*, in=state:24, add_vars=name )
  %Get_acs_detailed_table_api( table=C25074, out=C25074_county_5yr, year=2022, sample=acs5, for=county:*, in=state:24, add_vars=name )

  title "** Check reading API: Summary table B01001, 2022 1-year data, all states **";
  %Get_acs_detailed_table_api( table=B01001, out=B01001_state, year=2022, sample=acs1, for=state:*, in=, add_vars=name )
  %File_info( data=B01001_state, printobs=20, printchar=y )

  title "** Check reading API: Summary table B01001, 2022 1-year data, all states, OLD VARIABLE NAMES **";
  %Get_acs_detailed_table_api( table=B01001, out=B01001_state_old_names, year=2022, sample=acs1, for=state:*, in=, add_vars=name, old_var_names=y )
  %File_info( data=B01001_state_old_names, printobs=20, printchar=y )

  title "** Check reading API: Summary table B01001, 2022 5-year data, all places in MD **";
  %Get_acs_detailed_table_api( table=B01001, out=B01001_place, year=2022, sample=acs5, for=place:*, in=state:24, add_vars=name )
  %File_info( data=B01001_place, printobs=20, printchar=y )

  title "** Check reading API: Summary table B01001, 2022 5-year data, all counties in MD **";
  %Get_acs_detailed_table_api( table=B01001, out=B01001_county_5yr, year=2022, sample=acs5, for=county:*, in=state:24, add_vars=name )
  %File_info( data=B01001_county_5yr, printobs=20, printchar=y )

  title "** Check reading API: Summary table B01001, 2022 1-year data, all counties in MD **";
  %Get_acs_detailed_table_api( table=B01001, out=B01001_county_1yr, year=2022, sample=acs1, for=county:*, in=state:24, add_vars=name )
  %File_info( data=B01001_county_1yr, printobs=20, printchar=y )

  title "** Check reading API: Summary table B01001, 2017 5-year data, all tracts in DC **";
  %Get_acs_detailed_table_api( table=B01001, out=B01001_tract, year=2017, sample=acs5, for=tract:*, in=%nrstr(state:11&in=county:*) )
  %File_info( data=B01001_tract, printobs=20, printchar=y )

  title "** Check reading API: Summary table B01001, 2017 5-year data, all block groups in DC **";
  %Get_acs_detailed_table_api( table=B01001, out=B01001_block_group, year=2017, sample=acs5, for=block%20group:*, in=state:11%20in=county:* )
  %File_info( data=B01001_block_group, printobs=20, printchar=y )

  title "** Check reading API: Summary table B98001 (table with no MOEs), 2022 5-year data, all counties in MD **";
  %Get_acs_detailed_table_api( table=B98001, out=B98001_county_5yr, year=2022, sample=acs5, for=county:*, in=state:24, add_vars=name )
  %File_info( data=B98001_county_5yr, printobs=20 )

  run;
  
  title;
    
/**********************************************************************/
