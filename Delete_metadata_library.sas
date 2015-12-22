/******************* URBAN INSTITUTE MACRO LIBRARY *********************
 
 Macro: Delete_metadata_library

 Description: Deletes a library from the metadata system.
 
 Use: Open code
 
 Author: Peter Tatian
 
***********************************************************************/

%macro Delete_metadata_library(  
         ds_lib= ,
         meta_lib= ,
         meta_pre= meta
  );
  
  /*************************** USAGE NOTES *****************************
   
   SAMPLE CALL: 
     %Delete_metadata_library( 
              ds_lib= Health,
              meta_lib= meta
       )

   NOTES:
   - This macro deletes the record for a library from the metadata system.
   - However, it does NOT delete the records for any files associated
     with that library. 
   - Use the %Delete_metadata_file() macro to remove any files
     associated with the library BEFORE using %Delete_metadata_library().

  *********************************************************************/

  /*************************** UPDATE NOTES ****************************

   12/20/04  Peter A. Tatian
   09/06/05  Set OPTIONS OBS=MAX to avoid data loss when updating metadata.

  *********************************************************************/

  %***** ***** ***** MACRO SET UP ***** ***** *****;
   
  %let ds_lib = %upcase( &ds_lib );

  %** Save current OBS= setting then set to MAX **;

  %Push_option( obs )
  
  options obs=max;
  %Note_mput( macro=Delete_metadata_library, msg=OPTIONS OBS set to MAX for metadata processing. )

    
  %***** ***** ***** ERROR CHECKS ***** ***** *****;

  ** Check for existence of library metadata file **;
  
  %if not %Dataset_exists( &meta_lib..&meta_pre._libs, quiet=n ) %then %do;
    %Err_mput( macro=Delete_metadata_library, msg=File &meta_lib..&meta_pre._libs does not exist. )
    %goto exit_err;
  %end;

  ** Check that library is registered **;
  
  %Data_to_format( 
    FmtName=$libchk, 
    inDS=&meta_lib..&meta_pre._libs, 
    value=upcase( Library ),
    label="Y",
    otherlabel="N",
    print=N )

  data _null_;
    call symput( 'lib_exists', put( upcase( "&ds_lib" ), $libchk. ) );
  run;
    
  %if &lib_exists = N %then %do;
    %Err_mput( macro=Delete_metadata_library, msg=Library &ds_lib is not registered in the metadata system. )
    %goto exit_err;
  %end;
  

  %***** ***** ***** MACRO BODY ***** ***** *****;
  
  ** Delete library from metadata **;
  
  data &meta_lib..&meta_pre._libs (compress=char);

    set &meta_lib..&meta_pre._libs;
    
    if library = "&ds_lib" then delete;
  
  run;

  %Note_mput( macro=Delete_metadata_library, msg=Library &ds_lib deleted from metadata system. )
  
  %goto exit;

  %exit_err:
  
  %** Put error handling here **;
  
  %goto exit;
  
  %exit:
  
  %***** ***** ***** CLEAN UP ***** ***** *****;

  %** Restore system options **;
  
  %Pop_option( obs )

  %Note_mput( macro=Delete_metadata_library, msg=Macro exiting. )

%mend Delete_metadata_library;

