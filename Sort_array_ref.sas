/* Sort_array_ref.sas - SAS Macro Library
 *
 * SAS autocall macro to 'sort' the elements in an array by reference.  
 * Given an array, say A{*}, the macro creates a temporary array 
 * called A_SRTD{*} that contains a list of indices for the 
 * original array that will put its elements in sorted order.
 *
 * Uses bubble sort algorithm.
 *
 * NB:  Program written for SAS Version 8.2
 *
 * 06/02/03  Peter A. Tatian
 ****************************************************************************/


/** Macro Sort_array_ref - Start Definition **/

%macro Sort_array_ref( arry, max_arry_size=32767, order=ASCENDING, quiet=N );

  %if %upcase( &order ) = DESCENDING %then %do; 
    %let comp_op = LT;
    %if %upcase( &quiet ) ~= Y %then %do;
      put "NOTE (Sort_array_ref):  Array %upcase( &arry ) sorted in DESCENDING order.";
    %end;
  %end;
  %else %do; 
    %let comp_op = GT;
    %if %upcase( &quiet ) ~= Y %then %do;
      put "NOTE (Sort_array_ref):  Array %upcase( &arry ) sorted in ASCENDING order.";
    %end;
  %end;

  ** Check that size of array does not exceed temporary array size **;
  
  if dim( &arry ) > &max_arry_size then do;
    put "ER" "ROR (Sort_array_ref):  Size of array %upcase( &arry ) exceeds limit set in MAX_ARRY_SIZE parameter (&max_arry_size).";
    put "ER" "ROR (Sort_array_ref):  Specify a larger value for MAX_ARRY_SIZE= in macro invocation.";
  end;

  ** Define temporary array of array indices to sort **;

  array &arry._srtd{ &max_arry_size } _temporary_;

  do _srta_i = 1 to dim( &arry );
    &arry._srtd{ _srta_i } = _srta_i;
  end;
  
  ** Sort array indices by array element value using bubble sort algorithm **;
  
  do _srta_i = dim( &arry ) to 1 by -1;

    do _srta_j = 1 to dim( &arry ) - 1;
    
      if &arry{ &arry._srtd{ _srta_j } } &comp_op &arry{ &arry._srtd{ _srta_j + 1} } then do;
        _srta_z = &arry._srtd{ _srta_j };
        &arry._srtd{ _srta_j } = &arry._srtd{ _srta_j + 1 };
        &arry._srtd{ _srta_j + 1 } = _srta_z;
      end;
      
    end;
  
  end;

  drop _srta_i _srta_j _srta_z;

%mend Sort_array_ref;

/** End Macro Definition **/


/***** UNCOMMENT TO TEST MACRO *****

title "Sort_array_ref:  SAS Macro Library";

options mprint nosymbolgen nomlogic;

data Test_Sort_array_ref;

  input w x y z;

  cards;
  3 1 4 2
  ;

run;

data _null_;

  set Test_Sort_array_ref;
  
  array a{*} w x y z;
  
  %Sort_array_ref( a )

  put / "UNSORTED:  " @;
        
  do i = 1 to dim( a );
    put "a{" i "}=" a{i} "  " @;
  end;
  
  put / "SORTED:    " @;
        
  do i = 1 to dim( a );
    put "a{" a_srtd{i} "}=" a{a_srtd{i}} "  " @;
  end;

  put //;

run;

data _null_;

  set Test_Sort_array_ref;
  
  array a{*} w x y z;
  
  %Sort_array_ref( a, order=descending )

  put / "UNSORTED:  " @;
        
  do i = 1 to dim( a );
    put "a{" i "}=" a{i} "  " @;
  end;
  
  put / "SORTED:    " @;
        
  do i = 1 to dim( a );
    put "a{" a_srtd{i} "}=" a{a_srtd{i}} "  " @;
  end;

  put //;

run;

/***** END MACRO TEST *****/

