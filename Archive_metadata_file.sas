/******************* URBAN INSTITUTE MACRO LIBRARY *********************
 
 Macro: Archive_metadata_file

 Description: Archives metadata for a SAS data set.
 
 Use: Open code
 
 Author: Peter Tatian
 
***********************************************************************/

%macro Archive_metadata_file( 
         ds_lib=        /** Data set library reference **/,
         ds_lib_display=  /** Library name displayed in metadata system (opt.) **/,
         ds_name=       /** Data set name **/,
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
              ds_name=Shoes
           )
         archives the metadata for data set Dat.Shoes

  *********************************************************************/

  /*************************** UPDATE NOTES ****************************


  *********************************************************************/

  %***** ***** ***** MACRO SET UP ***** ***** *****;
   
  %local file_registered file_archived;
  
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

  %** Check that metadata files data set exists **;
  
  %if not %Dataset_exists( &meta_lib..&meta_pre._files, quiet=n ) %then %do;
    %Err_mput( macro=Archive_metadata_file, msg=File &meta_lib..&meta_pre._files does not exist. )
    %goto exit_err;
  %end;

  %** Check that the data set is registered and not already archived **;
  
  proc sql noprint;
    select count( FileName ), MetadataFileArchive into :file_registered, :file_archived from &meta_lib..&meta_pre._files
    where upcase( Library ) = upcase( "&ds_lib_display" ) and upcase( FileName ) = upcase( "&ds_name" );
  quit;

  %PUT FILE_REGISTERED=&FILE_REGISTERED FILE_ARCHIVED=&FILE_ARCHIVED;
  
  %if &file_registered = 0 %then %do;
    %Err_mput( macro=Archive_metadata_file, msg=Data set &ds_lib_display..&ds_name is not registered in the metadata system. )
    %goto exit;
  %end;
  
  %if &file_archived = 1 %then %do;
    %Err_mput( macro=Archive_metadata_file, msg=Data set &ds_lib_display..&ds_name is already archived. )
    %goto exit;
  %end;
  

  %***** ***** ***** MACRO BODY ***** ***** *****;
  
  

  %***** ***** ***** CLEAN UP ***** ***** *****;

  %Note_mput( macro=Archive_metadata_file, msg=Data set &ds_lib_display..&ds_name successfully archived. )
  
  %exit:

  %** Restore system options **;
  
  %Pop_option( obs )
  %Pop_option( mprint )
  
  %Note_mput( macro=Archive_metadata_file, msg=Macro Archive_metadata_file() exiting. )

%mend Archive_metadata_file;

