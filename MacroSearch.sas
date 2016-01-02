/******************* URBAN INSTITUTE MACRO LIBRARY *********************
 
 Macro: MacroSearch

 Description: Autocall macro to manage multiple SAS macro libraries.
 Adapted from FmtSearch by Pete Lund.
 
 Use: Open code
 
 Author: Peter Tatian
 
***********************************************************************/

%macro MacroSearch(
  Action=M,     /* Action:
                    B = Add to beginning of search list
                    M = Add to middle (def.), i.e., after existing 
                        libraries but before the libraries in &Def
                    E = Add to end
                    D = Delete from search list
                    X = Reset search list to &Def
                    L = Display current search list (no changes)
                */
  A=,           /* Alternate name for Action= */
  Cat=,         /* Macro library filename */
  C=,           /* Alternate name for Cat= */
  Status=Y,     /* Display status after changes (def. Y) */
  Def=SASAUTOS  /* Default libraries, only used with Action=M or X 
                   (def. SASAUTOS) */
  );
  
  /*************************** USAGE NOTES *****************************
   
   SAMPLE CALL: 
     %MacroSearch( cat=Test, action=E )
       adds Test to end of autocall macro library search

    macro variables/parameters
      Cat (C):    name of the macro library filename
      Action (A): What do you want to do with the library filename:
         B = put it at the beginning of the format search list,
             even before default libraries
         E = put it at the end of the library search list
         D = remove it from the library search list
         M = put it in the "middle" of the library search list.  It
             will go after default libraries and before
             any user-defined libraries in the search list.
         L = simply lists the current macro library search list

  *********************************************************************/

  /*************************** UPDATE NOTES ****************************

   11/02/13 PAT Used compbl() on _NEWFMS before checking for pos of DEF.

  *********************************************************************/

  %***** ***** ***** MACRO SET UP ***** ***** *****;
   
  %local _FMS i pos _ThisCat _Index1 _Index2 _ByVal NumCats;
  %local _NewFMS;
    
  %if &C ne %str() %then %let Cat = &C;
  %if &A ne %str() %then %let Action = &A;
  %let Action = %upcase(&Action);
  %if &Def ne %str() %then %let Def = %upcase( %sysfunc(compbl(&Def)) );

    
  %***** ***** ***** ERROR CHECKS ***** ***** *****;

  %if %index(BMEDXLZ,&Action) eq 0 or
      %length(&Action) ne 1 %then
    %do;
      %put ;
      %put %str(=====================================================================);
      %err_mput( macro=MacroSearch, msg=No valid action requested. Cat=&Cat Action=&Action )
      %put %str(=====================================================================);
      %put ;
      %goto Finish;
    %end;


  %***** ***** ***** MACRO BODY ***** ***** *****;
  
  %if &Cat eq %str() and &Action ne L and &Action ne X and &Action ne Z %then
    %do;
      %put Here%str(%')s a list:;
      %goto Finish;
    %end;

  %if &Action eq X %then 
    %do;
      options sasautos=(&Def);
      %let Cat = %str();
    %end;

  %if &Cat ne %str() %then %let Cat = %upcase( %sysfunc(compbl(&Cat)) );

  %let NumCats = %eval(%length(&Cat) - %length(%sysfunc(compress(&Cat,%str( )))) +1);
  %if &Action eq Z %then %let NumCats = 1;

  %if &NumCats ge 1 %then
    %do;
      %if &Action eq M or &Action eq B %then
        %do;
          %let _Index1 = &NumCats;
          %let _Index2 = 1;
          %let _ByVal  = -1;
        %end;
      %else
        %do;
          %let _Index1 = 1;
          %let _Index2 = &NumCats;
          %let _ByVal  = 1;
        %end;
      %do i = &_Index1 %to &_Index2 %by &_ByVal;
        %let _ThisCat = %scan(&Cat,&i,%str( ));

        %let _FMS   = 
           %upcase(%sysfunc(compress(%sysfunc(getoption(sasautos)),%str(%(%)))));

        %if &Action eq D or &Action eq M or &Action eq B or &Action eq E  %then
          %do;
            %let _NewFMS = %sysfunc(compbl(%sysfunc(tranwrd(%str( &_FMS ),%str( &_ThisCat ),%str()))));
            %if &Action eq D %then %str(options sasautos=(&_NewFMS););
          %end;

        %if &Action eq M %then
          %do;
            %let pos = %index( &_NewFMS, &Def );
            %if &pos = 0 %then 
              %do;
                options sasautos=(&_NewFMS &_ThisCat);
              %end;
            %else %if &pos = 1 %then
              %do;
                options sasautos=(&_ThisCat &_NewFMS);
              %end;
            %else
              %do;
                options sasautos=(%substr(&_NewFMS,1,&pos-1) &_ThisCat %substr(&_NewFMS,&pos));
              %end;
          %end;

        %if &Action eq B %then
          %do;
            options sasautos=(&_ThisCat &_NewFMS);
          %end;

        %if &Action eq E %then
          %do;
            options sasautos=(&_NewFMS &_ThisCat);
          %end;
      %end;
    %end;

  %if %mparam_is_yes( &Status ) %then
    %do;
      %put; 
      %put %str(=====================================================================);
      %let _FMS = %upcase(%sysfunc(compress(%sysfunc(getoption(sasautos)),%str(%(%)))));
      %put Current Sasautos Option value:;
      %put ;
      %put %str(     )&_FMS;
      %put ;
      %put %str(=====================================================================);
      %put ;
    %end;

  %Finish:


  %***** ***** ***** CLEAN UP ***** ***** *****;

%mend MacroSearch;


/************************ UNCOMMENT TO TEST ***************************

filename Test 'D:\';

%MacroSearch( action=L )

%MacroSearch( cat=Test, action=0 )

%MacroSearch( cat=Test, action=E )

%put _global_;

/**********************************************************************/

