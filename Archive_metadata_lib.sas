/******************* URBAN INSTITUTE MACRO LIBRARY *********************
 
 Macro: Archive_metadata_lib

 Description: Archives metadata for a SAS library.
 
 Use: Open code
 
 Author: Peter Tatian
 
***********************************************************************/

%macro Archive_metadata_lib( 
         ds_lib=        /** Data set library reference **/,
         ds_lib_display=  /** Library name displayed in metadata system (opt.) **/,
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
     %Archive_metadata_lib( 
              ds_lib=Dat,
              meta_lib=metadata,
              html_folder=C:\DCData\Libraries\Metadata\HTML
           )
         archives the metadata for library Dat

  *********************************************************************/

  /*************************** UPDATE NOTES ****************************


  *********************************************************************/

  %***** ***** ***** MACRO SET UP ***** ***** *****;
   
  %local lib_registered lib_archived final_ds_name_list i ds_name;
  
  %let ds_lib = %upcase( &ds_lib );
  
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
  %Note_mput( macro=Archive_metadata_lib, msg=OPTIONS OBS set to MAX for metadata processing. )
      
    
  %***** ***** ***** ERROR CHECKS ***** ***** *****;
  
  %** Check for required parameters **;
  
  %if %length( &meta_lib ) = 0 %then %do;
    %Err_mput( macro=Archive_metadata_lib, msg=Library for metadata data sets not provided. )
    %goto exit_err;
  %end;

  %if %length( &html_folder ) = 0 %then %do;
    %Err_mput( macro=Archive_metadata_lib, msg=Location of metadata HTML folder not provided. )
    %goto exit_err;
  %end;
  
  %** Check that metadata library data set exists **;
  
  %if not %Dataset_exists( &meta_lib..&meta_pre._libs, quiet=n ) %then %do;
    %Err_mput( macro=Archive_metadata_lib, msg=File &meta_lib..&meta_pre._libs does not exist. )
    %goto exit_err;
  %end;
  
  %** Check that library is registered and not archived **;
  
  proc sql noprint;
    select count( Library ), MetadataLibArchive into :lib_registered, :lib_archived from &meta_lib..&meta_pre._libs
    where upcase( Library ) = "&ds_lib";
  quit;

  %PUT LIB_REGISTERED=&LIB_REGISTERED LIB_ARCHIVED=&LIB_ARCHIVED;
  
  %if &lib_registered = 0 %then %do;
    %Err_mput( macro=Archive_metadata_lib, msg=Library &ds_lib is not registered in the metadata system. )
    %goto exit_err;
  %end;
  
  %if &lib_archived = 1 %then %do;
    %Err_mput( macro=Archive_metadata_lib, msg=Library &ds_lib is already archived. )
    %goto exit_err;
  %end;


  %***** ***** ***** MACRO BODY ***** ***** *****;
  
  %** Remove trailing \ from html_folder **;
  
  %if %substr( %sysfunc( reverse( &html_folder ) ), 1, 1 ) = \ %then 
    %let html_folder = %substr( &html_folder, 1, %length( &html_folder ) - 1 );
    
  ** Generate list of unarchived data sets **;
  
  proc sql noprint;
    select upcase( FileName ) into :final_ds_name_list separated by ' ' from &meta_lib..&meta_pre._files
    where upcase( Library ) = "&ds_lib" and MetadataFileArchive = 0;
  quit;
  
  ** Set MetadataLibArchive = 1 **;
  
  data &meta_lib..&meta_pre._libs;
  
    set &meta_lib..&meta_pre._libs;
  
    if upcase( Library ) = "&ds_lib" then MetadataLibArchive = 1;
    
  run;
  
  ** Set MetadataFileArchive = 1 **;

  data &meta_lib..&meta_pre._files;
  
    set &meta_lib..&meta_pre._files;
  
    if upcase( Library ) = "&ds_lib" then MetadataFileArchive = 1;
    
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
  
    where not( upcase( Library ) = "&ds_lib" );
    
  run;
  
  data &meta_lib..&meta_pre._fval;
  
    set &meta_lib..&meta_pre._fval;
  
    where not( upcase( Library ) = "&ds_lib" );
    
  run;
  
  %if %mparam_is_yes( &del_history ) %then %do;
  
    data &meta_lib..&meta_pre._history;
    
      set &meta_lib..&meta_pre._history;
    
      where not( upcase( Library ) = "&ds_lib" );
      
    run;
  
  %end;
  
  %Note_mput( macro=Archive_metadata_lib, msg=Library &ds_lib successfully archived. )


  %***** ***** ***** CLEAN UP ***** ***** *****;

  %goto exit;
  
  %exit_err:
  
  %Err_mput( macro=Archive_metadata_lib, msg=No library was archived. )
  
  %exit:

  %** Restore system options **;
  
  %Pop_option( obs )
  %Pop_option( mprint )
  
  %Note_mput( macro=Archive_metadata_lib, msg=Macro Archive_metadata_lib() exiting. )

%mend Archive_metadata_lib;

