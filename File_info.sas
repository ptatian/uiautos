/************************************************************************
 * Program:  File_info.sas
 * Project:  UI SAS Macro Library
 * Author:   P. Tatian
 * Updated:  8/23/04
 * Version:  SAS 8.12
 * Environment:  Windows or Alpha
 * Use:      Open code
 * 
 * Description:  Autocall macro to print basic information for a
 * data set:  contents, first few obs., and means.
 *
 * Modifications:
 *   10/13/04  Added freqvars option to do frequency tables.
 ************************************************************************/

/** Macro File_info - Start Definition **/

%macro File_info(
  data=,           /* Data set */
  contents=Y,      /* Print Proc Contents (N to suppress) */
  printobs=10,     /* Number of obs. to print (0 to suppress) */
  printchar=N,     /* Print char. vars. only when printing obs. */
  printvars=,      /* List of variables to print (optional) */
  freqvars=,       /* List of variables for frequency tables (optional) */
  stats=n sum mean stddev min max  /* Proc Means statistics (blank to suppress) */
  );

  title2 "File = &data";

  %if %upcase( &contents ) = Y %then %do; 
    proc contents data=&data;
    run;
  %end;

  %if &printobs > 0 %then %do; 
    proc print data=&data (obs=&printobs);
    %if %upcase( &printchar ) = Y %then %do;
      var _char_;
      title3 "Printing first &printobs obs. (char. vars. only)";
    %end;
    %else %if %length( &printvars ) > 0 %then %do;
      var &printvars;
      title3 "Printing first &printobs obs. (selected vars.)";
    %end;
    %else %do;
      title3 "Printing first &printobs obs.";
    %end;
    run;
    title3;
  %end;
  
  %if %length( &stats ) %then %do;
    options nolabel;
    proc means data=&data &stats;
    run;
    options label;
  %end;

  %if %length( &freqvars ) %then %do;
    proc freq data=&data;
      tables &freqvars / missing;
    run;
  %end;

  %exit:

  title2;

%mend File_info;

/** End Macro Definition **/

