/******************* URBAN INSTITUTE MACRO LIBRARY *********************
 
 Macro: DSNameOnly

 Description: Autocall macro that returns the data set name portion of a
 libname.dataset specification.
 
 Use: Function
 
 Author: Peter Tatian
 
***********************************************************************/

%macro DSNameOnly( LibDataSpec );

  /*************************** USAGE NOTES *****************************
   
   SAMPLE CALL: 
     %DSNameOnly( Libname.Dataset )
       returns Dataset

  *********************************************************************/

  /*************************** UPDATE NOTES ****************************


  *********************************************************************/

  %***** ***** ***** MACRO SET UP ***** ***** *****;
   
  %local dot Ret;
    
    
  %***** ***** ***** ERROR CHECKS ***** ***** *****;



  %***** ***** ***** MACRO BODY ***** ***** *****;

  %let dot = %sysfunc( indexc( &LibDataSpec, '.' ) );
  
  %let Ret = %sysfunc( substr( &LibDataSpec, &dot + 1 ) );
  &Ret


  %***** ***** ***** CLEAN UP ***** ***** *****;


%mend DSNameOnly;


/************************ UNCOMMENT TO TEST ***************************

options mprint symbolgen mlogic;

%let test1 = Libname.DataSet;
%let test1_ds = %DSNameOnly( &test1 );
%put test1=&test1 test1_ds=&test1_ds;

%let test2 = DataSet;
%let test2_ds = %DSNameOnly( &test2 );
%put test2=&test2 test2_ds=&test2_ds;

/**********************************************************************/

