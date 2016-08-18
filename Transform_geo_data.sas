/******************* URBAN INSTITUTE MACRO LIBRARY *********************
 
 Macro: Transform_geo_data

 Description: Autocall macro to convert data from an original geographic 
 level to new geography using a normalized weighting file. 
 
 Use: Open code
 
 Author: Peter Tatian
 
***********************************************************************/

%macro Transform_geo_data(
    dat_ds_name = ,    /** Input data set library and name **/
    dat_org_geo = ,    /** Original geo id in input data set **/
    dat_new_geo = ,    /** Specify an alternate aggregation geo var from input data set when a weighting file is not being used (optional) **/
    dat_count_vars = , /** Count vars in input data set **/
    dat_prop_vars  = , /** Proportion vars in input data set **/
    dat_id_vars = ,    /** ID variables from input data set to add to output data set observations (optional) **/
    dat_count_moe_vars = ,  /** Margin of error vars for transformed count vars (optional) **/
    calc_vars = ,      /** SAS statements to define calculated vars based on transformed data (optional) **/
    calc_vars_labels = ,  /** Variable labels for vars defined in calc_vars= (optional) **/
    wgt_ds_name = ,    /** Weighting file data set library and name **/
    wgt_org_geo = ,    /** Original geo id in weighting file **/
    wgt_new_geo = ,    /** New geo id in weighting file **/
    wgt_new_geo_fmt = ,  /** Format for weighting file geo var, will be added to output data set (optional) **/
    wgt_id_vars = ,    /** Additional geo IDs in weighting file (optional) **/
    wgt_wgt_var = ,    /** Alias for wgt_count_var= **/
    wgt_count_var = ,  /** Name of weight variable to use for counts **/
    wgt_prop_var = ,   /** Name of weight variable to use for proportions **/
    out_ds_name = ,    /** Output data set library and name **/
    out_ds_label = ,   /** Label for output data set (optional) **/
    show_warnings = 10,  /** Number of nonmatch warnings to show (optional, def. 10) **/
    keep_nonmatch = N,   /** Keep nonmatching obs in output data (optional, Y/N, def. N) **/
    print_diag = Y,    /** Print diagnostic table at end if input and output count sums do not match (optional, Y/N, def. Y) **/
    max_diff = 0.00001,   /** Maximum difference allowed for diagnostic check of count variable sums (optional, def. 0.00001) **/
    full_diag = N,     /** Print full diagnostics (optional, Y/N, def. N) **/
    mprint = N         /** Sets printing of resolved macro code (optional, Y/N, def. N) **/
  );
  
  /*************************** USAGE NOTES *****************************
   
   SAMPLE CALL: 
     %Transform_geo_data(
         dat_ds_name = Test_dat,
         dat_org_geo = geo_in,
         dat_count_vars = count1 count2,
         dat_prop_vars  = prop1, 
         calc_vars = 
           prop2 = 100 * ( count1 / count2 );
           sum1 = count1 + count2; ,
         calc_vars_labels = 
           prop2 = "100 * ( count1 / count2 )"
           sum1 = "count1 + count2" , 
         wgt_ds_name = Test_wgt,
         wgt_org_geo = geo_in,
         wgt_new_geo = geo_out,
         wgt_id_vars = alt_id,
         wgt_count_var = wt,
         wgt_prop_var = wt,
         out_ds_name = Test_out,
         out_ds_label = Transform_geo_data macro test output data set
       )

     The following named parameters must be supplied:
         dat_ds_name    = Input data set library and name
         dat_org_geo    = Original geo id in input data set
         wgt_ds_name    = Weighting file data set library and name
         wgt_org_geo    = Original geo id in weighting file
         wgt_new_geo    = New geo id in weighting file
         out_ds_name    = Output data set library and name
    
     At least one of the two variable lists (or both) must be supplied:
         dat_count_vars = Count vars in input data set
         dat_prop_vars  = Proportion vars in input data set
    
     One or more of the following weighting variables must be supplied based on the variable lists specified:
         wgt_count_var  = Name of weight variable to use for counts
         wgt_wgt_var    = Alias for wgt_count_var=
         wgt_prop_var   = Name of weight variable to use for proportions

     The following parameters are optional:
         dat_new_geo    = Specify an alternate aggregation geo var from input data set when a weighting file is not being used
         dat_id_vars    = ID variables from input data set to add to output data set observations
         dat_count_moe_vars = Margin of error vars for transformed count vars
         out_ds_label   = Label for output data set
         wgt_new_geo_fmt = Format for weighting file geo var, will be added to output data set
         wgt_id_vars    = Additional geo IDs in weighting file
         calc_vars      = SAS statements to define calculated vars based on transformed data
         calc_vars_labels = Variable labels for vars defined in calc_vars=
         show_warnings  = Number of nonmatch warnings to show (def. 10)
         keep_nonmatch  = Keep nonmatching obs in output data (Y/N, def. N)
         print_diag     = Print diagnostic table at end if input and output count sums do not match (Y/N, def. Y)
         full_diag      = Print full diagnostics (Y/N, def. N)
         max_diff       = Maximum difference allowed for diagnostic check of count variable sums (def. 0.00001)
         mprint         = Sets printing of resolved macro code (Y/N, def. N)
    
     NOTES:
       The weighting file is assumed to be normalized, that is, the values
       of the count weight variable (wgt_count_var=) must sum to 1 for each value of 
       the original geography variable (wgt_org_geo=) and 
       values of the proportion weight variable (wgt_prop_var=) must sum to 1 for each
       value of the new geography variable (wgt_new_geo=).
    
       Neither the weight file nor the input file needs to be sorted.
    
       The keep_nonmatch= parameter controls how obs. in the input data set
       that do not have a matching geo ID in the weighting data set are 
       handled.  If keep_nonmatch=Y, the nonmatching obs are kept in the 
       output file and are given the same geo ID value as in the input file.
       If keep_nonmatch=N, the nonmatching obs are dropped.  
    
       For each nonmatch, a warning message will be printed in the SAS log 
       up to the number specified in show_warnings=. To suppress all nonmatch
       warnings, set show_warnings=0.
  
  *********************************************************************/

  /*************************** UPDATE NOTES ****************************

   09/09/02  Peter A. Tatian
   10/03/02  Macro now issues a nonmatch warning if the matching record 
             in the weight file has a missing value for the weight variable.
             PAT
   08/11/03  Added calc_vars= and calc_vars_labels= options.  PAT
   12/30/03  Corrected warning message using wgt_org_geo.  PAT
   01/14/05  Suppress variable labels in diagnostic output.  PAT
   08/21/06  Added WGT_NEW_GEO_FMT= option.  
             Modified diagnostic output to use Proc Compare.  PAT
   08/27/06  Added MAX_DIFF= option. Changed Proc Compare method to relative.
             Updated macro log messages.
   08/28/06  Changed Compare method to Absolute. Added MPRINT= option.
   12/18/07  Added dat_id_vars= parameter.
   06/27/11  Added dat_count_moe_vars= parameter to support calculation of
             aggregated margins of error.
             Omitting weight file now permitted. (Useful for margin of error
             aggregations without any weighting file.) Optional parameter 
             DAT_NEW_GEO= can be used to specify an alternate aggregation
             geo from the input data set when a weighting file is not being
             used. PAT
   07/09/11  Changed weighting for MOE calculation to simple weight 
             (previously was squared weight). 
   07/19/11  Corrected problem with "&out_ds_label] ~= " test. Replaced with
             "%length( &out_ds_label ) > 0".  PAT
   07/14/12  Added wgt_count_var= and wgt_prop_var= parameters to specify
             separate weights for counts and proportions. wgt_wgt_var= 
             is an alias for wgt_count_var=.

  *********************************************************************/

  %***** ***** ***** MACRO SET UP ***** ***** *****;
   
  %local macro version i v;
    
  %let macro = Transform_geo_data;
  %let version = 7/14/12;
  
    
  %***** ***** ***** ERROR CHECKS ***** ***** *****;



  %***** ***** ***** MACRO BODY ***** ***** *****;
  
  %note_mput( macro=&macro, msg=Starting macro (version &version). )
  
  %let mprint = %upcase( &mprint );
  
  %push_option( mprint )

  %if %mparam_is_yes( &mprint ) %then %do;
    options mprint;
  %end;
  %else %do;
    options nomprint;
  %end;
  
  %if &wgt_count_var = %then %let wgt_count_var = &wgt_wgt_var;
  
  %** Check parameters **;
  
  %if &wgt_ds_name = %then %do;
  
    %note_mput( macro=&macro, msg=No weighting file specified (WGT_DS_NAME=). )
  
    %let wgt_new_geo = &dat_new_geo;
  
  %end;
  %else %do;
  
    %if &dat_new_geo ~= %then %do;
      %warn_mput( macro=&macro, msg=Weighting file specified so DAT_NEW_GEO=&dat_new_geo will be ignored. )
      %let dat_new_geo = ;
    %end;
    
    %if ( ( &dat_count_vars ~= ) or ( &dat_count_moe_vars ~= ) ) and &wgt_count_var = %then %do;
      %err_mput( macro=&macro, msg=No weight variable specified for count variables (WGT_COUNT_VAR=). )
      %goto exit;
    %end;
  
    %if &dat_prop_vars ~= and &wgt_prop_var = %then %do;
      %err_mput( macro=&macro, msg=No weight variable specified for proportion variables (WGT_PROP_VAR=). )
      %goto exit;
    %end;
 
  %end;
  
  %put calc_vars= &calc_vars;
  
  ** Sort data for merging **;
  
  %if &wgt_ds_name ~= %then %do;
    proc sort 
        data=&wgt_ds_name (keep=&wgt_org_geo &wgt_new_geo &wgt_count_var &wgt_prop_var &wgt_id_vars )
        out=_tgd_wgt_file;
      *where not missing( sum( of &wgt_count_var &wgt_prop_var ) );
      %if &wgt_count_var ~= %then %do;
        %if &wgt_prop_var ~= %then %do;
          where &wgt_count_var >= 0 or &wgt_prop_var >= 0;
        %end;
        %else %do;
          where &wgt_count_var >= 0;
        %end;
      %end;
      %else %if &wgt_prop_var ~= %then %do;
        where &wgt_prop_var >= 0;
      %end;
      by &wgt_org_geo;
    run;
  %end;
  
  proc sort 
      data=&dat_ds_name (keep=&dat_org_geo &dat_new_geo &dat_count_vars &dat_count_moe_vars 
                              &dat_prop_vars &dat_id_vars)
      out=_tgd_dat_file;
    by &dat_org_geo;
  run;
    
  data _tgd_wgt_merg;

    ** Initialize warning count **;
    
    retain _warn_ct (&show_warnings);
    
    %if &wgt_ds_name ~= %then %do;
    
      ** Transform using weighting file **;

      merge
        _tgd_wgt_file (in=in_wf)
        _tgd_dat_file (in=in_df rename=(&dat_org_geo=&wgt_org_geo));
      by &wgt_org_geo;
      
      if not( in_wf ) then do;
      
        if _warn_ct > 0 then do;
          %warn_put( macro=&macro, msg="Matching obs. not found in weight file: &dat_ds_name/" 
            "&dat_org_geo=" &wgt_org_geo )
          %if %mparam_is_yes( &keep_nonmatch ) %then %do;
            %note_put( macro=&macro, msg="Nonmatching obs. will be kept (KEEP_NONMATCH=Y)." )
          %end;
          %else %do;
            %note_put( macro=&macro, msg="Nonmatching obs will be dropped (KEEP_NONMATCH=N)." )
          %end;
          _warn_ct = _warn_ct - 1;
          if _warn_ct = 0 then do;
            %note_put( macro=&macro, msg="No further nonmatch warnings will be printed because maximum reached (SHOW_WARNINGS=&show_warnings)." )
          end;
            
        end;
        
        %if %mparam_is_yes( &keep_nonmatch ) %then %do;
          %if &wgt_count_var ~= %then %do;
            &wgt_count_var = 1;
          %end;
          %if &wgt_prop_var ~= %then %do;
            &wgt_prop_var = 1;
          %end;
          &wgt_new_geo = &wgt_org_geo;
        %end;
        %else %do;
          delete;
        %end;
      
      end;
      
      ** Only retain obs in data file **;

      if in_df;

      drop _warn_ct;

    %end;
    %else %do;
    
      ** Transform without weighting file **;

      %let wgt_wgt_var = _tgd_weight_dum;
    
      set _tgd_dat_file;
      
      %if &wgt_count_var ~= %then %do;
        &wgt_count_var = 1;
      %end;
      %if &wgt_prop_var ~= %then %do;
        &wgt_prop_var = 1;
      %end;

    %end;
      
  run;

  %if %mparam_is_yes( &full_diag ) %then %do;
    proc print data=_last_;
      title3 "_tgd_Wgt_merg";
    run;
    title3;
  %end;
  
  %if &wgt_new_geo ~= %then %do;
    proc sort data=_tgd_wgt_merg;
      by &wgt_new_geo;
    run;
  %end;
    
  proc summary data=_tgd_wgt_merg;
    %if ( &dat_count_vars ~= ) or ( &dat_count_moe_vars ~= ) %then %do;
      var &dat_count_vars &dat_count_moe_vars /weight=&wgt_count_var;
    %end;
    %if &dat_prop_vars ~= %then %do;
      var &dat_prop_vars /weight=&wgt_prop_var;
    %end;
    %if &dat_id_vars ~=  or &wgt_id_vars ~=  %then %do;
      id &dat_id_vars &wgt_id_vars;
    %end;
    %if &wgt_new_geo ~= %then %do;
      by &wgt_new_geo;
    %end;
    output 
      %if %length( &calc_vars ) > 0 or %length( &dat_count_moe_vars ) > 0 %then %do;
        out=_tgd_wgt_merg_sum (drop=_type_ _freq_)
      %end;
      %else %do;
        out=&out_ds_name 
          (drop=_type_ _freq_
            %if %length( &out_ds_label ) > 0 %then %do;
              label="&out_ds_label"
            %end;
          )
      %end;
      %if &dat_count_vars ~=  %then %do;
        sum( &dat_count_vars )=
      %end;
      %if &dat_prop_vars ~=  %then %do;
        mean( &dat_prop_vars )=
      %end;
      %if &dat_count_moe_vars ~= %then %do;
        uss( &dat_count_moe_vars )=
      %end;
    ;  
    %if &wgt_new_geo_fmt ~= %then %do;
      format &wgt_new_geo &wgt_new_geo_fmt;
    %end;
    
  run;

  %if %length( &calc_vars ) > 0 or %length( &dat_count_moe_vars ) > 0 %then %do;
  
    data &out_ds_name (
          %if %length( &out_ds_label ) > 0 %then %do;
            label="&out_ds_label"
          %end;
         );

    set _tgd_wgt_merg_sum;
    
    ** Calculated variables **;

    &calc_vars ;

    %if %length( &calc_vars_labels ) > 0 %then %do;
      label &calc_vars_labels;
    %end;
    
    %if &dat_count_moe_vars ~= %then %do;

      ** MOE variables **;
      
      %let i = 1;
      %let v = %scan( &dat_count_moe_vars, &i, %str( ) );

      %do %until ( &v = );

        &v = sqrt( &v );

        %let i = %eval( &i + 1 );
        %let v = %scan( &dat_count_moe_vars, &i, %str( ) );

      %end;
    
    %end;
    
    run;

  %end;

  %if %mparam_is_yes( &full_diag ) %then %do;
    proc print data=&out_ds_name;
      title3 "&out_ds_name";
    run;
    title3;
  %end;

  %if %mparam_is_yes( &print_diag ) and &dat_count_vars ~=  %then %do;
    
    %note_mput( macro=&macro, msg=Running diagnostic on count vars. )
    
    /** Alternate diagnostic **/
    
    proc summary data=&dat_ds_name;
      var &dat_count_vars;
      output out=_tgd_input sum=;
      
    proc summary data=&out_ds_name;
      var &dat_count_vars;
      output out=_tgd_output sum=;
      
    proc compare base=_tgd_input compare=_tgd_output maxprint=(40,32000) nosummary
        method=absolute criterion=&max_diff;
      var &dat_count_vars;
      title3 "*** Transform_geo_data():  Diagnostic";
      title4 "*** Proc Compare should report that ""No unequal values were found,""";
      title5 "*** unless keep_nonmatch=N and there were non-matching obs.";
      title6 "*** BASE is input data set (&dat_ds_name), COMPARE is output data set (&out_ds_name).";
    run;
    
    title3;
    
  %end;
  %else %do;
    %note_mput( macro=&macro, msg=Diagnostic not run because PRINT_DIAG=N or DAT_COUNT_VARS= is empty. )
  %end;
  
  %exit:
  

  %***** ***** ***** CLEAN UP ***** ***** *****;

  proc datasets library=work memtype=(data) nolist nowarn;
    delete _tgd_:;
  quit;

  %pop_option( mprint )
  
  %note_mput( macro=&macro, msg=Macro exiting. )

%mend Transform_geo_data;


/************************ UNCOMMENT TO TEST ***************************

**options mprint symbolgen mlogic;
options mprint;

title 'Transform_geo_data:  DCNIS, Macro Library';

** Autocall macros **;

filename uiautos "K:\Metro\PTatian\UISUG\Uiautos";
options sasautos=(uiautos sasautos);

data Test_wgt;

  length geo_in geo_out alt_id $ 8;

  input geo_in geo_out alt_id wt;
  
  cards;
  A  A1  X  0.40
  A  A2  X  0.60
  B  B1  X  1.00
  C  B1  Y  1.00
  D  D   Y  1.00
  E  E1  Z  0.25
  E  F1  Z  0.75
  F  E1  Z  0.50
  F  F1  Z  0.50
  H  H   Z  1.00
  ;
  
run;

proc print data=Test_wgt;
  title3 "Test_wgt";
run;

data Test_dat;

  length geo_in $ 8;

  input geo_in count1 count2 prop1 ;
  
  cards;
  A 100 1000 20
  B 100 1000 40
  C 100 1000 50
  D 100 1000 60
  E 100 1000 80
  F 100 1000 100
  G 100 1000 10
  ;
  
run;

proc print data=Test_dat;
  title3 "Test_dat";
run;

** Invoke macro to convert count variables count1 and count2 and
** proportion variable prop1 in Test_dat from geographic level 
** geo_in to geo_out.  Weighting file is Test_wgt.
**;

%Transform_geo_data(
    dat_ds_name = Test_dat,
    dat_org_geo = geo_in,
    dat_count_vars = count1 count2,
    dat_prop_vars  = prop1, 
    calc_vars = 
      prop2 = 100 * ( count1 / count2 );
      sum1 = count1 + count2; ,
    calc_vars_labels = 
      prop2 = "100 * ( count1 / count2 )"
      sum1 = "count1 + count2" , 
    wgt_ds_name = Test_wgt,
    wgt_org_geo = geo_in,
    wgt_new_geo = geo_out,
    wgt_id_vars = alt_id,
    wgt_wgt_var = wt,
    wgt_prop_var = wt,
    out_ds_name = Test_out,
    out_ds_label = Transform_geo_data macro test output data set,
    show_warnings = 1,
    keep_nonmatch = Y,
    print_diag = Y,
    full_diag = Y,
    mprint = Y
  )

proc contents data=Test_out;
run;

** Check that macro temporary data sets have been deleted **;
proc datasets library=work memtype=(data);
quit;

/**********************************************************************/
