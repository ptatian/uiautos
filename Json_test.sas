* Json_test.sas - 
*
* 
*
* NB:  Program written for SAS Version 9.1
*
* 05/10/19  Peter A. Tatian
****************************************************************************;

%put _all_;

%macro test;

%local v1 v2 v3 v4 ver;

%let v1 = %scan( &SYSVLONG, 1, '.ABCDEFGHIJKLMNOPQRSTUVWXYZ' );
%let v2 = %scan( &SYSVLONG, 2, '.ABCDEFGHIJKLMNOPQRSTUVWXYZ' );
%let v3 = %scan( &SYSVLONG, 3, '.ABCDEFGHIJKLMNOPQRSTUVWXYZ' );
%let v4 = %scan( &SYSVLONG, 4, '.ABCDEFGHIJKLMNOPQRSTUVWXYZ' );

%let ver = %eval( &v4 + 1000 * (&v3) + 100000 * (&v2) + 10000000 * (&v1) );

%put _local_;

%mend test;

%test;

ENDSAS;

/*filename in 'D:\Temp\json_sample.txt';*/
filename in url "https://api.census.gov/data/2017/acs/acs5/variables.json" debug;

data testdata2;
    infile in firstobs=3 lrecl=3000 dlmstr='//' truncover /*scanover*/;

      length field label group attributes $ 255;
      length buff $ 3000;
    
      input buff;
      
      if buff = '}' then stop;
      
      field = compress( scan( left( buff ), 1, ':' ), '"' );
      
      input buff; 

      do until ( buff =: '}' );
      
        select ( compress( scan( left( buff ), 1, ':,' ), '"' ) );
          when ( 'label' ) label = left( compress( scan( left( buff ), 2, ':,' ), '"' ) );
          when ( 'group' ) group = left( compress( scan( left( buff ), 2, ':,' ), '"' ) );
          when ( 'attributes' ) attributes = left( compress( scan( left( buff ), 2, ':' ), '"' ) );
          otherwise /** DO NOTHING **/;
        end;
        
        input buff;
        
      end;
      
      if group = "B01001" then output;
      
      drop buff;

      
/****      
      
      input;
      label = compress( scan( left( _infile_ ), 2, ':,' ), '"' );
      
      input;
      concept = compress( scan( left( _infile_ ), 2, ':,' ), '"' );
      
      input;
      predicateType = compress( scan( left( _infile_ ), 2, ':,' ), '"' );
      
      input;
      group = compress( scan( left( _infile_ ), 2, ':,' ), '"' );
      
      input;
      limit = compress( scan( left( _infile_ ), 2, ':,' ), '"' );
      
      input;
      attributes = compress( scan( left( _infile_ ), 2, ':' ), '"' );
      
      input;
      
      output;
      
/*        
        input 
            @'"label": ' label $255.
            @'"concept": ' concept $255. 
            @'"predicateType": ' predicateType $255. 
            @'"group": ' group $255. 
            @'"limit": ' limit $255. 
            @'"predicateOnly": "' predicateOnly $255.;
*/
/*
        acct_nbr=scan(acct_nbr,1,',"');
        streetAddress = scan(streetAddress,1,',"');
        city = scan(city,1,',"');
        state = scan(state,1,',"');
        postalCode = scan(postalCode,1,',"');
*/
run;

proc sort data=testdata2;
  by field;

proc print data=testdata2 (obs=50);

RUN;
