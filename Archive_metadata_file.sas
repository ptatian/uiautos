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
              ds_name_list=Shoes
           )
         archives the metadata for data set Dat.Shoes

  *********************************************************************/

  /*************************** UPDATE NOTES ****************************


  *********************************************************************/

  %***** ***** ***** MACRO SET UP ***** ***** *****;
   
  %local file_registered file_archived ds_days_old_list ds_name final_ds_name_list i;
  
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
  
  %** Process ds_days_old= parameter, if provided **;
  
  %if %length( &ds_days_old ) > 0 %then %do;
  
    proc sql noprint;
      select upcase( FileName ) into :ds_days_old_list separated by ' ' from &meta_lib..&meta_pre._files
      where upcase( Library ) = "&ds_lib" and ( today() - datepart( FileUpdated ) ) >= &ds_days_old ;
    quit;
    
  %end;
  
  %if %length( &ds_name_list ) = 0 %then %let final_ds_name_list = &ds_days_old_list;
  %else %if %length( &ds_days_old_list ) > 0 %then %do;
    %let final_ds_name_list = %ListIntersect( &ds_name_list, &ds_days_old_list  );
  %end;
  %else %let final_ds_name_list = &ds_name_list;
  
  %put _local_;
  
    
  %***** ***** ***** ERROR CHECKS ***** ***** *****;
  
  %** Check for required parameters **;
  
  %if %length( &final_ds_name_list ) = 0 %then %do;
    %Err_mput( macro=Archive_metadata_file, msg=No data sets specified or selected based on parameters provided. )
    %goto exit_err;
  %end;

%let i = 1;
%let ds_name = %scan( &final_ds_name_list, &i, %str( ) );

%do %until ( &ds_name = );

  %** Check that metadata files data set exists **;
  
  %if not %Dataset_exists( &meta_lib..&meta_pre._files, quiet=n ) %then %do;
    %Err_mput( macro=Archive_metadata_file, msg=File &meta_lib..&meta_pre._files does not exist. )
    %goto exit_err;
  %end;

  %** Check that the data set is registered and not already archived **;
  
  proc sql noprint;
    select count( FileName ), MetadataFileArchive into :file_registered, :file_archived from &meta_lib..&meta_pre._files
    where upcase( Library ) = "&ds_lib" and upcase( FileName ) = "&ds_name";
  quit;

  %PUT FILE_REGISTERED=&FILE_REGISTERED FILE_ARCHIVED=&FILE_ARCHIVED;
  
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


  %MACRO SKIP;
  
  %***** ***** ***** MACRO BODY ***** ***** *****;
  
  ** Set MetadataFileArchive = 1 **;
  
  data &meta_lib..&meta_pre._files;
  
    set &meta_lib..&meta_pre._files;
  
    if upcase( Library ) = upcase( "&ds_lib" ) and upcase( FileName ) = upcase( "&ds_name" ) then MetadataFileArchive = 1;
    
  run;
  
  ** Copy HTML files to Archive subfolder **;
  
  x "md &html_folder\Archive";
  x "copy &html_folder.&html_pre._&ds_lib._&ds_name..&html_suf &html_folder\Archive";
  x "copy &html_folder.&html_pre._&ds_lib._&ds_name._v.&html_suf &html_folder\Archive";
  x "copy &html_folder.&html_pre._&ds_lib._&ds_name._h.&html_suf &html_folder\Archive";

  ** Delete records from metadata data sets **;
  
  data &meta_lib..&meta_pre._vars;
  
    set &meta_lib..&meta_pre._vars;
  
    where not( upcase( Library ) = upcase( "&ds_lib" ) and upcase( FileName ) = upcase( "&ds_name" ) );
    
  run;
  
  data &meta_lib..&meta_pre._fval;
  
    set &meta_lib..&meta_pre._fval;
  
    where not( upcase( Library ) = upcase( "&ds_lib" ) and upcase( FileName ) = upcase( "&ds_name" ) );
    
  run;
  
  %if %mparam_is_yes( &del_history ) %then %do;
  
    data &meta_lib..&meta_pre._history;
    
      set &meta_lib..&meta_pre._history;
    
      where not( upcase( Library ) = upcase( "&ds_lib" ) and upcase( FileName ) = upcase( "&ds_name" ) );
      
    run;
  
  %end;

  %Note_mput( macro=Archive_metadata_file, msg=Data set &ds_lib..&ds_name successfully archived. )
  
%MEND SKIP;

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

