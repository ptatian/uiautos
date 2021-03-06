/******************* URBAN INSTITUTE MACRO LIBRARY *********************
 
 Macro: DirExist

 Description: Returns 1 if specified folder exists, 0 if it does not exist.
 
 Code source is http://www.sascommunity.org/wiki/Tips:Check_if_a_directory_exists
 
 Use: Function
 
 Author: Peter Tatian
 
***********************************************************************/

%macro DirExist(
  dir    /** Folder pathname **/
  ); 

  /*************************** USAGE NOTES *****************************
   
   SAMPLE CALL: 
     %DirExist( K:\Metro\PTatian\UISUG\Uiautos )
       returns true (1) if folder K:\Metro\PTatian\UISUG\Uiautos exists,
       false (0) otherwise

  *********************************************************************/

  /*************************** UPDATE NOTES ****************************


  *********************************************************************/

  %***** ***** ***** MACRO SET UP ***** ***** *****;
   
  %local rc fileref return; 
    
    
  %***** ***** ***** ERROR CHECKS ***** ***** *****;



  %***** ***** ***** MACRO BODY ***** ***** *****;

   %let rc = %sysfunc(filename(fileref,&dir)) ; 
   %if %sysfunc(fexist(&fileref)) %then %let return=1;    
   %else %let return=0;
   &return


  %***** ***** ***** CLEAN UP ***** ***** *****;


%mend DirExist;


/************************ UNCOMMENT TO TEST ***************************

%let r = %DirExist( K:\Metro\PTatian\UISUG\Uiautos );

%put r=&r;

/**********************************************************************/

