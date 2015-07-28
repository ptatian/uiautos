/* Data_check_prt.sas - SAS Macro
 *
 * Autocall macro to print results from Data_check macro.  
 *
 * NB:  Program written for SAS Version 8.2
 *
 * 06/10/03  Peter A. Tatian
 ****************************************************************************/

/** Macro DATA_CHECK_PRT - Start Definition **/

%macro Data_check_prt( in_ds=, rule_num=, id_var=, left_exp=, right_exp=, obs=1000000000 );

  data;
    set &in_ds;
    where dck_flg&rule_num;
    _dcp_left = &left_exp;
    _dcp_right = &right_exp;
    _dcp_diff =  _dcp_left - _dcp_right;
    
    label
      _dcp_left = "&left_exp"
      _dcp_right = "&right_exp"
      _dcp_diff = "Difference - Rule #&rule_num";
    
    keep &id_var dck_flg&rule_num _dcp_: ;
    
  run;

  proc univariate plot;
    %if %length( &id_var ) > 0 %then %do; 
      id &id_var;
    %end;
    var _dcp_diff;
  run;

  %print_obs_where(
    data = _last_,
    id = &id_var,
    print_options = noobs label,
    obs = &obs,
    where = dck_flg&rule_num,
    var = _dcp_diff _dcp_left _dcp_right,
    by = dck_flg&rule_num
  )

%mend Data_check_prt;

/** End Macro Definition **/


/***** UNCOMMENT TO TEST MACRO *****

title "Data_check_prt:  SAS Macro";

** Autocall macros **;

filename uiautos "K:\Metro\PTatian\UISUG\Uiautos";
filename ncdbmac "D:\Data\NCDB2000\Prog\Macros";
options sasautos=(ncdbmac uiautos sasautos);

options mprint nosymbolgen nomlogic;

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
             rule_list= a>b !
                        b>a !
                        a=b 
            )

%data_check_prt( in_ds=Test_out,
                 id_var=id,
                 rule_num=1,
                 left_exp=a,
                 right_exp=b 
                )


/***** END MACRO TEST *****/
