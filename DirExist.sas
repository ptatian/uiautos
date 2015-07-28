/**************************************************************************
 Program:  DirExist.sas
 Project:  UI Macro Library
 Author:   P. Tatian
 Created:  11/02/13
 Version:  SAS 9.2
 Environment:  Windows
 
 Description: Returns 1 if specified folder exists, 0 if it does not exist.
 
 Source: http://www.sascommunity.org/wiki/Tips:Check_if_a_directory_exists

 Modifications:
**************************************************************************/

%macro DirExist(dir) ; 
   %LOCAL rc fileref return; 
   %let rc = %sysfunc(filename(fileref,&dir)) ; 
   %if %sysfunc(fexist(&fileref)) %then %let return=1;    
   %else %let return=0;
   &return
%mend DirExist;
