/**************************************************************************** 
  Get_file_date.sas - UI Autocall Macro Library
 
  Open code autocall macro to extract file date and time for an
  external file.
  
  WINDOWS OPERATING SYSTEM ONLY.
 
  NB:  Program written for SAS Version 9.1
  
  NEED TO ADD CHECK FOR WHETHER INPUT FILE EXISTS.
 
  11/23/08  Peter A. Tatian
****************************************************************************/

/** Macro Get_file_date - Start Definition **/

%macro Get_file_date( filepathname, vfiledate=filedate, vfiletime=filetime, vfiledatetime=filedatetime, quiet=N );

  %global &vfiledate &vfiletime &vfiledatetime;

  %let quiet = %upcase( &quiet );
  
  options noxwait;

  filename _gfd_inf pipe "dir ""&filepathname"" /n";

  data _null_;
  
     length filename $ 200;
     
     infile _gfd_inf length=len;
     
     input buff $varying200. len;
     
     %****put _n_= len= buff= ;
     
     if left( buff ) =: "Directory of" then do;
       
       input buff $varying200. len;
       input buff $varying200. len;
       
       filename = scan( buff, 5, ' ' );
       filedate = input( scan( buff, 1, ' ' ), mmddyy10. );
       filetime = input( scan( buff, 2, ' ' ) || scan( buff, 3, ' ' ), time. );
       filedatetime = input( put( filedate, date9. ) || ' ' || put( filetime, time. ), datetime. );

       format filedate mmddyy10. filetime time. filedatetime dateampm.;
       
       %if &quiet = N %then %do;
         %note_put( macro=Get_file_date, msg=filename= / filedate= / filetime= / filedatetime= )
         %***put buff= filedate= filetime= filedatetime=;
       %end;
       
       %if &vfiledate ~= %then %do;
         call symput( "&vfiledate", put( filedate, best16. ) );
       %end;
       
       %if &vfiletime ~= %then %do;
         call symput( "&vfiletime", put( filetime, best16. ) );
       %end;

       %if &vfiledatetime ~= %then %do;
         call symput( "&vfiledatetime", put( filedatetime, best32. ) );
       %end;
       
       stop;

     end;
       
  run;

  filename _gfd_inf clear;

  %****%put _user_;

%mend Get_file_date;

/** End Macro Definition **/

