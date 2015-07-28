/* Delete_metadata_file.sas - SAS Autocall Macro Library
 *
 * Deletes metadata for a SAS data set.
 *
 * NB:  Program written for SAS Version 8.2
 *
 * 12/20/04  Peter A. Tatian
 * 09/06/05  Added OPTIONS OBS=MAX to avoid data loss when updating metadata.
 ****************************************************************************/

/** Macro Delete_metadata_file - Start Definition **/

%macro Delete_metadata_file(  
         ds_lib= ,
         ds_name= ,
         meta_lib= ,
         meta_pre= meta,
         update_notify=
  );
  
  %let ds_lib = %upcase( &ds_lib );
  %let ds_name = %upcase( &ds_name );

  %** Save current OBS= setting then set to MAX **;

  %Push_option( obs )
  
  options obs=max;
  %Note_mput( macro=Delete_metadata_file, msg=OPTIONS OBS set to MAX for metadata processing. )

  ** Check for existence of library metadata file **;
  
  %if not %Dataset_exists( &meta_lib..&meta_pre._libs, quiet=n ) %then %do;
    %Err_mput( macro=Delete_metadata_file, msg=File &meta_lib..&meta_pre._libs does not exist. )
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
    %Err_mput( macro=Delete_metadata_file, msg=Library &ds_lib is not registered in the metadata system. )
    %goto exit_err;
  %end;
  
  ** Delete data set from metadata **;
  
  /** Macro _delete_file - Start Definition **/

  %macro _delete_file( metafile= );

    %if %Dataset_exists( &metafile, quiet=n ) %then %do;
  
      data &metafile (compress=char);

        set &metafile;
        
        if library = "&ds_lib" and FileName = "&ds_name"
          then delete;
      
      run;
    
    %end;
  
  %mend _delete_file;

  /** End Macro Definition **/

  %_delete_file( metafile=&meta_lib..&meta_pre._files )
  %_delete_file( metafile=&meta_lib..&meta_pre._vars )
  %_delete_file( metafile=&meta_lib..&meta_pre._fval )
  %_delete_file( metafile=&meta_lib..&meta_pre._history )
  
  %Note_mput( macro=Delete_metadata_file, msg=Data set &ds_lib..&ds_name deleted from metadata. )
  
  %goto exit;
  
  %exit_err:
  
  %Err_mput( macro=Delete_metadata_file, msg=Data set &ds_lib..&ds_name was not deleted from metadata system. )
  %goto exit;
  
  %exit:
  
  %** Restore system options **;
  
  %Pop_option( obs )

  %Note_mput( macro=Delete_metadata_file, msg=Macro exiting. )

%mend Delete_metadata_file;

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

%Delete_metadata_file( 
         ds_lib= Health,
         ds_name= Birth_1998_geo00,
         meta_lib= meta
  )

%File_info( data=Meta.Meta_libs, stats= )
%File_info( data=Meta.Meta_files, stats=, printobs=0 )
%File_info( data=Meta.Meta_vars, stats=, printobs=0 )
%File_info( data=Meta.Meta_fval, stats=, printobs=1000000 )
%File_info( data=Meta.Meta_history, stats=, printobs=0 )

/*************************************************************/
