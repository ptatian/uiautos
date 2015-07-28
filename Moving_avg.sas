/* Moving_avg.sas - UI SAS Macro Library
 *
 * Calculate a moving average for variables of the form xxx_nnn.
 *
 * NB:  Program written for SAS Version 9.1
 *
 * 11/18/06  Peter A. Tatian
 ****************************************************************************/

/** Macro Moving_avg - Start Definition **/

%macro Moving_avg( var, from, to, years, label=, time_unit=year );

  %let time_unit = %lowcase( &time_unit );

  %do i = &from + ( &years - 1 ) %to &to;
    
    %let j = %eval( &i - 2 );
    
    if n( of &var._&j-&var._&i ) = &years then 
      &var._&years.yr_&i = mean( of &var._&j-&var._&i );
    else 
      &var._&years.yr_&i = .;
   
    %if %length( &label ) > 0 %then %do;
      label &var._&years.yr_&i = "&label, 3-&time_unit avg., &i";
    %end;
    
  %end;

%mend Moving_avg;

/** End Macro Definition **/

