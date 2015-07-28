/**************************************************************************
 Program:  Concat_lr_lib.sas
 Library:  UI SAS Macro Library
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  11/02/13
 Version:  SAS 9.1
 Environment:  Windows
 
 Description:  Define concatenated local/remote/confidential SAS library.
 
 Note: 
   Local and remote library base names must be shortened to 6 chars to 
   allow _r and _l suffixes. Can't define two different libraries that
   have same first 6 chars in name. 

 Modifications:
**************************************************************************/

/** Macro Concat_lr_lib - Start Definition **/

%macro Concat_lr_lib( 
  libname=,  /** Name of concatenated library **/
  rpath=,    /** Remote session library path **/
  lpath=,    /** Local session library path **/
  cpath=,    /** Confidential library path (opt.) **/
  first=l,   /** Local/Remote library first [Conf library always first] (L/R) **/
  engine=    /** SAS data engine (opt.) **/
  );

  %local prename;

  %if %length( &libname ) > 6 %then %do;
    %let prename = %substr( &libname, 1, 6 );
  %end;
  %else %do;
    %let prename = &libname;
  %end;

  libname &prename._l &engine "&lpath";

  libname &prename._r &engine "&rpath";
  
  %if &cpath ~= %then %do;

    libname &prename._c &engine "&cpath";
    
    %if %upcase( &first ) = R %then %do;
      libname &libname (&prename._c &prename._r &prename._l);
    %end;
    %else %do;
      libname &libname (&prename._c &prename._l &prename._r);
    %end;
    
  %end;
  %else %do;
    
    %if %upcase( &first ) = R %then %do;
      libname &libname (&prename._r &prename._l);
    %end;
    %else %do;
      libname &libname (&prename._l &prename._r);
    %end;
    
  %end;

%mend Concat_lr_lib;

/** End Macro Definition **/
