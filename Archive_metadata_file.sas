/******************* URBAN INSTITUTE MACRO LIBRARY *********************
 
 Macro: Archive_metadata_file

 Description: Archives metadata for a SAS data set.
 
 Use: Open code
 
 Author: Peter Tatian
 
***********************************************************************/

%macro Archive_metadata_file( 
         ds_lib=        /** Data set library reference **/,
         ds_lib_display=  /** Library name displayed in metadata system (opt.) **/,
         ds_name_list=    /** List of data set names **/,
         ds_days_old=   /** Archive data sets that are at least X days old **/,
         del_history=n  /** Delete file history from metadata (opt.) **/,
         meta_lib=        /** Metadata library reference **/,
         meta_pre= meta   /** Metadata data set name prefix **/,
         html_folder=       /** Folder for HTML files **/,
         html_pre= meta     /** Filename prefix for HTML files **/,
         html_suf= html     /** Filename suffix for HTML files **/,
         mprint=N      /** Print resolved macro code to LOG **/
       );

  /*************************** USAGE NOTES *****************************
   
   SAMPLE CALL: 
     %Archive_metadata_file( 
              ds_lib=Dat,
              ds_name_list=Shoes,
              meta_lib=metadata,
              html_folder=C:\DCData\Libraries\Metadata\HTML
           )
         archives the metadata for data set Dat.Shoes

  *********************************************************************/

  /*************************** UPDATE NOTES ****************************


  *********************************************************************/

  %***** ***** ***** MACRO SET UP ***** ***** *****;
   
  %local lib_registered lib_archived  file_registered file_archived 
         ds_days_old_list ds_name final_ds_name_list ds_where_list i;
  
  %let ds_lib = %upcase( &ds_lib );
  %let ds_name_list = %upcase( &ds_name_list );
  
  %** If not specified, use ds_lib value as ds_lib_display **;
  
  %if &ds_lib_display = %then %let ds_lib_display = &ds_lib;
  
  %** Save current MPRINT setting and reset based on MPRINT= parameter **;
  
  %Push_option( mprint )
  
  %if %mparam_is_yes( &mprint ) %then %do;
    options mprint;
  %end;
  %else %do;
    options nomprint;
  %end;
  
  %** Force step boundary **;
  
  run;
  
  %** Save current OBS= setting then set to MAX **;

  %Push_option( obs )
  
  options obs=max;
  %Note_mput( macro=Archive_metadata_file, msg=OPTIONS OBS set to MAX for metadata processing. )
  
    
  %***** ***** ***** ERROR CHECKS ***** ***** *****;
  
  %** Check for required parameters **;
  
  %if %length( &meta_lib ) = 0 %then %do;
    %Err_mput( macro=Archive_metadata_file, msg=Library for metadata data sets not provided. )
    %goto exit_err;
  %end;

  %if %length( &html_folder ) = 0 %then %do;
    %Err_mput( macro=Archive_metadata_file, msg=Location of metadata HTML folder not provided. )
    %goto exit_err;
  %end;
  
  %** Check that metadata files data set exists **;
  
  %if not %Dataset_exists( &meta_lib..&meta_pre._files, quiet=n ) %then %do;
    %Err_mput( macro=Archive_metadata_file, msg=File &meta_lib..&meta_pre._files does not exist. )
    %goto exit_err;
  %end;
  
  %** Check that library is registered and not archived **;
  
  proc sql noprint;
    select count( Library ), MetadataLibArchive into :lib_registered, :lib_archived from &meta_lib..&meta_pre._libs
    where upcase( Library ) = "&ds_lib";
  quit;

  %if &lib_registered = 0 %then %do;
    %Err_mput( macro=Archive_metadata_lib, msg=Library &ds_lib is not registered in the metadata system. )
    %goto exit_err;
  %end;
  
  %if &lib_archived = 1 %then %do;
    %Err_mput( macro=Archive_metadata_lib, msg=Library &ds_lib is already archived. )
    %goto exit_err;
  %end;

  %** Process ds_days_old= parameter, if provided **;
  
  %if %length( &ds_days_old ) > 0 %then %do;
  
    proc sql noprint;
      select upcase( FileName ) into :ds_days_old_list separated by ' ' from &meta_lib..&meta_pre._files
      where upcase( Library ) = "&ds_lib" and ( today() - datepart( FileUpdated ) ) >= &ds_days_old and MetadataFileArchive = 0;
    quit;
    
  %end;
  
  %if %length( &ds_name_list ) = 0 %then %let final_ds_name_list = &ds_days_old_list;
  %else %if %length( &ds_days_old_list ) > 0 %then %do;
    %let final_ds_name_list = %ListIntersect( &ds_name_list, &ds_days_old_list  );
  %end;
  %else %let final_ds_name_list = &ds_name_list;
    
  %if %length( &final_ds_name_list ) = 0 %then %do;
    %Err_mput( macro=Archive_metadata_file, msg=No data sets specified or selected based on parameters provided. )
    %goto exit_err;
  %end;

  %** Perform checks on each data set **;

  %let i = 1;
  %let ds_name = %scan( &final_ds_name_list, &i, %str( ) );

  %do %until ( &ds_name = );

    %** Check that the data set is registered and not already archived **;
    
    proc sql noprint;
      select count( FileName ), MetadataFileArchive into :file_registered, :file_archived from &meta_lib..&meta_pre._files
      where upcase( Library ) = "&ds_lib" and upcase( FileName ) = "&ds_name";
    quit;

    %if &file_registered = 0 %then %do;
      %Err_mput( macro=Archive_metadata_file, msg=Data set &ds_lib..&ds_name is not registered in the metadata system. )
      %goto exit_err;
    %end;
    
    %if &file_archived = 1 %then %do;
      %Err_mput( macro=Archive_metadata_file, msg=Data set &ds_lib..&ds_name is already archived. )
      %goto exit_err;
    %end;
    
    %let i = %eval( &i + 1 );
    %let ds_name = %scan( &final_ds_name_list, &i, %str( ) );

  %end;


  %***** ***** ***** MACRO BODY ***** ***** *****;
  
  %** Remove trailing \ from html_folder **;
  
  %if %substr( %sysfunc( reverse( &html_folder ) ), 1, 1 ) = \ %then 
    %let html_folder = %substr( &html_folder, 1, %length( &html_folder ) - 1 );

  %** Create list of data sets for if/where processing **;
  
  %let i = 1;
  %let ds_name = %scan( &final_ds_name_list, &i, %str( ) );
  
  %let ds_where_list = ;

  %do %until ( &ds_name = );

    %if %length( &ds_where_list ) > 0 %then 
      %let ds_where_list = &ds_where_list, %sysfunc( quote(&ds_name) ); 
    %else 
      %let ds_where_list = %sysfunc( quote(&ds_name) );

    %let i = %eval( &i + 1 );
    %let ds_name = %scan( &final_ds_name_list, &i, %str( ) );

  %end;
  
  ** Set MetadataFileArchive = 1 **;
  
  data &meta_lib..&meta_pre._files;
  
    set &meta_lib..&meta_pre._files;
  
    if upcase( Library ) = "&ds_lib" and upcase( FileName ) in ( &ds_where_list ) then MetadataFileArchive = 1;
    
  run;
  
  ** Copy HTML files to Archive subfolder **;
  
  x "md &html_folder\Archive";

  %let i = 1;
  %let ds_name = %scan( &final_ds_name_list, &i, %str( ) );

  %do %until ( &ds_name = );

    x "copy &html_folder\&html_pre._&ds_lib._&ds_name..&html_suf &html_folder\Archive";
    x "copy &html_folder\&html_pre._&ds_lib._&ds_name._v.&html_suf &html_folder\Archive";
    x "copy &html_folder\&html_pre._&ds_lib._&ds_name._h.&html_suf &html_folder\Archive";

    %let i = %eval( &i + 1 );
    %let ds_name = %scan( &final_ds_name_list, &i, %str( ) );

  %end;

  ** Delete records from metadata data sets **;
  
  data &meta_lib..&meta_pre._vars;
  
    set &meta_lib..&meta_pre._vars;
  
    where not( upcase( Library ) = "&ds_lib" and upcase( FileName ) in ( &ds_where_list ) );
    
  run;
  
  data &meta_lib..&meta_pre._fval;
  
    set &meta_lib..&meta_pre._fval;
  
    where not( upcase( Library ) = "&ds_lib" and upcase( FileName ) in ( &ds_where_list ) );
    
  run;
  
  %if %mparam_is_yes( &del_history ) %then %do;
  
    data &meta_lib..&meta_pre._history;
    
      set &meta_lib..&meta_pre._history;
    
      where not( upcase( Library ) = "&ds_lib" and upcase( FileName ) in ( &ds_where_list ) );
      
    run;
  
  %end;

  %Note_mput( macro=Archive_metadata_file, msg=Data sets &final_ds_name_list in &ds_lib successfully archived. )


  %***** ***** ***** CLEAN UP ***** ***** *****;

  %goto exit;
  
  %exit_err:
  
  %Err_mput( macro=Archive_metadata_file, msg=No data set metadata were archived. )
  
  %exit:

  %** Restore system options **;
  
  %Pop_option( obs )
  %Pop_option( mprint )
  
  %Note_mput( macro=Archive_metadata_file, msg=Macro Archive_metadata_file() exiting. )

%mend Archive_metadata_file;

