/************************************************************************
 * Program:  Concat_lib.sas
 * Project:  UI SAS Macro Library
 * Author:   P. Tatian
 * Updated:  9/17/04
 * Version:  SAS 8.12
 * 
 * Description:  Define a concatenated V8 & V6 SAS library
 *
 * Modifications:
 *  04/12/06  Remove LONGFILEEXT option from libname statement because
 *            not supported in SAS V9.
 ************************************************************************/

/** Macro Concat_lib - Start Definition **/

%macro Concat_lib( libname, path );

  %if %length( &libname ) > 6 %then %do;
    %let prename = %substr( &libname, 1, 6 );
  %end;
  %else %do;
    %let prename = &libname;
  %end;

  libname &prename.v6 v6 "&path";

  %if &SYSSCP = WIN %then %do;
    libname &prename.v8 v8 "&path" /*longfileext*/;
  %end;
  %else %do;
    libname &prename.v8 v8 "&path";
  %end;
  
  libname &libname (&prename.v8 &prename.v6);

%mend Concat_lib;

/** End Macro Definition **/

