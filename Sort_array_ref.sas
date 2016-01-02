/******************* URBAN INSTITUTE MACRO LIBRARY *********************
 
 Macro: Sort_array_ref

 Description: autocall macro to 'sort' the elements in an array by reference.  
 Given an array, A{*}, the macro creates a temporary array 
 called A_SRTD{*} that contains a list of indices for the 
 original array that will put its elements in sorted order.
 
 Use: Within data step
 
 Author: Peter Tatian
 
***********************************************************************/

%macro Sort_array_ref( arry, max_arry_size=32767, order=ASCENDING, quiet=N );

  /*************************** USAGE NOTES *****************************
   
   SAMPLE CALL: 
     %Sort_array_ref( a )
       creates a temporary array, a_srtd{}, that has the index values
       for array a{} that put array values in ascending order, ie,
       a{a_srtd{1}} would return the smallest value in a{}

  *********************************************************************/

  /*************************** UPDATE NOTES ****************************

   06/02/03  Peter A. Tatian

  *********************************************************************/

  %***** ***** ***** MACRO SET UP ***** ***** *****;
   
  %local comp_op;
    
    
  %***** ***** ***** ERROR CHECKS ***** ***** *****;

  ** Check that size of array does not exceed temporary array size **;
  
  if dim( &arry ) > &max_arry_size then do;
    %err_put( macro=Sort_array_ref, msg="Size of array %upcase( &arry ) exceeds limit set in MAX_ARRY_SIZE parameter (&max_arry_size)." )
    %err_put( macro=Sort_array_ref, msg="Specify a larger value for MAX_ARRY_SIZE= parameter in macro invocation." )
  end;


  %***** ***** ***** MACRO BODY ***** ***** *****;

  %if %upcase( &order ) = DESCENDING %then %do; 
    %let comp_op = LT;
    %if not %mparam_is_yes( &quiet ) %then %do;
      %note_put( macro=Sort_array_ref, msg="Array %upcase( &arry ) will be sorted in DESCENDING order." )
    %end;
  %end;
  %else %do; 
    %let comp_op = GT;
    %if not %mparam_is_yes( &quiet ) %then %do;
      %note_put( macro=Sort_array_ref, msg="Array %upcase( &arry ) will be sorted in ASCENDING order." )
    %end;
  %end;

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


  %***** ***** ***** CLEAN UP ***** ***** *****;

%mend Sort_array_ref;


/************************ UNCOMMENT TO TEST ***************************

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

/**********************************************************************/
