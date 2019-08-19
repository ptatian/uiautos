* Test_m3_ver.sas - 
*
* Test M3 and M5 versions of programs.
*
* NB:  Program written for SAS Version 9.1
*
* 05/11/19  Peter A. Tatian
****************************************************************************;

%include "D:\Projects\UISUG\Uiautos\Get_acs_detailed_table_api_m3.sas" /source2;

/******
%include "D:\Projects\UISUG\Uiautos\Get_acs_detailed_table_api.sas";

proc compare base=B01001_county compare=B01001_county_m3 listall maxprint=(40,32000);
  id state county;
run;

proc compare base=B01001_tract compare=B01001_tract_m3 listall maxprint=(40,32000);
  id state county tract;
run;
