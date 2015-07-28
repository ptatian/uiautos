/* Delete_metadata_library.sas - SAS Autocall Macro Library
 *
 * Deletes metadata for a library.
 *
 * NB:  Program written for SAS Version 8.2
 *
 * 12/20/04  Peter A. Tatian
 * 09/06/05  Set OPTIONS OBS=MAX to avoid data loss when updating metadata.
 ****************************************************************************/

/** Macro Delete_metadata_library - Start Definition **/

%macro Delete_metadata_library(  
         ds_lib= ,
         meta_lib= ,
         meta_pre= meta
  );
  
  %let ds_lib = %upcase( &ds_lib );

  %** Save current OBS= setting then set to MAX **;

  %Push_option( obs )
  
  options obs=max;
  %Note_mput( macro=Delete_metadata_library, msg=OPTIONS OBS set to MAX for metadata processing. )

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
  
  %** Restore system options **;
  
  %Pop_option( obs )

  %Note_mput( macro=Delete_metadata_library, msg=Macro exiting. )

%mend Delete_metadata_library;

/** End Macro Definition **/


/******************** UNCOMMENT TO TEST MACRO ********************

libname general v8 "D:\Projects\DCNIS\Data\General";
libname health v8 "D:\Projects\DCNIS\Data\Health";
libname ipums v8 "D:\DCData\Libraries\IPUMS\Data";
libname meta v8 "D:\Projects\UISUG\Data";

options mprint nosymbolgen nomlogic;
options fmtsearch=(ipums health general);

** Autocall macros **;

filename uidev "D:\Projects\UISUG\MacroDev";
filename uiautos "K:\Metro\PTatian\UISUG\Uiautos";
options sasautos=(uidev uiautos sasautos);

%Delete_metadata_library( 
         ds_lib= Health,
         meta_lib= meta
  )

%File_info( data=Meta.Meta_libs, stats= )
%File_info( data=Meta.Meta_files, stats=, printobs=0 )
%File_info( data=Meta.Meta_vars, stats=, printobs=0 )
%File_info( data=Meta.Meta_fval, stats=, printobs=1000000 )
%File_info( data=Meta.Meta_history, stats=, printobs=0 )

/*************************************************************/
