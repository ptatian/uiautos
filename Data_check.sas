/* Data_check.sas - SAS Macro
 *
 * Autocall macro to apply a series of data checking rules to all of
 * the observations in a data set.  Observations violating the
 * conditions are indicated in the indicated report file.
 *
 * NB:  Program written for SAS Version 8.2
 *
 * 05/21/03  Peter A. Tatian
 * 11/20/03  Added threshold options min_num_viol= and min_pct_viol= 
             for limiting violations listed in summary report.  PAT
 * 12/22/03  Added detail_rpt_max= option to limit total number of obs.
 *           listed in detail report.  Default value 0 lists all obs. PAT
   02/23/11  PAT  Added declaration for local macro vars.
 ****************************************************************************/

/** Macro DATA_CHECK - Start Definition **/

%macro Data_check( in_ds=, out_ds=, rule_list=, id_vars=, rpt_out=, detail_rpt=Y,
                   detail_rpt_max=0, min_num_viol=0, min_pct_viol=0 );

  %local delim i rule count;

  %let delim = !;

  %* Count rules;

  %let i = 1;
  %let rule = %scan( &rule_list, &i, &delim );
    
  %do %while( %length( &rule ) > 0 );
    %let i = %eval( &i + 1 );
    %let rule = %scan( &rule_list, &i, &delim );
  %end;

  %let count = %eval( &i - 1 );

  %if %length( &out_ds ) > 0 %then %do;
    data &out_ds (drop=sum_dck_flg: dck_first_viol dck_pct_viol 
                       dck_max_viol dck_no_viol dck_1m_viol);
  %end;
  %else %do;
    data _null_;
  %end;
  
    %if %length( &rpt_out ) > 0 %then %do;
      file "&rpt_out";
    %end;

    set &in_ds end=dck_last_obs;
    
    length dck_flg_total 8 dck_flg1-dck_flg&count 3;
    retain dck_max_viol dck_no_viol dck_1m_viol 
           sum_dck_flg1-sum_dck_flg&count 0;

    ** Write report header **;

    if _n_ = 1 then do;
    
      put /"******************************" /
           "*****  DATA_CHECK MACRO  *****" /
           "******************************";

      put / "DATA SET:  %upcase( &in_ds )";

      %if %upcase( &detail_rpt ) = Y %then %do;
        put / "*****  DETAILED REPORT  *****";
      %end;

    end;

    ** Check all rules **;

    dck_first_viol = 1;

    %let i = 1;
    %let rule = %scan( &rule_list, &i, &delim );
    
    %do %while( %length( &rule ) > 0 );

      if not(&rule) then do;
        %if %upcase( &detail_rpt ) = Y %then %do;
          if &detail_rpt_max = 0 or _n_ <= &detail_rpt_max then do;
            if dck_first_viol then do;
              put / "DATA_CHECK: " %put_var_list( _n_ &id_vars ) ;
              dck_first_viol = 0;
            end;
            put "  VIOLATES RULE #&i:  %upcase( &rule )";
          end;
        %end;
        dck_flg&i = 1;
        sum_dck_flg&i + 1;
      end;
      else do;
        dck_flg&i = 0;
      end;
      
      %let i = %eval( &i + 1 );
      %let rule = %scan( &rule_list, &i, &delim );
    
    %end;

    ** If detail report limit reached, print warning message **;
    
    if _n_ = &detail_rpt_max then do;
      put / "MAXIMUM OBS. LIMIT REACHED FOR DETAILED REPORT (DETAIL_RPT_MAX=&detail_rpt_max)";
      put "NO FURTHER OBS. WILL BE PRINTED.";
    end;
    
    ** Update violation counts **;

    dck_flg_total = sum( of dck_flg1-dck_flg&count );
    dck_max_viol = max( dck_max_viol, dck_flg_total );
    
    if dck_flg_total = 0 then
      dck_no_viol + 1;
    else 
      dck_1m_viol + 1;
    
    ** Print summary report when last obs. reached **;
    
    if dck_last_obs then do;
    
      put // "*****  SUMMARY REPORT  *****";
      put /  "OBS. CHECKED:                    " _n_ comma12.;
      put    "OBS. WITH NO VIOLATIONS:         " dck_no_viol comma12.;
      put    "OBS. WITH 1 OR MORE VIOLATIONS:  " dck_1m_viol comma12.;
      put /  "MAXIMUM VIOLATIONS PER OBS.:     " dck_max_viol comma12.;
      
      if &min_num_viol > 0 or &min_pct_viol > 0 then 
        put / "ONLY RULES WITH >= &min_num_viol OBS. AND >= "
              "&min_pct_viol.% OBS. WITH VIOLATIONS WILL BE SHOWN.";
    
      %let i = 1;
      %let rule = %scan( &rule_list, &i, &delim );
        
      %do %while( %length( &rule ) > 0 );

        dck_pct_viol = sum_dck_flg&i / _n_;
        
        if sum_dck_flg&i >= &min_num_viol and 100 * dck_pct_viol >= &min_pct_viol then do;

          put / "RULE #&i:  %upcase( &rule )";
          if sum_dck_flg&i > 0 then
            put "VIOLATIONS:  " sum_dck_flg&i comma12. "  (" dck_pct_viol percent9.2 ")";
          else
            put "NO VIOLATIONS";
            
        end;
        
        %let i = %eval( &i + 1 );
        %let rule = %scan( &rule_list, &i, &delim );

      %end;
      
      put / "*****  REPORT RUN ON %upcase( %sysfunc(date(),worddate.) ) *****" /;
      
    end;

    ** Label flag variables **;

    label 
    
      dck_flg_total = "Total violations"
    
      %let i = 1;
      %let rule = %scan( &rule_list, &i, &delim );
        
      %do %while( %length( &rule ) > 0 );

        dck_flg&i = "%nrquote(&rule)"
        
        %let i = %eval( &i + 1 );
        %let rule = %scan( &rule_list, &i, &delim );

      %end;

    ;
    
  run;

%mend Data_check;

/** End Macro Definition **/


/***** UNCOMMENT TO TEST MACRO *****

title "Data_check:  SAS Macro";

** Autocall macros **;

filename uiautos "K:\Metro\PTatian\UISUG\Uiautos";
filename ncdbmac "D:\Data\NCDB2000\Prog\Macros";
options sasautos=(ncdbmac uiautos sasautos);

options mprint symbolgen mlogic;

data Test;

  input id a b;
  
  cards;
  1 1 0
  2 1 1
  3 0 1
  4 0 0
  ;

run;

%data_check( in_ds=Test, 
             out_ds=Test_out,
             id_vars=id a b,
             rpt_out=D:\Data\NCDB2000\Prog\Macros\Data_check_out.txt, 
             detail_rpt=Y,
             detail_rpt_max=0,
             min_num_viol=2,
             rule_list= a>b !
                        b>a !
                        a=b 
            )

proc print data=Test_out label;
  title2 "File = Test_out";
run;

/***** END MACRO TEST *****/
