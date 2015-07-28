/**************************** DOLLAR_CONVERT ***************************

 Macro Name: Dollar_convert.sas

 Description: Converts dollars using CPI.
 Use Category: Within data step

 Author: Peter Tatian

 Date of approval: 04/02/2012
 Approvers: Amos Budde
 SAS Version: 9.1

/**************************** USAGE NOTES ***************************
 
 Two CPI series are allowed:
   U.S. All items, 1982-84=100 - CUUR0000SA0 (default)
   U.S. All items less shelter, 1982-84=100 - CUUR0000SA0L2 
 
 The mprint option no longer does anything, but it exists as a parameter so programs using it do not break. 
 
 SAMPLE CALL: See testing section below.
 
/************************* UPDATE NOTES ******************************

 TO UPDATE DATA, go to: http://data.bls.gov/pdq/querytool.jsp?survey=cu
   1) Area: US city average
   2) Items: All items (series=CUUR0000SA0)
             All items less shelter (series=CUUR0000SA0L2)
   3) Not Seasonally Adjusted
   
 When adding data for a new year, be sure to add a new 
 CPI_ macro variable for that year to the %local declaration list
 and update the value of MAX_YEAR. 

/****************************** CAUTIONS *****************************
 Dollar_Convert uses both positional and definitional parameters. Be careful that 
 the the order is correct for the first 4 parameters. 

 Series must equal exactly CUUR0000SA0 or CUUR0000SA0L2

 SUBMACROS CALLED: err_mput, note_mput, datatyp (sas autocall macro)

/************************EDITING HISTORY *************************************   
   07/28/05  Created Peter A. Tatian
   10/19/05  Expanded CUUR0000SA0 back to 1980.
  Added MPRINT= option.
   04/03/06  Updated 2005 CPI to full year.  Added 2006 (Jan & Feb only).
   08/07/06  Updated 2006 CPI to half year.
   12/31/06  Changed earliest year to 1979.
   01/30/06  Updated 2006 CPI to full year.
   08/27/07  Updated 2007 CPI to half year.
   01/29/08  Updated 2007 CPI to full year.
   02/02/09  Updated 2008 CPI to full year.
   07/06/09  Updated 2009 CPI to Jan-May average.
   09/02/09  Updated 2009 CPI to half year.
  Added series CUUR0000SA0L2 (All items less shelter).
   03/02/10  Updated 2009 to full year.
   05/20/10  Updated 2010 avg first 4 months.
   09/29/10  Updated 2010 to half year.
   02/17/11  LH  Updated 2010 to full year.
   02/23/11  PAT Added declaration for local macro vars.
   05/09/11  PAT Updated 2011 first 3 months.
   09/26/11  PAT Updated 2011 to half year.
   05/04/12  GM  Updated 2011 to full year, added 2012 Jan-Mar average.
   01/03/13	 SL Updated 2012 to half year.
   07/11/13  GM Updated 2012 to full year.
   02/3/14   BL Updated 2013 to full year.
   07/01/14  RP Updated 2014 to half year
 ****************************************************************************/

/************************ MACRO AND PARAMETERS ************************/

%macro Dollar_convert( 
    amount1,            /* variable with original dollar amount */
    amount2,            /* variable to put converted dollar amount */
    from,               /* year of amount1 */
    to,                 /* year of amount2 */
    series=CUUR0000SA0, /* CPI series to use. Default is CUUR0000SA0. The other option is CUUR0000SA0L2 */
    quiet=Y,            /* suppresses notes to the log (Y/N) */
    mprint=N            /* control MPRINT= option (Y/N) [currently inactive] */
    );

  %***** ***** ***** SET UP ***** ***** *****;
 
  %local _i MIN_YEAR MAX_YEAR _dcnv_array;
  
  %local
    CPI_1979 CPI_1980 CPI_1981 CPI_1982 CPI_1983 CPI_1984
    CPI_1985 CPI_1986 CPI_1987 CPI_1988 CPI_1989 CPI_1990
    CPI_1991 CPI_1992 CPI_1993 CPI_1994 CPI_1995 CPI_1996
    CPI_1997 CPI_1998 CPI_1999 CPI_2000 CPI_2001 CPI_2002
    CPI_2003 CPI_2004 CPI_2005 CPI_2006 CPI_2007 CPI_2008
    CPI_2009 CPI_2010 CPI_2011 CPI_2012 CPI_2013 CPI_2014;

  %global _dcnv_count;

  %***** ***** ***** ERROR CHECKS ***** ***** *****;

  %** Error checks are already embedded into the macro. We will leave them there to not  
      break programs that rely on the current version (AB - 1/2/12) **;

  %***** ***** ***** BODY ***** ***** *****;
  %let MIN_YEAR = 1979;
  %let MAX_YEAR = 2014;

  %let series = %upcase( &series );

  %if &series = CUUR0000SA0 %then %do;
    %************************************************** 
        Consumer Price Index - All Urban Consumers
        Series Id:    CUUR0000SA0
        Not Seasonally Adjusted
        Area:         U.S. city average
        Item:         All items
        Base Period:  1982-84=100
    ***************************************************;
    %let CPI_1979 = 72.6;
    %let CPI_1980 = 82.4;
    %let CPI_1981 = 90.9;
    %let CPI_1982 = 96.5;
    %let CPI_1983 = 99.6;
    %let CPI_1984 = 103.9;
    %let CPI_1985 = 107.6;
    %let CPI_1986 = 109.6;
    %let CPI_1987 = 113.6;
    %let CPI_1988 = 118.3;
    %let CPI_1989 = 124.0;
    %let CPI_1990 = 130.7;
    %let CPI_1991 = 136.2;
    %let CPI_1992 = 140.3;
    %let CPI_1993 = 144.5;
    %let CPI_1994 = 148.2;
    %let CPI_1995 = 152.4;
    %let CPI_1996 = 156.9;
    %let CPI_1997 = 160.5;
    %let CPI_1998 = 163.0;
    %let CPI_1999 = 166.6;
    %let CPI_2000 = 172.2;
    %let CPI_2001 = 177.1;
    %let CPI_2002 = 179.9;
    %let CPI_2003 = 184.0;
    %let CPI_2004 = 188.9;
    %let CPI_2005 = 195.3;   
    %let CPI_2006 = 201.6;   %** Full year 2006 **;
    %let CPI_2007 = 207.342;  %** Full year 2007 **;
    %let CPI_2008 = 215.303;  %** Full year 2008 **;
    %let CPI_2009 = 214.537;  %** Full year 2009 **;
    %let CPI_2010 = 218.056;  %** Full year 2010 **;
    %let CPI_2011 = 224.939;  %** Full year 2011 **;
	%let CPI_2012 = 229.594;  %** Full year 2012 **;
	%let CPI_2013 = 232.957;  %** Full year 2013 **;
	%let CPI_2014 = 235.99;   %** Half year 2014 **;
  %end;
  %else %if &series = CUUR0000SA0L2 %then %do;
    %************************************************** 
        Consumer Price Index - All Urban Consumers
        Series Id:    CUUR0000SA0L2
        Not Seasonally Adjusted
        Area:         U.S. city average
        Item:         All items less shelter
        Base Period:  1982-84=100
    ***************************************************;
    %let CPI_1979 = 74.2;
    %let CPI_1980 = 82.9;
    %let CPI_1981 = 91;
    %let CPI_1982 = 96.2;
    %let CPI_1983 = 99.8;
    %let CPI_1984 = 103.9;
    %let CPI_1985 = 107;
    %let CPI_1986 = 108;
    %let CPI_1987 = 111.6;
    %let CPI_1988 = 115.9;
    %let CPI_1989 = 121.6;
    %let CPI_1990 = 128.2;
    %let CPI_1991 = 133.5;
    %let CPI_1992 = 137.3;
    %let CPI_1993 = 141.4;
    %let CPI_1994 = 144.8;
    %let CPI_1995 = 148.6;
    %let CPI_1996 = 152.8;
    %let CPI_1997 = 155.9;
    %let CPI_1998 = 157.2;
    %let CPI_1999 = 160.2;
    %let CPI_2000 = 165.7;
    %let CPI_2001 = 169.7;
    %let CPI_2002 = 170.8;
    %let CPI_2003 = 174.6;
    %let CPI_2004 = 179.3;
    %let CPI_2005 = 186.1;
    %let CPI_2006 = 191.9;
    %let CPI_2007 = 196.639;
    %let CPI_2008 = 205.453;
    %let CPI_2009 = 203.301;  %** Full year 2009 **;
    %let CPI_2010 = 208.643;  %** Full year 2010 **;
    %let CPI_2011 = 217.048;  %** Full year 2011 **;
	%let CPI_2012 = 221.446;  %** Full year 2012 **;
	%let CPI_2013 = 223.820;  %** Full year 2013 **;
	%let CPI_2014 = 226.038;  %** Half year 2014 **;
  %end;
  %else %do;
    %err_mput( macro=Dollar_convert, msg=Invalid SERIES= value: &series )
    %goto exit_macro;
  %end;
  
  %if &_dcnv_count = %then %let _dcnv_count = 1;
  %else %let _dcnv_count = %eval( &_dcnv_count + 1 );
  
  %let _dcnv_array = _dcnv&_dcnv_count;

  array &_dcnv_array{&MIN_YEAR:&MAX_YEAR} _temporary_ 
    ( 
      %do _i = &MIN_YEAR %to &MAX_YEAR;
        &&&CPI_&_i 
      %end;
    );
  
  %let Result = (&amount1) * (&_dcnv_array{&to}/&_dcnv_array{&from});
  
  if (&from) < &MIN_YEAR or (&from) > &MAX_YEAR then do;
    %if %datatyp(&from) = NUMERIC %then %do;
      %err_put( macro=Dollar_convert, msg=_n_= "Invalid year FROM=&from..  Only years &MIN_YEAR-&MAX_YEAR supported." )
    %end;
    %else %do;
      %err_put( macro=Dollar_convert, msg=_n_= "Invalid year FROM=" &from ". Only years &MIN_YEAR-&MAX_YEAR supported." )
    %end;
  end;
  else if (&to) < &MIN_YEAR or (&to) > &MAX_YEAR then do;
    %if %datatyp(&to) = NUMERIC %then %do;
      %err_put( macro=Dollar_convert, msg=_n_= "Invalid year TO=&to..  Only years &MIN_YEAR-&MAX_YEAR supported." )
    %end;
    %else %do;
      %err_put( macro=Dollar_convert, msg=_n_= "Invalid year TO=" &to ". Only years &MIN_YEAR-&MAX_YEAR supported." )
    %end;
  end;
  else do;
    &amount2 = (&result);
  end;

  %exit_macro:
  
  %if %upcase( &quiet ) = N %then %do;
    %note_mput( macro=Dollar_convert, msg=Result=&result )
  %end;

  %***** ***** ***** CLEAN UP ***** ***** *****;

    %** No cleanup needed **;

%mend Dollar_convert;

/** END MACRO DEFINITION **/


/************ UNCOMMENT TO TEST ****************************

filename macrodev "D:\Projects\UISUG\MacroDev";

filename uiautos "K:\Metro\ABudde\SAS Macro Lib\Macros";
options sasautos=(macrodev uiautos sasautos);
options mprint nosymbolgen nomlogic;
options msglevel=i;

%let last_year = 2012;

%let i = 12345;
%let _i = 67890;

%put BEFORE DATA STEP: i=&i _i=&_i;

** Numeric value test **;

data _null_;

  %dollar_convert( 100, amount2, 1980, &last_year, quiet=N, series=CUUR0000SA0L2 );
  put amount2=;

  %dollar_convert( 100, amount2, &last_year, 1980, quiet=N, series=CUUR0000SA0L2 );
  put amount2=;
  
  %dollar_convert( 100, amount2, 1994, &last_year, quiet=N, series=CUUR0000SA0L2 );
  put amount2=;
  
  %dollar_convert( 100, amount2, 1995, &last_year, quiet=N, series=CUUR0000SA0L2 );
  put amount2=;
  
  %dollar_convert( 100, amount2, 2000, &last_year, quiet=N, series=CUUR0000SA0L2 );
  put amount2=;
  
  %dollar_convert( 100, amount2, &last_year, 1995, quiet=N, series=CUUR0000SA0L2 );
  put amount2=;
  
  %dollar_convert( 100, amount2, 1995, 2020, quiet=N, series=CUUR0000SA0L2 );
  put amount2=;

run;

%put AFTER DATA STEP: i=&i _i=&_i;

** Numeric variable test **;

data _null_;

  input amount from to ;

  %dollar_convert( amount, amount2, from, to, quiet=N, series=CUUR0000SA0L2 );
  put amount2= amount= from= to=;

cards;
100 1980 2012
100 2012 1980
100 1994 2012
100 1995 2012
100 2000 2012
100 2012 1995
100 1995 2020
;
  
run;

** Create new variables test **;

data input;
  input amount;
cards;
100
105
110
115
120
125
130
;
run;

data test;
	set input;
	%dollar_convert( amount, year2000 , 1980, 2000, quiet=N, series=CUUR0000SA0L2 );
	%dollar_convert( amount, year2010 , 1980, 2010, quiet=N, series=CUUR0000SA0L2 );
run;

proc print data=test; run;

/*****************************************************************/

