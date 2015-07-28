/* Update_metadata_library.sas - SAS Autocall Macro Library
 *
 * Registers metadata for a SAS library.
 *
 * NB:  Program written for SAS Version 8.2
 *
 * 01/02/04  Peter A. Tatian
 * 
 * Modifications:
 * 10/29/04  Macro now will create _libs file if it does not exist.
 * 09/06/05  Set OPTIONS OBS=MAX to avoid data loss when updating metadata.
   09/29/10  PAT  Delete temporary data set at end of macro execution.
 ****************************************************************************/

/** Macro Update_metadata_library - Start Definition **/

%macro Update_metadata_library( 
         lib_name= ,
         lib_desc= ,
         meta_lib= ,
         meta_pre= meta,
         quiet=N
       );

  %** Save current OBS= setting then set to MAX **;

  %Push_option( obs )
  
  options obs=max;
  %Note_mput( macro=Update_metadata_library, msg=OPTIONS OBS set to MAX for metadata processing. )

  ** Create library record **;
  
  data _lib_&lib_name;
  
    length Library $ 32 LibDesc $ 400;
    
    Library = upcase( "&lib_name" );
    LibDesc = "&lib_desc";
  
  run;
  
  ** Create library metadata file if it does not exist **;
  
  %if not %dataset_exists( &meta_lib..&meta_pre._libs ) %then %do;
    %Note_mput( macro=Update_metadata_library, msg=File &meta_lib..&meta_pre._libs does not exist - it will be created. )
    data &meta_lib..&meta_pre._libs;
      set _lib_&lib_name (obs=0);
    run;
  %end;  

** Update library list **;
  
  data &meta_lib..&meta_pre._libs (compress=char);
  
    update &meta_lib..&meta_pre._libs _lib_&lib_name;
      by Library;
      
  run;
  
  %if %upcase( &quiet ) ~= Y %then %do;

    data _null_;
      set _lib_&lib_name;
      put;
      %Note_put( macro=Update_metadata_file, msg="Update to Library metadata record:" )
      put (_all_) (= /);
      put /;
    run;
    
  %end;
  
  run;
  
  %Note_mput( macro=Update_metadata_library, msg=Library %upcase( &lib_name ) has been registered with the metadata system. )

  ** Delete temporary data set **;
  
  proc datasets library=work memtype=(data) nolist nowarn;
    delete _lib_&lib_name;
  quit;
  
  %exit:

  %** Restore system options **;
  
  %Pop_option( obs )

  %Note_mput( macro=Update_metadata_library, msg=Macro exiting. )
    
%mend Update_metadata_library;

/** End Macro Definition **/


/******************** UNCOMMENT TO TEST MACRO ********************

libname general v8 "D:\Projects\DCNIS\Data\General";
libname health v8 "D:\Projects\DCNIS\Data\Health";
libname ipums v8 "D:\DCData\Libraries\IPUMS\Data";
libname meta v8 "D:\Projects\UISUG\Data";

options mprint nosymbolgen nomlogic;

** Autocall macros **;

filename uidev "D:\Projects\UISUG\MacroDev";
filename uiautos "K:\Metro\PTatian\UISUG\Uiautos";
options sasautos=(uidev uiautos sasautos);

%Update_metadata_library( 
         lib_name= ipums,
         lib_desc= Census/Integrated Public Microdata Sample (IPUMS),
         meta_lib= meta
       )

%Update_metadata_library( 
         lib_name= general,
         lib_desc= General purpose data files,
         meta_lib= meta
       )

%Update_metadata_library( 
         lib_name= health,
         lib_desc= Births and deaths from State Center for Health Statistics,
         meta_lib= meta
       )

%File_info( data=meta.meta_libs, stats= )

/*********************************************************/
