/******************* URBAN INSTITUTE MACRO LIBRARY *********************
 
 Macro: Moving_avg

 Description: Calculate a moving average for variables of the form xxx_nnn
 and assign to specified variable. Label variable.
 
 Use: Within data step
 
 Author: Peter Tatian
 
***********************************************************************/

%macro Moving_avg( 
  var,            /** Variable name prefix **/ 
  from,           /** Starting time period **/
  to,             /** Ending time period **/
  years,          /** Number of obs to combine for an average **/ 
  label=,         /** Base label for variable **/
  time_unit=year  /** Label for observation time period **/
  );

  /*************************** USAGE NOTES *****************************
   
   SAMPLE CALL: 
     %Moving_avg( val, 1999, 2002, 3, label=Value )
       creates two variables (val_3yr_2001, val_3yr_2002) with 3-year 
       moving averages of val_1999 through val_2002

  *********************************************************************/

  /*************************** UPDATE NOTES ****************************


  *********************************************************************/

  %***** ***** ***** MACRO SET UP ***** ***** *****;
   
  %local i j;
    
  %let time_unit = %lowcase( &time_unit );

    
  %***** ***** ***** ERROR CHECKS ***** ***** *****;
  
  %if &years =  %then %do;
    %err_mput( macro=Moving_avg, msg=Must provide a value for number of obs to combine (4th parameter). )
    %goto exit;
  %end;

  %if %sysfunc( anyalpha( &years ) ) %then %do;
    %err_mput( macro=Moving_avg, msg=Must provide a numeric value for number of obs to combine (4th parameter): &years.. )
    %goto exit;
  %end;

  %let years = %sysfunc( int( &years ) );

  %if not( &years >= 1 ) %then %do;
    %err_mput( macro=Moving_avg, msg=Number of obs to combine must be 1 or higher: &years.. )
    %goto exit;
  %end;
  
  %if &years > %eval( ( &to - &from ) + 1 ) %then %do;
    %err_mput( macro=Moving_avg, msg=Number of obs to combine must be less than or equal to number of variables: &years > %eval( ( &to - &from ) + 1 ). )
    %goto exit;
  %end;
    
  
  %***** ***** ***** MACRO BODY ***** ***** *****;
  
  %do i = &from + ( &years - 1 ) %to &to;
    
    %let j = %eval( &i - ( &years - 1 ) );
    
    if n( of &var._&j-&var._&i ) = &years then 
      &var._&years.yr_&i = mean( of &var._&j-&var._&i );
    else 
      &var._&years.yr_&i = .;
   
    %if %length( &label ) > 0 %then %do;
      label &var._&years.yr_&i = "&label, &years-&time_unit avg., &i";
    %end;
    
  %end;
  
  %exit:


  %***** ***** ***** CLEAN UP ***** ***** *****;

%mend Moving_avg;


/************************ UNCOMMENT TO TEST ***************************

**options mprint symbolgen mlogic;
options mprint;


data _null_;

  val_1999 = 50;
  val_2000 = 40;
  val_2001 = 30;
  val_2002 = 20;
  
  %Moving_avg( val, 1999, 2002, 3, label=Value )
  
  put (val_:) (=) /;

run;

/**********************************************************************/

