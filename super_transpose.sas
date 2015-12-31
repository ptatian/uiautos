/******************* URBAN INSTITUTE MACRO LIBRARY *********************
 
 Macro: Super_transpose

 Description: Autocall macro that performs transpose on a series of vars in a
 data set and combines results together into a single file.
 
 Use: Open code
 
 Author: Peter Tatian
 
***********************************************************************/

%macro Super_transpose(  
  data= ,     /** Input data set **/
  out= ,      /** Output data set **/
  var= ,      /** List of variables to transpose **/
  id= ,       /** Input data set var. to use for transposing **/
  by= ,       /** List of BY variables (opt.) **/
  mprint=N    /** Print macro code to LOG (Y/N) **/
);

  /*************************** USAGE NOTES *****************************
   
   SAMPLE CALL: 
     %Super_transpose(
       data=Test,
       out=Test_res,
       id=idvar,
       by=byvar,
       var=var1 var2
     )
    transposes data set Test variables var1 and var2 using idvar
    to define variable names and byvar to define observations.
    result is saved to data set Test_res.


  *********************************************************************/

  /*************************** UPDATE NOTES ****************************

   06/24/06  Peter A. Tatian
   02/23/11  PAT  Added declaration for local macro vars.

  *********************************************************************/

  %***** ***** ***** MACRO SET UP ***** ***** *****;
   
  %local i tvar files j val;
  
    
  %***** ***** ***** ERROR CHECKS ***** ***** *****;



  %***** ***** ***** MACRO BODY ***** ***** *****;
  
  %Note_mput( macro=Super_transpose, msg=Macro starting. )

  %** Save current MPRINT setting and reset based on MPRINT= parameter **;

  %Push_option( mprint )

  %if %mparam_is_yes( &mprint ) %then %do;
    options mprint;
  %end;
  %else %do;
    options nomprint;
  %end;

  %** Check input parameters **;
  
  %if &var = %then %do;
    %Err_mput( macro=Super_transpose, msg=Parameter VAR= cannot be blank. )
    %goto exit;
  %end;
  
  %** Begin main macro **;

  %** Get list of ID values for label creation **;

  proc summary data=&data nway;
    class &id;
    output out=_st_idvals (drop=_type_ _freq_ compress=no);

  data _null_;
    length idvals $ 5000;
    retain idvals "";
    set _st_idvals end=eof;
    idvals = trim( idvals ) || " " || left( &id );
    if eof then call symput( "idvals", idvals );
  run;

  %put idvals=&idvals;

  %** Create individual transposed files for each variable **;
  
  %let i = 1;
  %let tvar = %scan( &var, &i );
  %let files = ;

  %do %until ( &tvar = );

      ** Get variable label **;

      data _null_;
        set &data (obs=1 keep=&tvar);
        call symput( "&tvar._lbl", vlabel( &tvar ) );
      run;

    ** Transpose &tvar **;
  
    proc transpose data=&data 
        out=_st_&tvar (keep=&by &tvar._: )
        prefix=&tvar._;
      var &tvar;
      id &id;
      %if &by ~= %then %do;
        by &by;
      %end;
    run;
    
    %let files = &files _st_&tvar;
    
    %let i = %eval( &i + 1 );
    %let tvar = %scan( &var, &i );
     
  %end;
  
  ** Combine transposed files **;
  
  data &out;
  
    merge &files;
    %if &by ~= %then %do;
      by &by;
    %end;

    ** Label variables **;

    %let i = 1;
    %let tvar = %scan( &var, &i );

    %do %until ( &tvar = );

      %**%put tvar_lbl=&tvar_lbl;
  
      %let j = 1;
      %let val = %scan( &idvals, &j );

      label

      %do %until ( &val =  );

        &tvar._&val = "&&&tvar._lbl, &val"
    
        %let j = %eval( &j + 1 );
        %let val = %scan( &idvals, &j );

      %end;
  
      ;

      %let i = %eval( &i + 1 );
      %let tvar = %scan( &var, &i );

    %end;
    
  run;
  
  %** Exit macro **;
  
  %exit:


  %***** ***** ***** CLEAN UP ***** ***** *****;

  %** Restore system options **;

  %Pop_option( mprint )


  %Note_mput( macro=Super_transpose, msg=Macro exiting. )

%mend Super_transpose;



/************************ UNCOMMENT TO TEST ***************************

options nocenter;

** Locations of SAS autocall macro libraries **;

filename uiautos  "K:\Metro\PTatian\UISUG\Uiautos";
options sasautos=(uiautos sasautos);

data Test;

  input byvar $ idvar var1 var2 $;

  label 
    byvar = 'By variable'
    idvar = 'ID variable'
    var1 = 'Variable #1'
    var2 = 'Variable #2';
  
datalines;
A 1 11 12
A 2 21 22
A 3 31 32
A 4 41 42
B 1 11 12
B 2 21 22
B 4 41 42
C 1 11 12
C 2 21 22
;

run;

%File_info( data=Test, stats=, printobs=10 );

%Super_transpose(
  data=Test,
  out=Test_res,
  id=idvar,
  by=byvar,
  var=var1 var2,
  mprint=y
)

%File_info( data=Test_res, stats=, printobs=10  )

/**********************************************************************/
