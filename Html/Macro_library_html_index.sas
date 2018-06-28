/******************* URBAN INSTITUTE MACRO LIBRARY *********************
 
 Program: Macro_library_html_index

 Description: Generate HTML list of macros in library.
 
 Author: Peter Tatian (adapted from code by Quentin McMullen)
 
***********************************************************************/

%macro CodeIndex
(path = /* path for directory with macro code */
,htmpath = /* path to write html files (copy of each sas program and index) */
,htmtitle = /**PT** title for HTML pages (character value) **/
,htmstyle = Minimal /**PT** ODS style for HTML pages **/
,debug = 0 /* boolean, debug mode or not */
,taglist=macro description use author approval approver version /**PT** List of header tags to process **/
);
/**********************************************************************
Macro: CodeIndex
Description: Read through a directory full of macros and create an html
index listing each macro name, description, and a link to the code.
The macro name and description are taken from the header of the
macro code, which must be in the standard header format.
Each macro program is copied to an html file (program.htm).
Example: %CodeIndex(path=c:/SAS/development/junk
,htmpath=c:/SAS/development/junk
)
Author: Quentin McMullen
History: Created 2/11/2004
Notes:
**********************************************************************/
%local
programlist
program
i
urltext
;
%*build pipe-delimited list of programs found in the directory;
%let programlist=%FileList(path=&path,ext=sas,dlm=|) ;
%let i=1;
%let program=%scan(&programlist,&i,|);
%do %while (%length(&program));
%*write out an html copy of program;
%makehtml(file=&path\&program
,out=&htmpath/%scan(&program,1,.).htm
)
%*read in program and write a dataset __macinfo with data from program header;
%ExtractHeaderInfo(path=&path,program=&program,out=__macinfo,
taglist=&taglist)
%*build a dataset that has one record per macro, with data from program header;
%put ;
%put /////  Processing &program..  /////;
proc append base=__allmacinfo data=__macinfo;
run;
proc datasets library=work memtype=data nolist;
delete __macinfo;
quit;
%let i=%eval(&i+1);
%let program=%scan(&programlist,&i,|);
%end;
%BuildIndex(data=__allmacinfo, path=&htmpath, htmtitle=&htmtitle, htmstyle=&htmstyle)
proc datasets library=work memtype=data nolist;
delete __allmacinfo;
quit;
%mexit:
%mend CodeIndex;


%macro FileList
(path = /* directory path */
,ext = _ALL_ /* extension for files to be returned */
,dlm = | /* delimiter for list of files */
,debug = 0 /* boolean, debug mode or not */
);
/**********************************************************************
Macro: FileList
Description: Macro function to return a list of files in a specified
directory.
Example: %put %FileList(path=c:\junk
,ext=sas
);
Author: Quentin McMullen
History: created 2/11/2004
Notes:
**********************************************************************/
%local
filrf
rc
did
memcount
i
filename
return
;
%let filrf=__MYDIR;
/*assign fileref MYDIR to directory, no & needed for filename function!*/
%let rc=%sysfunc(filename(filrf,&path));
%if &rc ne 0 %then %do;
%put ERROR: USER rc=&rc bad directory name exiting macro;
%goto mEXIT;
%end;
%let did=%sysfunc(dopen(&filrf)); /*id number for directory*/
%if &did eq 0 %then %do;
%put ER%str()ROR: USER did=&did bad directory name exiting macro;
%goto mEXIT;
%end;
%let memcount=%sysfunc(dnum(&did)); /*number of files in directory*/
%*build list of files;
%do i=1 %to &memcount;
%let filename=%qsysfunc(dread(&did,&i));
%if %upcase(&ext)=_ALL_ or %length(&ext)=0 %then %do;
%let return=&return&filename&dlm;
%end;
%else %do;
%if %upcase(%scan(&filename,-1,.))=%upcase(&ext) %then
%let return=&return&filename&dlm;
%end;
%end;
%let rc=%sysfunc(dclose(&did)); /*close directory*/
%let rc=%sysfunc(filename(filrf)); /*unassign fileref*/
&return /*return the list of files*/
%if &debug %then %put memcount=&memcount filelist=&return;
%mexit:
%mend filelist;


%macro MakeHtml
(file = /* text file read in */
,out = /* html file written out */
,debug = 0 /* boolean, debug mode or not */
);
/**********************************************************************
Macro: MakeHtml
Description: Read in a SAS program (or any text file),
add a <pre> tag at the top, and save as
an html file. Uses htmlencode function to
convert & < > into html code.
Example: %makehtml(file=c:/junk/me.sas
,out=c:/junk/me.htm
)
Author: Quentin McMullen
History: Created 2/11/2004
Notes: html tags taken from Ed Heaton SAS-L post 3/29/2004
**********************************************************************/
%local file_nopath;
%let file_nopath = %scan( &file, -1, \/ );
data _null_;
infile "&file" end=eof;
file "&out";
if ( _n_ eq 1 ) then put
@01 '<!doctype html public "-//w3c//dtd html 4.0 final//en">'
/ @01 "<html>"
/ @04 "<head>"
/ @07 "<title>&file_nopath</title>"
/ @04 "</head>"
/ @04 "<body>"
/ @07 "<pre>"
;
input;
_infile_=htmlencode(_infile_); %*convert & < > in SAS code into &amp &lt &gt;
put _infile_ ;
if eof then put
@07 "</pre>"
/ @04 "</body>"
/ @01 "</html>"
;
run;
%mend Makehtml;


%macro ExtractHeaderInfo
(path = /* path for macro code to be read in */
,program = /* name of file being read in */
,taglist = macro description example author history notes
/* space-delimited list of tags used in header */
,out = /* name of output dataset with info from header */
,debug = 0 /* boolean, debug mode or not */
);
/**********************************************************************
Macro: ExtractHeaderInfo
Description: Read in the header of a macro file, write out a dataset
that has information from the header. Output dataset
has one wide record.
Example:
Author: Quentin McMullen
History: Created 2/11/2004
Notes:
**********************************************************************/
data __minfo(keep=field text);
infile "&path\&program" end=eof length = len pad;
retain field text;
length FirstWord $20 Field $20 text $32767;
input line $varying132. len ;
**PT** Remove leading blanks and *s from line ;
if index(line,'*****/') = 0 then do;
  do while ( line in: ( ' ', '*' ) and line ne '' );
    line = substr( line, 2 );
  end;
end;
if line=' ' then delete; *skip blank lines;
%* Check first word of each line. If the word is a tag ;
%* from the macro header, grab the text after the tag. ;
FirstWord=upcase(left(scan(line,1,':')));
/************PT*************
PUT "PROGRAM=&PROGRAM" FIELD= TEXT= FIRSTWORD= LINE=;
/***************************/
if indexw(upcase("&taglist"),FirstWord) or index(line,'*****/') then do;
  if field ne ' ' then output;
  field=FirstWord;
  /***PT****text=left(substr(line,length(FirstWord)+2));****/
  /***PT***/ text=left(substr(left(line),length(FirstWord)+2));
end;
else do; %*continuation- additional lines for same field;
  text=trim(text)||' '||left(line);
end;
if index(line,'*****/') then do;
%*add record for program name, taken from parameter;
field="PROGRAM";
text="&program";
output;
%**PT** Add field for case-insensitive sorting of program list ;
field="PROGRAM_SRT";
text=upcase("&program");
output;
stop;
end;
run;

/************PT*************
PROC PRINT DATA=__MINFO;
ID FIELD;
FORMAT TEXT $40.;
RUN;
/***********************/

proc transpose data=__minfo out=&out (drop=_name_);
var text;
id field;
run;

proc datasets library=work memtype=data nolist;
delete __minfo ;
run;
quit;

%mexit:
%mend ExtractHeaderInfo;


%macro BuildIndex
(data = /* name of dataset holding information for index */
,path = /* path to write index */
,htmtitle = /**PT** title for HTML pages (character value) **/
,htmstyle = /**PT** ODS style for HTML pages **/
,debug = 0 /* boolean, debug mode or not */
);
/**********************************************************************
Macro: BuildIndex
Description: Produce 2 html files:
_macroindex.htm lists macro names and descriptions from the
input dataset;
_index.htm is a simple frameset to display the index.
Example: %BuildIndex(data=macroinfo, path=c:\junk)
Author: Quentin McMullen
History: Created 2/11/2004
Notes:
**********************************************************************/
%local urltext;
%* Write a simple html with 2 frames, one will hold the macro index ;
%* the other will hold display macro code. ;
data _null_;
file "&path\_index.htm";
put @01 '<!doctype html public "-//w3c//dtd html 4.0 final//en">'
/ @01 "<html>"
/ @04 "<head>"
/ @07 "<title>" &htmtitle "</title>"
/ @04 "</head>"
/ @04 '<frameset rows="*,340" border="20" framespacing="2" cols="*">'
/ @07 '<frame name="Index" src="_macroindex.htm">'
/ @07 '<frame name="Code" src="">'
/ @04 "</frameset>"
/ @01 "</html>"
;
run;
/************PT*************
PROC CONTENTS DATA=__ALLMACINFO;
RUN;
PROC PRINT DATA=__ALLMACINFO;
ID MACRO;
RUN;
DATA _NULL_;
  SET __ALLMACINFO;
  FILE PRINT;
  PUT / '--------------------';
  PUT (_ALL_) (= /);
RUN;
/***********************/
ods listing close;
ods html body = "&path\_macroindex.htm" (title=&htmtitle) style=&htmstyle;
title1 &htmtitle;
footnote1 "Updated %sysfunc(putn(%sysfunc(today()),mmddyy10.))";
proc report data=&data nowd;
column program program_srt macro description;
define program / noprint;
define program_srt / noprint order;
define macro / 'Macro' display;
define description / 'Description';
compute macro;
%*Each macro name links to its code. The hreftarget="CODE" is the name;
%*of the frame in the viewing window. ;
call symput("urltext",scan(program,1,".")||".htm");
call define(_col_,"STYLE",'STYLE=[hreftarget="Code" URL="&urltext"]');
endcomp;
run;
title;
footnote;
ods html close;
ods listing;
%mend BuildIndex;



***********************************************************************************************;
*****  Main macro call;

options mprint nosymbolgen nomlogic;
options msglevel=n;

%CodeIndex( 
path=D:\Projects\UISUG\Uiautos,
htmpath=D:\Projects\UISUG\Uiautos\Html,
htmtitle="Urban Institute SAS Macro Library",
htmstyle=BarrettsBlue,
debug=1 )

run;

