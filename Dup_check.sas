/******************* URBAN INSTITUTE MACRO LIBRARY *********************
 
 Macro: Dup_check

 Description: Check data set for duplicate obs. by key variables and 
 print out duplicates.
 
 Use: Open code
 
 Author: Peter Tatian
 
***********************************************************************/

%macro Dup_check( 
  data=,                   /** Input data set **/
  by=,                     /** BY variable list **/
  id=,                     /** ID variables to include in list of duplicate obs. **/
  out=_dup_check,          /** Output data set containing duplicate obs. (def. _DUP_CHECK is deleted at end of macro execution) **/
  listdups=Y,              /** Print list of duplicate obs. to output (Y/N) **/
  printnumdups=Y,          /** Show number of duplicate obs. for each BY group (Y/N) **/
  count=dup_check_count,   /** Name of macro variable where no. of duplicate obs. will be saved **/
  quiet=N,                 /** Suppress printing of final duplicate count to LOG (Y/N) **/
  debug=N                  /** Debug mode (MPRINT on) (Y/N) **/
);

  /*************************** USAGE NOTES *****************************
   
   SAMPLE CALL: 
     %dup_check( data=test, by=byvar1 byvar2, id=firstname lastname )     
       prints observations in test that have same values of byvar1 and 
       byvar2

  *********************************************************************/

  /*************************** UPDATE NOTES ****************************


  *********************************************************************/

  %***** ***** ***** MACRO SET UP ***** ***** *****;
   
  %local by_data id_data by_freq i item1 item2 itme3 coalesce where_cond;

  %push_option( mprint, quiet=y )
  
  %if %mparam_is_yes( &debug ) %then %do;
    options mprint;
  %end;
  %else %do;
    options nomprint;
  %end;

    
  %***** ***** ***** ERROR CHECKS ***** ***** *****;

  %if %length( &data ) = 0 %then %do;
    %err_mput( macro=Dup_check, msg=You must provide a data set specification in the DATA= option.  Macro exiting. )
    %note_mput( macro=Dup_check, msg=Macro exiting. )
    %goto exit;
  %end;

  %if &by = %then %do;
    %err_mput( macro=Dup_check, msg=You must provide one or more BY variables in the BY= option. )
    %note_mput( macro=Dup_check, msg=Macro exiting. )
    %goto exit;
  %end;


  %***** ***** ***** MACRO BODY ***** ***** *****;

  %** Create comma-separated variable lists **;

  %let by_data = %ListChangeDelim( &by, prefix=data., quiet=y );
  %let id_data = %ListChangeDelim( &id, prefix=data., quiet=y );
  %let by_freq = %ListChangeDelim( &by, prefix=freq., quiet=y );
  
  %** Create coalesce() lists and where condition for join **;
  
  %let i = 1;
  %let item1 = %scan( &by_data, &i, %str(,) );
  %let item2 = %scan( &by_freq, &i, %str(,) );
  %let item3 = %scan( &by, &i, %str( ) );
  %let coalesce = ;
  %let where_cond = ;

  %do %while ( %length( &item1 ) > 0 );
  
    %let coalesce = &coalesce coalesce( &item1, &item2 ) as &item3;
    %let where_cond = &where_cond &item1 = &item2;
    
    %let i = %eval( &i + 1 );
    %let item1 = %scan( &by_data, &i, %str(,) );
    %let item2 = %scan( &by_freq, &i, %str(,) );
    %let item3 = %scan( &by, &i, %str( ) );
    
    %if &item1 ~= %then %let where_cond = &where_cond and;
    %if &item1 ~= %then %let coalesce = &coalesce,;

  %end;
  
  %** Find duplicate obs. **;
  
  proc sql;
    create table &out as
    select &coalesce, 
      %if &id_data ~= %then %do;
        &id_data, 
      %end;
      freq._freq_ from 
      &data as data, 
      (
        select &by_data, count(*) as _freq_ from
        &data as data
        group by &by_data
      ) as freq
    where ( &where_cond ) and freq._freq_ > 1
    order by &by_data
      %if &id_data ~= %then %do;
        , &id_data
      %end;
    ;

  %** Count no. of duplicate obs. **;
  
  proc sql noprint;
    select count(*) into :_dup_check_count
    from &out;
  quit;
  
  %if &count ~= %then %do;
    %global &count;
    %let &count = &_dup_check_count;
  %end;
  
  %** Report findings to log (if requested) **;
  
  %if %mparam_is_no( &quiet ) %then %do;
    %note_mput( macro=Dup_check, msg=&_dup_check_count duplicate observations found in data set %upcase(&data) )
    %note_mput( macro=Dup_check, msg=for BY variables %upcase(&by). )
  %end;

  %** Print duplicate obs. (if requested) **;

  %if %mparam_is_yes( &listdups ) %then %do;

    proc print data=&out noobs 
      %if %mparam_is_yes( &printnumdups ) %then %do;
        n='Number of duplicates = '
      %end;
      ;
      id &by;
      by &by;
      var &id;
    run;
    
  %end;
  
  
  %***** ***** ***** CLEAN UP ***** ***** *****;

  %** Clean up temporary data set **;
  
  %if &out = _dup_check %then %do;
  
    proc datasets library=work nolist nowarn;
      delete _dup_check /memtype=data;
    quit;

  %end;
  
  %pop_option( mprint, quiet=y )

  %exit:
    
%mend Dup_check;


/************************ UNCOMMENT TO TEST ***************************

title "Dup_check:  UI SAS Autocall Macro Library";

filename uiautos "K:\Metro\PTatian\UISUG\Uiautos";
options sasautos=(uiautos sasautos);

options nocenter;
options mprint nosymbolgen nomlogic;
options msglevel=i;

data test;

  length firstname lastname $ 12;

  input byvar1 byvar2 firstname lastname;

datalines;
1 1 Albert Arbor
1 2 Barbara Bouche
1 3 Chelsea Ciel
1 4 Dagmar Desire
1 5 Euripides Erudite
1 1 Alberta Amie
1 3 Constantine Clochard
1 4 Dagy Deauville
1 3 Cedille Cellule
;

run;

proc print data=test;

%dup_check(  )

%dup_check( data=test )

%dup_check( data=test, by=byvar1 byvar2, id=firstname lastname, debug=y )

%put dup_check_count=&dup_check_count;

/**********************************************************************/
