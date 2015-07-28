/************************************************************************
  Program:  MacroSearch.sas
  Project:  UI SAS Macro Library
  Author:   P. Tatian
  Updated:  8/17/04
  Version:  SAS 8.12
  Environment:  Windows or Alpha
  Use in:  Open code
  
  Description:  Autocall macro to manage multiple SAS macro libraries.
    Adapted from FmtSearch by Pete Lund.
 
  Modifications:
   11/02/13 PAT Used compbl() on _NEWFMS before checking for pos of DEF.
 ************************************************************************/

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
  Cat=,         /* Macro library name */
  C=,           /* Alternate name for Cat= */
  Status=Y,     /* Display status after changes (def. Y) */
  Def=SASAUTOS  /* Default libraries, only used with Action=M or X 
                   (def. SASAUTOS) */
  );
  
  %local _FMS i pos _ThisCat _Index1 _Index2 _ByVal;
  %local _NewFMS;
  
  %if &C ne %str() %then %let Cat = &C;
  %if &A ne %str() %then %let Action = &A;
  %let Action = %upcase(&Action);
  %if &Def ne %str() %then %let Def = %upcase( %sysfunc(compbl(&Def)) );

  %if %index(BMEDXLZ,&Action) eq 0 or
      %length(&Action) ne 1 %then
    %do;
      %put ;
      %put %str(=====================================================================);
      %put ERROR: No valid action requested.;
      %put %str(=====================================================================);
      %put ;
      %goto Finish;
    %end;

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

  %if &Status eq Y %then
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
%mend MacroSearch;
