/******************* URBAN INSTITUTE MACRO LIBRARY *********************
 
 Macro: Update_metadata_file

 Description: Registers metadata for a SAS data set.
 
 Use: Open code
 
 Author: Peter Tatian
 
***********************************************************************/

%macro Update_metadata_file( 
         ds_lib=        /** Data set library reference **/,
         ds_lib_display=  /** Library name displayed in metadata system (opt.) **/,
         ds_name=       /** Data set name **/,
         creator=       /** Name of data set creator **/,
         creator_process=  /** Name of data set creation process **/,
         revisions=     /** Description of latest data set revisions **/,
         format=SAS     /** Data set format **/,
         restrictions=None  /** Data set restrictions **/,
         desc_stats=n sum mean std min max  /** Descriptives to display in metadata **/,
         max_fmt_vals=100   /** Maximum number of formatted values to display **/,
         meta_lib=      /** Library reference for metadata data sets **/,
         meta_pre= meta /** Prefix for metadata data set names **/,
         update_notify= /** FUNCTION DISABLED **/,
         quiet=N,       /** Suppress LOG messages **/
         debug=N,       /** Print extra debugging information **/
         mprint=N,      /** Print resolved macro code to LOG **/
         add_exclude_fmts="",  /** Additional user-defined formats to exclude from value pages **/
         exclude_fmts= 
          "/$ASCII/$BIDI/$BINARY/$CHAR/$CPTDW/$CPTWD/$EBCDIC/$HEX/$KANJI/$KANJIX/$LOGVS/" ||
          "/$LOGVSR/$MSGCASE/$OCTAL/$QUOTE/$REVERJ/$REVERS/$UCS2B/$UCS2BE/$UCS2L/$UCS2LE/$UCS2X/" ||
          "/$UCS2XE/$UCS4B/$UCS4BE/$UCS4L/$UCS4LE/$UCS4X/$UCS4XE/$UESC/$UESCE/$UNCR/" ||
          "/$UNCRE/$UPAREN/$UPARENE/$UPCASE/$UTF8X/$VARYING/$VSLOG/$VSLOGR/$/" ||
          "/BEST/BINARY/COMMA/COMMAX/D/DATE/DATEAMPM/DATETIME/DAY/DDMMYY/" ||
          "/DDMMYYB/DDMMYYC/DDMMYYD/DDMMYYN/DDMMYYP/DDMMYYS/" ||
          "/DOLLAR/DOLLARX/DOWNAME/DTDATE/DTMONYY/DTWKDATX/DTYEAR/DTYYQC/" ||
          "/E/EURDFDD/EURDFDE/EURDFDN/EURDFDT/EURDFDWN/EURDFMN/EURDFMY/EURDFWDX/EURDFWKX/EURFRATS/EURFRBEF/" ||
          "/EURFRCHF/EURFRCZK/EURFRDEM/EURFRDKK/EURFRESP/EURFRFIM/EURFRFRF/EURFRGBP/EURFRGRD/EURFRHUF/" ||
          "/EURFRIEP/EURFRITL/EURFRLUF/EURFRNLG/EURFRNOK/EURFRPLZ/EURFRPTE/EURFRROL/EURFRRUR/EURFRSEK/EURFRSIT/" ||
          "/EURFRTRL/EURFRYUD/EURO/EUROX/EURTOATS/EURTOBEF/EURTOCHF/EURTOCZK/EURTODEM/EURTODKK/" ||
          "/EURTOESP/EURTOFIM/EURTOFRF/EURTOGBP/EURTOGRD/EURTOHUF/EURTOIEP/EURTOITL/EURTOLUF/EURTONLG/" ||
          "/EURTONOK/EURTOPLZ/EURTOPTE/EURTOROL/EURTORUR/EURTOSEK/EURTOSIT/EURTOTRL/EURTOYUD/" ||
          "/FLOAT/FRACT/HDATE/HEBDATE/HEX/HHMM/HOUR/IB/IBR/IEEE/" ||
          "/JULDAY/JULIAN/MINGUO/MMDDYY/" ||
          "/MMDDYYB/MMDDYYC/MMDDYYD/MMDDYYN/MMDDYYP/MMDDYYS/" ||
          "/MMSS/MMYY/" ||
          "/MMYYC/MMYYD/MMYYN/MMYYP/MMYYS/" ||
          "/MONNAME/MONTH/MONYY/NEGPAREN/NENGO/NLDATE/NLDATEMN/NLDATEW/NLDATEWN/NLDATM/NLDATMAP/" ||
          "/NLDATMTM/NLDATMW/NLMNY/NLMNYI/NLNUM/NLNUMI/NLPCT/NLPCTI/NLTIMAP/NLTIME/NUMX/" ||
          "/OCTAL/PD/PDJULG/PDJULI/PERCENT/PERCENTN/PIB/PIBR/PK/PVALUE/" ||
          "/QTR/QTRR/RB/ROMAN/" ||
          "/S370FF/S370FIB/S370FIBU/S370FPD/S370FPDU/S370FPIB/S370FRB/S370FZD/S370FZDL/S370FZDS/S370FZDT/S370FZDU/" ||
          "/SSN/TIME/TIMEAMPM/TOD/VAXRB/WEEKDATE/WEEKDATX/WEEKDAY/WEEKU/WEEKV/WEEKW/" ||
          "/WORDDATE/WORDDATX/WORDF/WORDS/YEAR/YEN/YYMM/" ||
          "/YYMMC/YYMMD/YYMMN/YYMMP/YYMMS/" ||
          "/YYMMDD/" ||
          "/YYMMDDB/YYMMDDC/YYMMDDD/YYMMDDN/YYMMDDP/YYMMDDS/" ||
          "/YYMON/" ||
          "/YYQ/" ||
          "/YYQC/YYQD/YYQN/YYQP/YYQS/" ||
          "/YYQR/" ||
          "/YYQRC/YYQRD/YYQRN/YYQRP/YYQRS/" ||
          "/Z/ZD/"
          /** SAS-defined formats to exlude from value pages **/
       );

  /*************************** USAGE NOTES *****************************
   
   SAMPLE CALL: 
     %Update_metadata_file( 
              ds_lib=Dat,
              ds_name=Shoes,
              creator=SAS Institute,
              creator_process=Shoes.sas,
              revisions=New file.,
              meta_lib=metadata
           )
         registers the data set Dat.Shoes in the metadata system

  *********************************************************************/

  /*************************** UPDATE NOTES ****************************

   01/02/04  Peter A. Tatian
   09/02/04  Dealt with situation where data set has no formatted values
             Clean up temporary data sets at end of macro
   10/28/04  Checks that library is registered in metadata system.
             If not, exits macro without processing file.
   10/29/04  Macro will now create _files, _vars, _fval, and _history 
             metadata files if they do not already exist.
   11/10/04  Added max_fmt_vals= option to limit number of formatted values
             written to metadata for a variable (def=100/max=2000000).
   11/11/04  NOTE printed to log when max. no. formatted values surpassed.
   11/15/04  Added support for SAS data set views.
   12/20/04  Setting desc_stats= to blank will suppress descriptive stats
             for numeric variables.
   03/25/05  Implemented update_notify= option.
   05/06/05  Added file sorted by info to metadata.
   09/06/05  Set OPTIONS OBS=MAX to avoid data loss when updating metadata.
             Set NOMPRINT unless MPRINT=Y.
   12/06/06  Added ADD_EXCLUDE_FMTS= option to exclude additional, 
             user-specified formats.
   03/08/08  Updated excluded format list to all SAS 9.2 formats.
   06/09/10  Write note to LOG for each email notification.
   09/29/10  Corrected problem with long data set names.
   02/23/11  PAT Added declaration for local macro vars.
                 Changed name of local macro vars fvar* to _fvar*.
   10/12/11  PAT Increased length of FileRevisions to 500.
   11/09/13  PAT Revised for use with new SAS server setup.
                 Added ds_lib_display=.
                 Removed update_notify= functionality.

   Next steps:
    - Handle situation where file has no numeric unformatted vars
  
  *********************************************************************/

  %***** ***** ***** MACRO SET UP ***** ***** *****;
   
  %local sortvars SAS_DATASET_VIEW lib_exists ds_name25 allfvar i em num_fval_vars num_vars;

  %let SAS_DATASET_VIEW = "SASDSV";
    
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
  
  %** Shorter file name for temporary data sets **;
  
  %if %length( &ds_name ) > 25 %then %let ds_name25 = %substr( &ds_name, 1, 25 );
  %else %let ds_name25 = &ds_name;
  
  %** Force step boundary **;
  
  run;
  
  %** Save current OBS= setting then set to MAX **;

  %Push_option( obs )
  
  options obs=max;
  %Note_mput( macro=Update_metadata_file, msg=OPTIONS OBS set to MAX for metadata processing. )

    
  %***** ***** ***** ERROR CHECKS ***** ***** *****;

  %** Check for existence of library metadata file **;
  
  %if not %Dataset_exists( &meta_lib..&meta_pre._libs, quiet=n ) %then %do;
    %Err_mput( macro=Update_metadata_file, msg=File &meta_lib..&meta_pre._libs does not exist. )
    %goto exit_err;
  %end;

  %** Check that library is registered **;
  
  %Data_to_format( 
    FmtName=$libchk, 
    inDS=&meta_lib..&meta_pre._libs, 
    value=upcase( Library ),
    label="Y",
    otherlabel="N",
    print=N )

  data _null_;
    call symput( 'lib_exists', put( upcase( "&ds_lib_display" ), $libchk. ) );
  run;
    
  %if &lib_exists = N %then %do;
    %Err_mput( macro=Update_metadata_file, msg=Library &ds_lib_display is not registered in the metadata system. )
    %goto exit_err;
  %end;
  
  %** Check for existence of data set to be registered **;
  
  %if not ( %Dataset_exists( &ds_lib..&ds_name, quiet=n, memtype=data ) or
            %Dataset_exists( &ds_lib..&ds_name, quiet=n, memtype=view ) ) %then %do;
    %Err_mput( macro=Update_metadata_file, msg=The data set &ds_lib..&ds_name does not exist. )
    %goto exit_err;
  %end;


  %***** ***** ***** MACRO BODY ***** ***** *****;
  
  ** Get data set contents **;
  
  proc contents data=&ds_lib..&ds_name out=_cnts_&ds_name25 noprint;
 
  %if %mparam_is_yes( &debug ) %then %do;
    proc contents data=_cnts_&ds_name25;
      title2 "File = _cnts_&ds_name25";
    proc print data=_cnts_&ds_name25;
  %end;
  
  %if %length( &desc_stats ) > 0 %then %do;
  
    ** Check for numeric variables **;
  
    proc sql;
      select name into :num_vars separated by ' '
      from dictionary.columns
      where upcase(libname)="%upcase(&ds_lib)" and upcase(memname)="%upcase(&ds_name)" and upcase(type) = "NUM";
    quit;
    
    %if %length( &num_vars ) > 0 %then %do;
    
      ** Get descriptive statistics for numeric variables **;
   
      %Compile_num_desc( stats=&desc_stats, ds_lib=&ds_lib, ds_name=&ds_name )
      
    %end;
    %else %do;
    
      %note_mput( macro=Update_metadata_file, msg=No numeric variables in data set %upcase(&ds_lib..&ds_name). )
    
    %end;
    
  %end;
  
  ** Get list of sorted by variables **;

  proc sql noprint;
    create table _sortvars (compress=no) as
    select name, sortedby 
    from _cnts_&ds_name25 (where=(sortedby > 0))
    order by sortedby
    ;

    select name 
    into :sortvars separated by ', '
    from _sortvars
    ;

  ** Merge contents and descriptive stats files **;

  proc sort data=_cnts_&ds_name25;
    by name;

  data _info_&ds_name25;
  
    %if %length( &desc_stats ) > 0 and %length( &num_vars ) > 0 %then %do;

      merge _cnts_&ds_name25 &_compile_num_desc_out (rename=(_name_=name));
      by name;
      
      format _desc_: ;

    %end;
    %else %do;
    
      set _cnts_&ds_name25;

    %end;
    
  run;
  
  proc sort data=_info_&ds_name25;
    by varnum;

  run;
  
  %if %mparam_is_yes( &debug ) %then %do;
    proc print data=_info_&ds_name25 (obs=10);
      title2 "File = _info_&ds_name25";
    run;
  %end;
  
  ** Process and validate metadata in contents      **;
  ** Create new records for updating metadata files **;
  
  data 
  
    /* File record */
    _f_&ds_name25 
      (keep=libname_display memname memlabel nobs modate MetadataUpdated FileCreator FileProcess
            FileFmt FileRestrict FileSortedBy
       rename=(libname_display=Library memname=FileName memlabel=FileDesc nobs=NumObs 
               modate=FileUpdated))

    /* History record */
    _h_&ds_name25 
      (keep=libname_display memname modate MetadataUpdated FileCreator FileProcess
            FileRevisions
       rename=(libname_display=Library memname=FileName modate=FileUpdated))

    /* Variable records */
    _v_&ds_name25
      (keep=libname_display memname varnum name VarNameUC label VarType length format
            ListFmtVals
              %if %length( &desc_stats ) > 0 and %length( &num_vars ) > 0 %then %do;
                _desc_:
              %end;
       rename=(libname_display=Library memname=FileName varnum=VarOrder name=VarName label=VarDesc
               length=VarLen format=VarFmt))
      
    ;
  
    length libname_display $ 32;         ** Force resize of libname variable **;
    
    retain libname_display "%upcase( &ds_lib_display )";
 
    set _info_&ds_name25;
    
    length 
      VarType $ 1 
      VarNameUC FileFmt $ 32
      FileCreator FileProcess $ 80
      FileRestrict FileSortedBy $ 250
      FileRevisions $ 500
      ListFmtVals 3
    ;
    
    ** Process file-level data (first obs.) **;
    
    if _n_ = 1 then do;
    
      if memlabel = "" then do;
        %warn_put( macro=Update_metadata_file, msg="Data set &ds_name not labeled." )
      end;
        
      MetadataUpdated = datetime();
      
      format MetadataUpdated datetime16.;
      
      %if &format = SAS %then %do;
        if Engine = &SAS_DATASET_VIEW then 
          FileFmt = "SAS/View";
        else
          FileFmt = "SAS/" || trim( Engine );
      %end;
      %else %do;
        FileFmt = "&format";
      %end;
      
      FileCreator = "&creator";
      FileProcess = "&creator_process";
      FileRevisions = "&revisions";
      FileRestrict = "&restrictions";
      FileSortedBy = lowcase( "&sortvars" );
      
      output _f_&ds_name25;
      
      output _h_&ds_name25;

    end;
    
    ** Process variable-level data (all obs.) **;
    
    if label = "" then do;
      %Warn_put( macro=Update_metadata_file, msg="Variable " name " in data set &ds_name not labeled." )
    end;

    if type = 1 then VarType = "N";
    else if type = 2 then VarType = "C";
    
    VarNameUC = upcase( name );
    
    if format ~= "" and 
       not index( %upcase(&exclude_fmts||&add_exclude_fmts), compress( "/" || format || "/" ) )
       then
         ListFmtVals = 1;
       else
         ListFmtVals = 0;
    
    output _v_&ds_name25;
    
    label
      memname = "Data set name"
      libname_display = "Library name"
      FileFmt = "Data set format"
      FileCreator = "Name of data set creator"
      FileProcess = "Name or description of data set creation process"
      FileRevisions = "Revisions since previous data set version"
      FileRestrict = "Type of data set restrictions"
      FileSortedBy = "List of variables indicating data set sort order (if sorted)"
      MetadataUpdated = "Date metadata was updated"
      ListFmtVals = "Formatted values listed in metadata (1=Yes)"
      VarNameUC = "Variable name (uppercase, for sorting)"
      VarType = "Variable type (C/N)"
    ;
    
  run;
  
  proc sort data=_v_&ds_name25;
    by Library FileName VarNameUC;
  
  %if %mparam_is_yes( &debug ) %then %do;

    proc print data=_f_&ds_name25;
      format FileRestrict $40.;
      title2 "_f_&ds_name25";

    proc print data=_h_&ds_name25;
      title2 "_h_&ds_name25";

    proc print data=_v_&ds_name25;
      title2 "_v_&ds_name25";

    run;
    
  %end;
  
  ** Create data set with frequencies for formatted variables **;
  
  data _null_;
  
    set _v_&ds_name25 end=eof;
    
    if ListFmtVals then do;
      count + 1;
      call symput( '_fvar' || left( count ), VarName );
    end;
    
    if eof then call symput( 'num_fval_vars', count );
  
  run;
  
  %let allfvar = ;

  *options mprint symbolgen mlogic;

  %if &num_fval_vars > 0 %then %do;

    %do i = 1 %to &num_fval_vars;
      %let allfvar = &allfvar &&_fvar&i;
    %end;
    
    %if %mparam_is_yes( &debug ) %then %do;
      %put num_fval_vars=&num_fval_vars;
      %put allfvar=&allfvar;
    %end;
    
    %Freq_table( in_data = &ds_lib..&ds_name,
      var_list = &allfvar,
      out_data = _fvals_&ds_name25 )

    %if %mparam_is_yes( &debug ) %then %do;
      proc print data=_fvals_&ds_name25;
        title2 "File = _fvals_&ds_name25";
      run;
    %end;
    
    data 
    
      /* Formatted values record */
      _fv_&ds_name25  
        (keep=Library FileName Variable VarNameUC Frequency Value FmtValue
         MaxFmtVals
         rename=(Variable=VarName))
      ;
      
      length variable $ 32;         ** Force resize of variable name variable **;
      
      length Library FileName VarNameUC $ 32;
      
      length MaxFmtVals 4;
      
      retain Library "%upcase(&ds_lib_display)" FileName "%upcase(&ds_name)";
        
      set _fvals_&ds_name25;
        by Variable notsorted;
      
      if first.Variable then count = 0;
      
      count + 1;
      
      VarNameUC = upcase( Variable );
      
      if count = &max_fmt_vals and not last.Variable then do;
        MaxFmtVals = &max_fmt_vals;
        %Note_put( macro=Update_metadata_file, 
                   msg="Maximum no. of formatted values (&max_fmt_vals) reached for var. " VarNameUC                       " Additional values will be suppressed in metadata." )
      end;

      if count <= &max_fmt_vals then output;
      
      label
        FileName = "Data set name"
        Library = "Library name"
        VarNameUC = "Variable name (uppercase, for sorting)"
        Frequency = "Frequency count for value"
        MaxFmtVals = "If not missing, maximum number of formatted values for metadata was surpassed"
      ;
      
    run;
    
    proc sort data=_fv_&ds_name25;
      by Library FileName VarNameUC Value;
      
    run;
    
    %if %mparam_is_yes( &debug ) %then %do;
      proc print data=_fv_&ds_name25;
        title2 "File = _fv_&ds_name25";
      run;
    %end;

  %end;
  
  ** Create metadata files if they do not exist **;
  
  %if not %dataset_exists( &meta_lib..&meta_pre._files ) %then %do;
    %Note_mput( macro=Update_metadata_file, msg=File &meta_lib..&meta_pre._files does not exist - it will be created. )
    data &meta_lib..&meta_pre._files;
      set _f_&ds_name25 (obs=0);
    run;
  %end;  

  %if not %dataset_exists( &meta_lib..&meta_pre._history ) %then %do;
    %Note_mput( macro=Update_metadata_file, msg=File &meta_lib..&meta_pre._history does not exist - it will be created. )
    data &meta_lib..&meta_pre._history;
      set _h_&ds_name25 (obs=0);
    run;
  %end;  

  %if not %dataset_exists( &meta_lib..&meta_pre._vars ) %then %do;
    %Note_mput( macro=Update_metadata_file, msg=File &meta_lib..&meta_pre._vars does not exist - it will be created. )
    data &meta_lib..&meta_pre._vars;
      set _v_&ds_name25 (obs=0);
    run;
  %end;  

  %if not %dataset_exists( &meta_lib..&meta_pre._fval ) %then %do;
    %if %dataset_exists( _fv_&ds_name25 ) %then %do;
      %Note_mput( macro=Update_metadata_file, msg=File &meta_lib..&meta_pre._fval does not exist - it will be created. )
      data &meta_lib..&meta_pre._fval;
        set _fv_&ds_name25 (obs=0);
      run;
    %end;
  %end;  

  ** Update file record in metadata **;

  data &meta_lib..&meta_pre._files (compress=char);
  
    update &meta_lib..&meta_pre._files _f_&ds_name25 updatemode=nomissingcheck;
      by Library FileName;
    
  run;
  
  ** Update file history record in metadata **;
  
  data &meta_lib..&meta_pre._history (compress=char);
  
    update &meta_lib..&meta_pre._history _h_&ds_name25;
      by Library FileName descending FileUpdated;
    
  run;
  
  ** Update variable records in metadata **;
  
  data _vars;
  
    set &meta_lib..&meta_pre._vars;
    
    if library = "%upcase( &ds_lib_display )" and FileName = "%upcase( &ds_name )"
      then delete;
    
  run;
  
  data &meta_lib..&meta_pre._vars (compress=char);
  
    update _vars _v_&ds_name25 updatemode=nomissingcheck;
      by Library FileName VarNameUC;
    
  run;
  
  ** Update formatted variable value records in metadata **;
  
  %if %dataset_exists( &meta_lib..&meta_pre._fval ) %then %do;
  
    data _fvalues;
    
      set &meta_lib..&meta_pre._fval;
      
      if library = "%upcase( &ds_lib_display )" and FileName = "%upcase( &ds_name )"
        then delete;
      
    run;
      
    %if &num_fval_vars > 0 %then %do;
    
      data &meta_lib..&meta_pre._fval (compress=char);
      
        update _fvalues _fv_&ds_name25 updatemode=nomissingcheck;
          by Library FileName VarNameUC Value;
        
      run;
      
    %end;
    %else %do;
    
      data &meta_lib..&meta_pre._fval (compress=char);
      
        set _fvalues;
        
      run;
      
    %end;
  
  %end;
  
  ** Print updated metadata to log (unless Quiet=Y) **;
  
  %if %upcase( &quiet ) ~= Y %then %do;
  
    data _null_;
      set _f_&ds_name25;
      put;
      %Note_put( macro=Update_metadata_file, msg="Update to File metadata record:" )
      put (_all_) (= /);
      put /;
    run;
  
    data _null_;
      set _h_&ds_name25;
      put;
      %Note_put( macro=Update_metadata_file, msg="Update to File History metadata record:" )
      put (_all_) (= /);
      put /;
    run;
  
    data _null_;

      set _v_&ds_name25 end=eof;
      
      if eof then do;
        put;
        %Note_put( macro=Update_metadata_file, msg="Update to Variables metadata record:" )
        put Library= / FileName= ;
        put "NumberVariables=" _n_;
        put /;
      end;

    run;
  
    %if &num_fval_vars > 0 %then %do;
    
      data _null_;

        set _fv_&ds_name25;
        by VarNameUC;
        
        count + 1;

        if _n_ = 1 then do;
          put;
          %Note_put( macro=Update_metadata_file, msg="Update to Formatted Values metadata record:" )
          put Library= / FileName= ;
        end;
        
        if last.VarNameUC then do;
          put VarName= @;
          put " / NumberValues=" count;
          put /;
          count = 0;
        end;

      run;
      
    %end;
    %else %do;
    
      %put;
      %Note_mput( macro=Update_metadata_file, msg=No Formatted Values updated. )
      
    %end;
    
  %end;
  
  %if %mparam_is_yes( &debug ) %then %do;
  
    proc contents data=&meta_lib..&meta_pre._files;
      title2 "File = &meta_lib..&meta_pre._files";
      
    proc print data=&meta_lib..&meta_pre._files;
      format FileRestrict $40.;
      title2 "File = &meta_lib..&meta_pre._files";
      
    proc contents data=&meta_lib..&meta_pre._history;
      title2 "File = &meta_lib..&meta_pre._history";

    proc print data=&meta_lib..&meta_pre._history;
      title2 "File = &meta_lib..&meta_pre._history";
      
    proc contents data=&meta_lib..&meta_pre._vars;
      title2 "File = &meta_lib..&meta_pre._vars";

    proc print data=&meta_lib..&meta_pre._vars;
      title2 "File = &meta_lib..&meta_pre._vars";
      
    proc contents data=&meta_lib..&meta_pre._fval;
      title2 "File = &meta_lib..&meta_pre._fval";

    proc print data=&meta_lib..&meta_pre._fval noobs;
      by Library Filename VarNameUC;
      title2 "File = &meta_lib..&meta_pre._fval";

    run;
    
  %end;
  
  /****** FUNCTION DISABLED ******
    
  ** Notify by email of metadata update **;
  
  %if %length( &update_notify ) > 0 %then %do;

    %if &SYSSCP = WIN %then %do;
      %Warn_mput( macro=Update_metadata_file, msg=Email notification (UPDATE_NOTIFY=) is only available in Alpha environment. )
    %end;
    %else %do;
      %let i = 1;
      %let em = %scan( &update_notify, &i, %str( ) );
      %do %until ( &em = );
        %note_mput( macro=Update_metadata_file, msg=Email notification being sent to &em.. )
        X mail /subject="Metadata for &ds_lib..&ds_name updated by &creator" nl: "&em";
        %let i = %eval( &i + 1 );
        %let em = %scan( &update_notify, &i, %str( ) );
      %end;
    %end;
  
  %end;
  
  ********************************/
  

  %***** ***** ***** CLEAN UP ***** ***** *****;

  ** Clean up all temporary files **;
  
  proc datasets library=WORK memtype=(data) nolist nowarn;
    delete _cnts_: _desc_: _fvals_: _fvalues _f_: _fv_: _h_: _v_:
           _info_: _vars _sortvars;
  quit;
  run;
  
  %Note_mput( macro=Update_metadata_file, msg=Data set &ds_lib_display..&ds_name successfully registered with metadata system. )
  %goto exit;
  
  %exit_err:
  
  %Err_mput( macro=Update_metadata_file, msg=Data set &ds_lib_display..&ds_name was not registered with metadata system. )
  %goto exit;
  
  %exit:

  %** Restore system options **;
  
  %Pop_option( obs )
  %Pop_option( mprint )
  

  %Note_mput( macro=Update_metadata_file, msg=Macro Update_metadata_file() exiting. )

%mend Update_metadata_file;



/************************ UNCOMMENT TO TEST ***************************/

** Autocall macros **;

filename uiautos "K:\Metro\PTatian\UISUG\Uiautos";
options sasautos=(uiautos sasautos) noxwait;

** Set up and clear test folder **;

x "md d:\temp\Update_metadata_file_test";
x "del /q d:\temp\Update_metadata_file_test\*.*";

libname test "d:\temp\Update_metadata_file_test\";

proc format library=work;
  value $region
    "Africa" = "~Africa"
    "Asia" = "~Asia"
    "Canada" = "~Canada"
    "Central America/Caribbean" = "~Central America/Caribbean"
    "Eastern Europe" = "~Eastern Europe"
    "Middle East" = "~Middle East"
    "Pacific" = "~Pacific"
    "South America" = "~South America"
    "United States" = "~United States"
    "Western Europe" = "~Western Europe";
    
data Test.Shoes;

  set Sashelp.shoes;
  
  dtvar = datetime();
  
  format region $region.;
  format dtvar datetime.;
  
run;

data Test.Shoes_nonum;

  set Test.shoes;
  
  keep _character_;
  
run;

data Test.Shoes_empty;

  set Test.shoes (obs=0);
  
run;

%File_info( data=Test.shoes, freqvars=region )
%File_info( data=Test.shoes_nonum, stats= )
%File_info( data=Test.shoes_empty, stats= )

%Update_metadata_file( 
         ds_lib=Test,
         ds_name=Shoes,
         creator=SAS Institute,
         creator_process=SAS Institute,
         revisions=Test file.,
         meta_lib=Test
      )

%Update_metadata_library( 
         lib_name=Test,
         lib_desc=Test library,
         meta_lib=Test
      )

%Update_metadata_file( 
         ds_lib=Test,
         ds_name=Shoes,
         creator=SAS Institute,
         creator_process=SAS Institute,
         revisions=Test file.,
         meta_lib=Test,
         mprint=y
      )

%Update_metadata_file( 
         ds_lib=Test,
         ds_name=Shoes_nonum,
         creator=SAS Institute,
         creator_process=SAS Institute,
         revisions=Test file.,
         meta_lib=Test,
         mprint=y
      )

proc datasets library=Test memtype=(data);
quit;

%File_info( data=Test.Meta_files, printobs=50, contents=n, stats= )
%File_info( data=Test.Meta_vars, printobs=50, contents=n, stats= )
%File_info( data=Test.Meta_fval, printobs=50, contents=n, stats= )
%File_info( data=Test.Meta_history, printobs=50, contents=n, stats= )

/**********************************************************************/
