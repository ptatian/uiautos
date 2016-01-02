/******************* URBAN INSTITUTE MACRO LIBRARY *********************
 
 Macro: SAS_compatibility

 Description: Submits system options for backward compatibility
 of earlier SAS versions. 

 Currently supports backward compatibility of versions 9.3 and 9.4 to
 9.2. 
 
 Use: Open code
 
 Author: Peter Tatian
 
***********************************************************************/

%macro SAS_compatibility( 
  ver=9.2    /** Version number (currently only 9.2 supported) **/
  );

  /*************************** USAGE NOTES *****************************
   
   SAMPLE CALL: 
     %SAS_compatibility(  )

  *********************************************************************/

  /*************************** UPDATE NOTES ****************************


  *********************************************************************/

  %***** ***** ***** MACRO SET UP ***** ***** *****;
   
    
    
  %***** ***** ***** ERROR CHECKS ***** ***** *****;

  %if &ver ~= 9.2 %then %do;
    %err_mput( macro=SAS_compatibility, msg=Value ver=&ver not supported. )
    %goto exit;
  %end;

  %***** ***** ***** MACRO BODY ***** ***** *****;

  %if %sysevalf(&sysver >= 9.3) %then %do;
    options extendobscounter=no validmemname=compatible;
  %end;

  %exit:

  %***** ***** ***** CLEAN UP ***** ***** *****;

%mend SAS_compatibility;


/************************ UNCOMMENT TO TEST ***************************

options mprint mlogic symbolgen;

%SAS_compatibility()

%SAS_compatibility( ver=6 )

/**********************************************************************/
