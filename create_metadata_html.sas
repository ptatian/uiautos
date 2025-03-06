/******************* URBAN INSTITUTE MACRO LIBRARY *********************
 
 Macro: Create_metadata_html

 Description: Creates HTML pages from metadata repository created by the
 Update_metadata() macro.
 
 Use: Open code
 
 Author: Peter Tatian
 
***********************************************************************/

%macro Create_metadata_html( 
         meta_lib= ,         /** Library reference for metadata data sets **/
         meta_pre= meta,     /** Data set name prefix for metadata data sets **/
         meta_title= ,       /** Title for metadata HTML pages **/
         update_months=12,   /** Number of past months to show on update page **/
         rss=N,              /** Create RSS update feed? **/
         rss_url=,           /** Prefix URL for RSS update feed **/
         rss_timezone=EST,   /** Timezone for RSS date/time stamps **/
         creator_fmt=,       /** Format for FileCreator (lowercase values) **/
         error_notify=,      /** Email addresses to notify when error occurs (DEPRECATED) **/
         html_folder= ,      /** Folder for HTML files **/
         html_pre= meta,     /** Filename prefix for HTML files **/
         html_suf= html,     /** Filename suffix for HTML files **/
         html_title= Metadata -,  /** HTML title prefix **/
         html_stylesht= ,    /** HTML CSS stylesheet **/
         html_head= ,        /** HTML header tags **/
         html_pg_header= ,   /** HTML page header **/
         html_pg_footer= ,   /** HTML page footer **/
         html_altbgcol=#CCFFCC,  /** Color for alternating backround rows **/
         html_meta_tags=
           "  <meta http-equiv=""Content-type"" content=""text/html;charset=UTF-8"">" /
           "  <meta name=""generator"" content=""SAS macro Create_metadata_html()"">" /
           "  <meta name=""robots"" content=""noindex,nofollow"">"
           /** HTML page meta tags **/
       );

  /*************************** USAGE NOTES *****************************
   
   SAMPLE CALL: 
     %Create_metadata_html( 
              meta_lib= metadata,
              meta_pre= meta,
              meta_title= NeighborhoodInfo DC Metadata System,
              update_months= 12,
              creator_fmt= $creator.,
              html_folder= L:\Metadata\,
              html_pre= meta,
              html_suf= html,
              html_title= NeighborhoodInfo DC Metadata -,
              html_stylesht= metadata_style.css
            )
         create metadata HTML pages in folder L:\Metadata\
         Format $creator is used to convert FileCreator initials to 
         full names.

  *********************************************************************/

  /*************************** UPDATE NOTES ****************************

   12/31/03  Peter A. Tatian
   09/01/04  Add formatted values to HTML pages
             Revised library list
   11/11/04  Added nav bars, web page time stamp, note for suppressed
             formatted values.  "Back to file" link on var values page goes 
             directly to variable entry on file page.  Format name displayed
             on var values page.
   12/20/04  Supports suppression of descriptive statistics for num. vars.
             Suppress "Metadata updated" date on library page if no files.
   03/30/05  Display "(blank)" if variable value is blank string.
             Use MMDDYY format for MEAN, MIN, MAX of SAS date values.
   03/31/05  Added html_meta_tags= option.
   05/06/05  File history: Removed library & data set lines,
             process column. Prevent file date/time from wrapping.
             File: Added list of sorted by variables.
   05/13/05  If no formated value (_FVAL) file, will still create values page
             if numeric variables.
   09/06/05  Set OPTIONS OBS=MAX to avoid data loss when updating metadata.
   03/08/08  Updated date/time format list to SAS 9.2 formats.
             Added update_months= parameter and recent updates page.
   03/10/08  Removed "Metadata updated" from bottom of updates page.
   03/11/08  Fixed Proc Print problem w/FileDesc values that are too long. 
   03/06/09  Added creator_fmt= option to format FileCreator.
             Added option to create RSS feed with latest updates 
             (options rss=, rss_url=, rss_timezone=).
   10/12/11  PAT Added error_notify= option.
                 Report error if no variable records for file. 
   10/14/11  PAT Added local macro variable declaration.
                 Updated HTML document type declaration (html_doctype).
                 Added charset meta tag to html_meta_tags=.
                 Fixed HTML validation problem with <A NAME= > tags in 
                 data set and value pages.
                 Fixed problem with email error notification by switching
                 from X statement to system() function.
   10/18/11  PAT Corrected problems with "Metadata updated:" dates on 
                 library/file list and history pages (wasn't using the 
                 latest dates before). 
   10/21/11  PAT Added macro starting and ending messages to LOG. 
   03/30/14  PAT Added Creator process (FileProcess) to file history pages.
   07/28/17  PAT Added support for datetime and time vars.

  *********************************************************************/

  %***** ***** ***** MACRO SET UP ***** ***** *****;
   
  %local html_doctype date_fmts datetime_fmts time_fmts cur_dt_raw cur_tm_raw cur_dt cur_tm i em archive_folder;
  
  %Note_mput( macro=Create_metadata_html, msg=Macro (version 7/28/17) starting. )
  
  %** HTML document type declaration **;
  
  %let html_doctype = "<!DOCTYPE HTML PUBLIC ""-//W3C//DTD HTML 4.0 Transitional//EN"" ""http://www.w3.org/TR/1998/REC-html40-19980424/loose.dtd"">";

  %** Date formats (updated for SAS 9.2) **;

  %let date_fmts =
    "/DATE/DAY/DDMMYY/" ||
    "/DDMMYYB/DDMMYYC/DDMMYYD/DDMMYYN/DDMMYYP/DDMMYYS/" ||
    "/DOWNAME/" ||
    "/EURDFDD/EURDFDE/EURDFDN/EURDFDWN/EURDFMN/EURDFMY/EURDFWDX/EURDFWKX/" ||
    "/HDATE/HEBDATE/JULDAY/JULIAN/MINGUO/MMDDYY/" ||
    "/MMDDYYB/MMDDYYC/MMDDYYD/MMDDYYN/MMDDYYP/MMDDYYS/" ||
    "/MMYY/" ||
    "/MMYYC/MMYYD/MMYYN/MMYYP/MMYYS/" ||
    "/MONNAME/MONTH/MONYY/NENGO/NLDATE/NLDATEMN/NLDATEW/NLDATEWN/" ||
    "/NLTIMAP/NLTIME/PDJULG/PDJULI/QTR/QTRR/" ||
    "/WEEKDATE/WEEKDATX/WEEKDAY/WEEKU/WEEKV/WEEKW/WORDDATE/WORDDATX/YEAR/YYMM/" ||
    "/YYMMC/YYMMD/YYMMN/YYMMP/YYMMS/" ||
    "/YYMMDD/" ||
    "/YYMMDDB/YYMMDDC/YYMMDDD/YYMMDDN/YYMMDDP/YYMMDDS/" ||
    "/YYMON/YYQ/" ||
    "/YYQC/YYQD/YYQN/YYQP/YYQS/" ||
    "/YYQR/" ||
    "/YYQRC/YYQRD/YYQRN/YYQRP/YYQRS/";

  %let datetime_fmts =
    "/DATETIME/DATEAMPM/DTDATE/DTMONYY/DTWKDATX/DTYEAR/DTYYQC/EURDFDT/NLDATM/NLDATMAP/NLDATMTM/NLDATMW/";
    
  %let time_fmts = 
    "/HHMM/HOUR/MMSS/TIME/TIMEAMPM/TOD/";

  %** Get current date & time for stamping HTML pages **;
  
  %let cur_dt_raw = %sysfunc( date( ) );
  %let cur_tm_raw = %sysfunc( time( ) );

  %let cur_dt = %sysfunc( putn( &cur_dt_raw, worddatx12. ) );
  %let cur_tm = %sysfunc( putn( &cur_tm_raw, timeampm8. ) );
  
  %let archive_folder = Archive\;
  
  %** Save current OBS= setting then set to MAX **;

  %Push_option( obs )
  
  options obs=max;
  %Note_mput( macro=Create_metadata_html, msg=OPTIONS OBS set to MAX for metadata processing. )
  
  %** Set update_months= parameter to 0 if missing **;
  
  %if &update_months = %then %let update_months = 0;
  
    
  %***** ***** ***** ERROR CHECKS ***** ***** *****;



  %***** ***** ***** MACRO BODY ***** ***** *****;

  *****************************************;
  ****  Create library list page       ****;
  *****************************************;
  
  proc sort data=&meta_lib..&meta_pre._libs out=&meta_pre._libs;
    by MetadataLibArchive Library;
  run;
  
  filename fl_out "&html_folder.&html_pre._libraries.&html_suf";
  
  data _null_;
  
    length link $ 255;
    
    retain LastMetadataUpdated altrow HasActiveLibraries ret_MetadataLibArchive 0;
  
    file fl_out;
    
    set &meta_lib..&meta_pre._libs end=last; 
        
    if _n_ = 1 then do;
    
      ** Page header **;
      
      put &html_doctype;
      put "<html>";
      put "<head>";
      put "  <title>&html_title Library list</title>";
      
      if "&html_stylesht" ~= "" then
        put "  <link rel=""stylesheet"" type=""text/css"" href=""&html_stylesht"">";
        
      put &html_meta_tags;
      put "</head>" /;
      put "<body>" /;
      
      ** Copy user supplied header **;
    
      %if %length( &html_pg_header ) ne 0 %then %do;
        put "&html_pg_header" /;
      %end;
      
      ** Page title & nav bar **;
      
      put "<h1>&meta_title</h1>" /;
      
      put "<b>Libraries</b>" /;
      
      ** Link to updates page (if created) **;
      
      %if &update_months > 0 %then %do;
      
        put "<p><a href=""&html_pre._updates.&html_suf"">Recent updates</a></p>" /;
      
      %end;
      
      ** Start table **;
      
      put "<table width=""100%"" cellspacing=""0"" cellpadding=""2"">" /;

      if not MetadataLibArchive then do;
      
        put "<tr>";
        put '<th align="left" valign="bottom" colspan="2"><h2>Active Library List</h2></th>';
        put "</tr>" /;
        
        put "<tr>";
        put '<th align="left" valign="bottom">Library Name</th>';
        put "<th align=""left"" valign=""bottom"">Description</th>";
        put "</tr>" /;
        
        HasActiveLibraries = 1;
      
      end;
    
    end;
    
    if not ret_MetadataLibArchive and MetadataLibArchive then do;
    
      if HasActiveLibraries then do;
        put "<tr>";
        put '<th align="left" valign="bottom" colspan="2">&nbsp;</th>';
        put "</tr>" /;
      end;
    
      put "<tr>";
      put '<th align="left" valign="bottom" colspan="2"><h2>Archived Library List</h2></th>';
      put "</tr>" /;

      put "<tr>";
      put '<th align="left" valign="bottom">Library Name</th>';
      put "<th align=""left"" valign=""bottom"">Description</th>";
      put "</tr>" /;
    
    end;
    
    ** List of libraries **;
    
    link = cats( "&html_pre._", lowcase( library ), ".&html_suf" );
    
    if altrow and "&html_altbgcol" ~= "" then
      put "<tr bgcolor=""&html_altbgcol"">";
    else
      put "<tr>";
      
    Library = %capitalize( Library );
    
    put "<td><a href=" link ">" Library "</a></td>";
    put '<td valign="top">' LibDesc '</td>';
    put "</tr>" /;

    altrow = mod( altrow + 1, 2 );
    
    ** Page footer **;
    
    if last then do;

      put "</table>" /;
      
      put "<p><small><i>Web page updated: " @;

      put "&cur_dt," '&nbsp;' "&cur_tm</i></small></p>" /;
      
      %if %length( &html_pg_footer ) ne 0 %then %do;
        put "&html_pg_footer" /;
      %end;
      
      put "</body>";
      put "</html>";

    end;
    
    ret_MetadataLibArchive = MetadataLibArchive;
    
  run;  

  *****************************************;
  ****  Create library/file list pages ****;
  *****************************************;
  
  ** Add file names to variable data **;
  
  data &meta_pre._files;
  
    merge &meta_lib..&meta_pre._files (in=_in_files)
          &meta_lib..&meta_pre._libs  (in=_in_libs); 
       by Library;
    
    length html_file $ 255;
    
    in_files = _in_files;
    in_libs = _in_libs;
    
    if not in_libs then do;
      %warn_put( macro=Create_metadata_html, msg="Library " library "is not registered." )
      delete;
    end;
    
    html_file = cats( "&html_folder.&html_pre._", lowcase( library ), ".&html_suf" );
  
  run;
  
  proc print data=&meta_pre._files;
    format FileRestrict FileDesc $40.;
    title2 "&meta_pre._files";
  run;
  title2;
  
  data _null_;
  
    length link $ 255;
    
    retain LastMetadataUpdated altrow;
  
    set &meta_pre._files;
      by library;
        
    file fl_out filevar=html_file;
    
    if first.library then do;
    
      Library = %capitalize( Library );
      LastMetadataUpdated = .;
        
      ** Page header **;
      
      put &html_doctype;
      put "<html>";
      put "<head>";
      put "  <title>&html_title " library "library</title>";
      
      if "&html_stylesht" ~= "" then do;
        if MetadataLibArchive then do;
          put "  <link rel=""stylesheet"" type=""text/css"" href=""&html_stylesht"">";
          put "  <link rel=""stylesheet"" type=""text/css"" href=""&archive_folder.&html_stylesht"">";
        end;
        else do;
          put "  <link rel=""stylesheet"" type=""text/css"" href=""&html_stylesht"">";        
        end;
      end;  
        
      put &html_meta_tags;
      put "</head>" /;
      put "<body>" /;
      
      ** Copy user supplied header **;
    
      %if %length( &html_pg_header ) ne 0 %then %do;
        put "&html_pg_header" /;
      %end;
      
      ** Page title & nav bar **;
      
      put "<h1>&meta_title</h1>" /;
      
      put "<a href=""&html_pre._libraries.&html_suf"">Libraries</a>" ' &gt;';
      put "<b>" library "</b>" /;
      
      if MetadataLibArchive then
        put "<h2>File list for " library "library [archived metadata library]</h2>" /;
      else
        put "<h2>File list for " library "library</h2>" /;
      
      
      ** Start table **;
      
      put "<table width=""100%"" cellspacing=""0"" cellpadding=""2"">" /;
      
      put "<tr>";

      put '<th align="left" valign="bottom">File Name</th>';
      put "<th align=""left"" valign=""bottom"">Description</th>";
      put "<th align=""left"" valign=""bottom"">Last<br>Updated</th>";
      
      put "</tr>" /;
    
      altrow = 0;

    end;
    
    ** List of files **;
    
    if in_files then do;
    
      link = cats( '"', lowcase( Library ), '"' );
      
      LastMetadataUpdated = max( LastMetadataUpdated, MetadataUpdated );
      
      if MetadataFileArchive then do;

        link = cats( "&archive_folder.&html_pre._", lowcase( library ), "_", lowcase( FileName ), ".&html_suf" );
      
      end;
      else do;
      
        link = cats( "&html_pre._", lowcase( library ), "_", lowcase( FileName ), ".&html_suf" );

      end;
      
      dt = datepart( FileUpdated );
      
      FileName = %capitalize( FileName );
      
      if altrow and "&html_altbgcol" ~= "" then
        put "<tr bgcolor=""&html_altbgcol"">";
      else
        put "<tr>";
      
      put '<td valign="top"><a href="' link '">' FileName "</a></td>";
      put "<td valign=""top"">" FileDesc "</td>";
      put "<td valign=""top"">" dt mmddyys8. "</td>";
      put "</tr>" /;
      
      altrow = mod( altrow + 1, 2 );
    
    end;
    else do;
    
      put "<tr>";
      put '<td valign="top" colspan="3"><i>No files registered in this library.</i></td>';
      put "</tr>";
      
    end;
	    
    ** Page footer **;
    
    if last.library then do;

      put "</table>" /;
      
      if dt ~= . then do;
      
        dt = datepart( LastMetadataUpdated );
        tm = timepart( LastMetadataUpdated );

        put "<p><small><i>Metadata updated: " @;

        put dt worddatx12. ',&nbsp;' tm timeampm8. "</i></small><br>" /;
        
      end;
      else do;
        put "<p>" @;
      end;
              
      put "<small><i>Web page updated: " @;

      put "&cur_dt," '&nbsp;' "&cur_tm</i></small></p>" /;
      
      %if %length( &html_pg_footer ) ne 0 %then %do;
        put "&html_pg_footer" /;
      %end;
      
      put "</body>";
      put "</html>";

    end;
    
  run;  


  ****************************************************************;
  ****  Create separate data set pages with list of variables ****;
  ****************************************************************;
  
  ** Add file names to variable data **;
  
  data &meta_pre._vars;
  
    set &meta_lib..&meta_pre._vars;
    
    length html_file $ 255;
    
    html_file = cats( "&html_folder.&html_pre._", lowcase( library ), "_", lowcase( FileName ), ".&html_suf" );
  
  run;

  
  ** Create data set pages **;
  
  data _null_;
  
    length link cname sys_cmd $ 255;
  
    retain altrow;

    merge &meta_pre._vars (in=in_vars) &meta_lib..&meta_pre._files; 
      by library filename;

    sys_cmd = '';
    
    ** Check whether file was archived **;
    if MetadataFileArchive then do;
    
      %note_put( macro=CREATE_METADATA_HTML, 
                 msg="File metadata was archived: " library= filename= )
                 
      return;   ** Skip to next record **;      
    
    end;

    ** Check that file has matching variable records **;
    if not in_vars then do;
    
      %err_put( macro=CREATE_METADATA_HTML, 
                msg="No matching variable record for file: " library= filename= )

      ** Notify by email of error **;
      %if %length( &error_notify ) > 0 %then %do;
        %if &SYSSCP ~= WIN %then %do;
          %let i = 1;
          %let em = %scan( &error_notify, &i, %str( ) );
          %do %until ( &em = );
            %note_mput( macro=CREATE_METADATA_HTML, msg=Email notification being sent to &em.. )
            sys_cmd = 
              "mail /subject=""CREATE_METADATA_HTML error: No matching variable record for file: " || 
              "library=" || trim(library) || " filename=" || trim(filename) ||
              """ nl: ""&em""";
            rc = system( sys_cmd );
            %let i = %eval( &i + 1 );
            %let em = %scan( &error_notify, &i, %str( ) );
          %end;
        %end;
      %end;
  
      return;   ** Skip to next record **;
    
    end;
        
    file var_out filevar=html_file;
    
    library = %capitalize( library );
    filename = %capitalize( filename );
    
    cname = cats( library, ".", filename );
        
    if first.filename then do;
    
      ** Page header **;
      
      put &html_doctype;
      put "<html>";
      put "<head>";
      put "  <title>&html_title " cname "data set</title>";
      
      if "&html_stylesht" ~= "" then do;
        put "  <link rel=""stylesheet"" type=""text/css"" href=""..\&html_stylesht"">";
        put "  <link rel=""stylesheet"" type=""text/css"" href=""&html_stylesht"">";
      end;
        
      put &html_meta_tags;
      put "</head>" /;
      put "<body>" /;
      
      ** Copy user supplied header **;
    
      %if %length( &html_pg_header ) ne 0 %then %do;
        put "&html_pg_header" /;
      %end;
      
      ** Page title & nav bar **;
      
      put "<h1>&meta_title</h1>" /;

      put "<a href=""&html_folder.&html_pre._libraries.&html_suf"">Libraries</a>" ' &gt;';

      link = cats( "<a href=&html_folder.&html_pre._", lowcase( library ), ".&html_suf>", library, '</a> &gt;' );

      put link;

      put "<b>" filename "</b>" /;

      put "<h2>" cname "</h2>" /;
      
      ** Start data set info **;
      
      put "<table border=""0"" width=""100%"" cellspacing=""0"" cellpadding=""4"">" /;
      
      link = cats( "&html_folder.&html_pre._", lowcase( library ), ".&html_suf" );
    
      put "<tr>";
      put "<th align=""left"" valign=""top"">Library:</th>";
      put "<td align=""left"" valign=""top""><a href=""" link """>" Library "</a></td>";
      put "</tr>";

      put "<tr>";
      put "<th align=""left"" valign=""top"">Data set:</th>";
      put "<td align=""left"" valign=""top"">" FileName "</td>";
      put "</tr>";

      put "<tr>";
      put "<th align=""left"" valign=""top"">Description:</th>";
      put "<td align=""left"" valign=""top"">" FileDesc "</td>";
      put "</tr>";

      put "<tr>";
      put "<th align=""left"" valign=""top"">File format:</th>";
      put "<td align=""left"" valign=""top"">" FileFmt "</td>";
      put "</tr>";

      put "<tr>";
      put "<th align=""left"" valign=""top"">No. observations:</th>";
      put "<td align=""left"" valign=""top"">" NumObs comma16. "</td>";
      put "</tr>";
      
      if FileSortedBy ~= "" then do;
        put "<tr>";
        put "<th align=""left"" valign=""top"">Sorted by:</th>";
        put "<td align=""left"" valign=""top"">" FileSortedBy "</td>";
        put "</tr>";
      end;

      put "<tr>";
      put "<th align=""left"" valign=""top"">Restrictions:</th>";
      put "<td align=""left"" valign=""top"">" FileRestrict "</td>";
      put "</tr>";
      
      %if &creator_fmt ~= %then %do;
        link = tranwrd( put( lowcase( FileCreator ), &creator_fmt ), ' ', '&nbsp;' );
      %end;
      %else %do;
        link = FileCreator;
      %end;

      put "<tr>";
      put "<th align=""left"" valign=""top"">Creator:</th>";
      put "<td align=""left"" valign=""top"">" link "</td>";
      put "</tr>";

      put "<tr>";
      put "<th align=""left"" valign=""top"">Creator process:</th>";
      put "<td align=""left"" valign=""top"">" FileProcess "</td>";
      put "</tr>";

      dt = datepart( FileUpdated );
      tm = timepart( FileUpdated );

      link = cats( "&html_pre._", lowcase( library ), "_", lowcase( FileName ), "_h.&html_suf" );
  
      put "<tr>";
      put "<th align=""left"" valign=""top"">Last updated:</th>";
      put "<td align=""left"" valign=""top"">" dt worddatx12. ',&nbsp;' tm timeampm8. ;
      put '&nbsp;&nbsp;-&nbsp;&nbsp;';
      put "<a href=""" link """>Revision history</a>";
      put "</td>";
      
      put "</tr>";

      put "</table>" /;
      
      put "<hr>" /;
      
      ** Start variable list **;
      
      put "<table border=""0"" width=""100%"" cellspacing=""0"" cellpadding=""4"">" /;
      
      put "<tr>";

      put "<th align=""left"" valign=""bottom"">Variable name</th>";
      put "<th align=""left"" valign=""bottom"">Type</th>";
      put "<th align=""left"" valign=""bottom"">Values</th>";
      put "<th align=""left"" valign=""bottom"">Description</th>";
      
      put "</tr>" /;
      
      altrow = 0;

    end;
    
    ** Variable list and descriptions **;

    VarName = lowcase( VarName );
    
    if altrow and "&html_altbgcol" ~= "" then
      put "<tr bgcolor=""&html_altbgcol"">";
    else
      put "<tr>";

    link = cats( "<td valign=""top""><a name=""", VarName, """>", VarName, "</a></td>" );
    put link;

    put "<td valign=""top"">" VarType "</td>";

    link = cats( "&html_pre._", lowcase( library ), "_", lowcase( FileName ), "_v.&html_suf#", VarName );
    
    if ( VarType = "N" and _desc_n ~= . ) or ListFmtVals then
      put "<td valign=""top""><a href=""" link """>Values</a></td>";
    else
      put "<td valign=""top"">" '&nbsp;' "</td>";
    
    put "<td valign=""top"">" VarDesc;
    
    if VarType = "C" then do;
      put '<br>&nbsp;&nbsp;<i>Length=</i>' VarLen;
    end;
    
    if VarFmt ~= "" then do;
      put '<br>&nbsp;&nbsp;<i>Format=</i>' VarFmt;
    end;
    
    put "</td>";
        
    put "</tr>" /;
    
    altrow = mod( altrow + 1, 2 );

    ** Page footer **;
    
    if last.filename then do;

      put "</table>" /;

      dt = datepart( MetadataUpdated );
      tm = timepart( MetadataUpdated );

      put "<p><small><i>Metadata updated: " @;

      put dt worddatx12. ',&nbsp;' tm timeampm8. "</i></small><br>" /;
      
      put "<small><i>Web page updated: " @;

      put "&cur_dt," '&nbsp;' "&cur_tm</i></small></p>" /;
      
      %if %length( &html_pg_header ) ne 0 %then %do;
        put "&html_pg_footer" /;
      %end;
    
      put "</body>";
      put "</html>";

    end;
    
  run;  

  
  ************************************************;
  ****  Create separate variable value pages  ****;
  ************************************************;

  %let fval_exists = %Dataset_exists( &meta_lib..&meta_pre._fval );
  
  ** Add file names to variable & value data **;
  
  data &meta_pre._values;
  
    %if &fval_exists %then %do;
  
      merge &meta_lib..&meta_pre._vars (in=_in_vars)
            &meta_lib..&meta_pre._fval (in=_in_fval drop=VarName);
        by Library FileName VarNameUC;
      
      in_vars = _in_vars;
      in_fval = _in_fval;
      
    %end;
    %else %do;
    
      set &meta_lib..&meta_pre._vars;
        by Library FileName VarNameUC;
      
      in_vars = 1;
      in_fval = 0;

      Value = "";
      FmtValue = "";
      Frequency = .;
      MaxFmtVals = .;

    %end;
    
    if ( VarType = "N" and _desc_n ~= . ) or in_fval;
    
    length html_file $ 255;
    
    html_file = cats( "&html_folder.&html_pre._", lowcase( library ), "_", lowcase( FileName ), "_v.&html_suf" );
  
    keep library filename VarName VarNameUC VarType VarDesc VarFmt _desc_: html_file
       in_: Value FmtValue Frequency ListFmtVals MaxFmtVals;

  run;
  
  data &meta_pre._values_file;
  
    merge &meta_pre._values (in=_in_values) &meta_lib..&meta_pre._files; 
      by library filename;
      
    if _in_values; 
    
  run;
  
  ** Create variable value pages **;
  
  data _null_;
  
    length link cname $ 255;
  
    retain altrow 0;
    
    set &meta_pre._values_file;
      by Library FileName VarNameUC;

    ** Check whether file was archived **;
    if MetadataFileArchive then do;
    
      return;   ** Skip to next record **;      
    
    end;

    file var_out filevar=html_file;
    
    library = %capitalize( library );
    filename = %capitalize( filename );
    
    cname = cats( library, ".", filename );
        
    if first.filename then do;
    
      ** Page header **;
      
      put &html_doctype;
      put "<html>";
      put "<head>";
      put "  <title>&html_title " cname "variable values</title>";
      
      if "&html_stylesht" ~= "" then do;
        put "  <link rel=""stylesheet"" type=""text/css"" href=""..\&html_stylesht"">";
        put "  <link rel=""stylesheet"" type=""text/css"" href=""&html_stylesht"">";
      end;
        
      put &html_meta_tags;
      put "</head>" /;
      put "<body>" /;
      
      ** Copy user supplied header **;
    
      %if %length( &html_pg_header ) ne 0 %then %do;
        put "&html_pg_header" /;
      %end;
      
      ** Page title & nav bar **;
      
      put "<h1>&meta_title</h1>" /;
      
      put "<a href=""&html_folder.&html_pre._libraries.&html_suf"">Libraries</a>" ' &gt;';

      link = cats( "<a href=&html_folder.&html_pre._", lowcase( library ), ".&html_suf>", library, '</a> &gt;' );

      put link;

      link = cats( "<a href=&html_pre._", lowcase( library ), "_", lowcase( filename ), ".&html_suf>", filename, '</a> &gt;' );

      put link;

      put "<b>Values</b>" /;

      put "<h2>Variable values for " cname "</h2>" /;
      
      ** Start variable values **;
      
      put "<table border=""0"" width=""100%"" cellspacing=""0"" cellpadding=""2"">" /;
      
    end;
    
    VarName = lowcase( VarName );
    
    ** Determine if date value **;
    
    if VarFmt ~= "" and index( %upcase(&date_fmts), compress( "/" || VarFmt || "/" ) )
      then
        IsDateVal = 1;
      else
        IsDateVal = 0;

    ** Determine if datetime value **;
    
    if VarFmt ~= "" and index( %upcase(&datetime_fmts), compress( "/" || VarFmt || "/" ) )
      then
        IsDatetimeVal = 1;
      else
        IsDatetimeVal = 0;

    ** Determine if time value **;
    
    if VarFmt ~= "" and index( %upcase(&time_fmts), compress( "/" || VarFmt || "/" ) )
      then
        IsTimeVal = 1;
      else
        IsTimeVal = 0;

    ** Variable name & description **;
    
    if first.VarNameUC then do;
    
      put "<tr>";

      if IsDateVal then
        link = cat( "<td align=""left"" valign=""top"" colspan=""6""><a name=""", trim( VarName ), """><b>", 
               trim( VarName ), "</b> - ", trim( VarDesc ), " [SAS date value]</a></td>" );
      else if IsDatetimeVal then
        link = cat( "<td align=""left"" valign=""top"" colspan=""6""><a name=""", trim( VarName ), """><b>", 
               trim( VarName ), "</b> - ", trim( VarDesc ), " [SAS datetime value]</a></td>" );
      else if IsTimeVal then
        link = cat( "<td align=""left"" valign=""top"" colspan=""6""><a name=""", trim( VarName ), """><b>", 
               trim( VarName ), "</b> - ", trim( VarDesc ), " [SAS time value]</a></td>" );
      else
        link = cat( "<td align=""left"" valign=""top"" colspan=""6""><a name=""", trim( VarName ), """><b>", 
               trim( VarName ), "</b> - ", trim( VarDesc ), "</a></td>" );

      put link;

      link = cats( "&html_pre._", lowcase( library ), "_", lowcase( FileName ), ".&html_suf", "#", VarName );
      
      put '<td align="right" valign="top" colspan="6"><a href="' link '"><small>Back to file</small></a></td>';

      put "</tr>";
      
      altrow = 0;
      
    end;
    
    ** Descriptive statistics for unformatted numeric variables **;
    
    if first.VarNameUC and not( in_fval ) and _desc_n ~= . then do;
    
      if IsDateVal then do;

        put "<tr>";
        put '<td align="right" width="5%"><small>&nbsp;</small></td>';
        put "<td align=""right"" width=""15%""><small><i>N</i></small></td>";
        put "<td align=""right"" width=""15%""><small><i>Mean</i></small></td>";
        put "<td align=""right"" width=""15%""><small><i>StdDev (days)</i></small></td>";
        put "<td align=""right"" width=""15%""><small><i>Min</i></small></td>";
        put "<td align=""right"" width=""15%""><small><i>Max</i></small></td>";
        put '<td align="right"><small>&nbsp;</small></td>';
        put "</tr>";
        
        put "<tr>";
        put '<td align="right"><small>&nbsp;</small></td>';
        put "<td align=""right""><small>" _desc_n comma16. "</small></td>";
        put "<td align=""right""><small>" _desc_mean mmddyy10. "</small></td>";
        put "<td align=""right""><small>" _desc_std best8. "</small></td>";
        put "<td align=""right""><small>" _desc_min mmddyy10. "</small></td>";
        put "<td align=""right""><small>" _desc_max mmddyy10. "</small></td>";
        put '<td align="right"><small>&nbsp;</small></td>';
        put "</tr>";      

      end;
      else if IsDatetimeVal then do;

        put "<tr>";
        put '<td align="right" width="5%"><small>&nbsp;</small></td>';
        put "<td align=""right"" width=""15%""><small><i>N</i></small></td>";
        put "<td align=""right"" width=""15%""><small><i>Mean</i></small></td>";
        put "<td align=""right"" width=""15%""><small><i>StdDev (seconds)</i></small></td>";
        put "<td align=""right"" width=""15%""><small><i>Min</i></small></td>";
        put "<td align=""right"" width=""15%""><small><i>Max</i></small></td>";
        put '<td align="right"><small>&nbsp;</small></td>';
        put "</tr>";
        
        put "<tr>";
        put '<td align="right"><small>&nbsp;</small></td>';
        put "<td align=""right""><small>" _desc_n comma16. "</small></td>";
        put "<td align=""right""><small>" _desc_mean datetime. "</small></td>";
        put "<td align=""right""><small>" _desc_std best8. "</small></td>";
        put "<td align=""right""><small>" _desc_min datetime. "</small></td>";
        put "<td align=""right""><small>" _desc_max datetime. "</small></td>";
        put '<td align="right"><small>&nbsp;</small></td>';
        put "</tr>";      

      end;
      else if IsTimeVal then do;

        put "<tr>";
        put '<td align="right" width="5%"><small>&nbsp;</small></td>';
        put "<td align=""right"" width=""15%""><small><i>N</i></small></td>";
        put "<td align=""right"" width=""15%""><small><i>Mean</i></small></td>";
        put "<td align=""right"" width=""15%""><small><i>StdDev (seconds)</i></small></td>";
        put "<td align=""right"" width=""15%""><small><i>Min</i></small></td>";
        put "<td align=""right"" width=""15%""><small><i>Max</i></small></td>";
        put '<td align="right"><small>&nbsp;</small></td>';
        put "</tr>";
        
        put "<tr>";
        put '<td align="right"><small>&nbsp;</small></td>';
        put "<td align=""right""><small>" _desc_n comma16. "</small></td>";
        put "<td align=""right""><small>" _desc_mean time. "</small></td>";
        put "<td align=""right""><small>" _desc_std best8. "</small></td>";
        put "<td align=""right""><small>" _desc_min time. "</small></td>";
        put "<td align=""right""><small>" _desc_max time. "</small></td>";
        put '<td align="right"><small>&nbsp;</small></td>';
        put "</tr>";      

      end;
      else do;

        put "<tr>";
        put '<td align="right" width="5%"><small>&nbsp;</small></td>';
        put "<td align=""right"" width=""15%""><small><i>N</i></small></td>";
        put "<td align=""right"" width=""15%""><small><i>Sum</i></small></td>";
        put "<td align=""right"" width=""15%""><small><i>Mean</i></small></td>";
        put "<td align=""right"" width=""15%""><small><i>StdDev</i></small></td>";
        put "<td align=""right"" width=""15%""><small><i>Min</i></small></td>";
        put "<td align=""right"" width=""15%""><small><i>Max</i></small></td>";
        put '<td align="right"><small>&nbsp;</small></td>';
        put "</tr>";
        
        put "<tr>";
        put '<td align="right"><small>&nbsp;</small></td>';
        put "<td align=""right""><small>" _desc_n comma16. "</small></td>";
        put "<td align=""right""><small>" _desc_sum best8. "</small></td>";
        put "<td align=""right""><small>" _desc_mean best8. "</small></td>";
        put "<td align=""right""><small>" _desc_std best8. "</small></td>";
        put "<td align=""right""><small>" _desc_min best8. "</small></td>";
        put "<td align=""right""><small>" _desc_max best8. "</small></td>";
        put '<td align="right"><small>&nbsp;</small></td>';
        put "</tr>";

      end;
      
    end;
    
    ** Formatted numeric & character variables **;
    
    if in_fval then do;
    
      if first.VarNameUC then do;
      
        put "<tr>";
        put '<td align="right" width="5%"><small>&nbsp;</small></td>';
        put "<td align=""left"" width=""15%""><small><i>Value</i></small></td>";

        link = cats( "(", VarFmt, ")" );
        
        put "<td align=""left"" width=""60%"" colspan=""4""><small><i>Formatted value "
            link 
            "</i></small></td>";

        put "<td align=""right"" width=""15%""><small><i>N</i></small></td>";
        put '<td align="right"><small>&nbsp;</small></td>';
        put "</tr>";
        
      end;
      
      if altrow and "&html_altbgcol" ~= "" then
        put "<tr bgcolor=""&html_altbgcol"">";
      else
        put "<tr>";

      put '<td align="right"><small>&nbsp;</small></td>';
      
      if Value = "" then
        put "<td valign=""top"" align=""left""><small><i>(blank)</i></small></td>";
      else
        put "<td valign=""top"" align=""left""><small>" Value "</small></td>";
        
      put "<td valign=""top"" align=""left"" colspan=""4""><small>" FmtValue "</small></td>";
      put "<td valign=""top"" align=""right""><small>" Frequency comma16. "</small></td>";
      put '<td align="right"><small>&nbsp;</small></td>';
      put "</tr>";

      altrow = mod( altrow + 1, 2 );

    end;
    
    if last.VarnameUC then do;

      if MaxFmtVals > 0 then do;
        put "<tr>";
        put '<td align="right"><small>&nbsp;</small></td>';
        put "<td valign=""top"" align=""left"" colspan=""7""><small>" 
            "<i>Only first " MaxFmtVals " values shown.</i>"
            "</small></td>";
        put "</tr>";
      end;
      
      put '<tr><td colspan="8"><hr></td></tr>';

    end;
    
    ** Page footer **;
    
    if last.filename then do;

      put "</table>" /;

      dt = datepart( MetadataUpdated );
      tm = timepart( MetadataUpdated );

      put "<p><small><i>Metadata updated: " @;

      put dt worddatx12. ',&nbsp;' tm timeampm8. "</i></small><br>" /;
      
      put "<small><i>Web page updated: " @;

      put "&cur_dt," '&nbsp;' "&cur_tm</i></small></p>" /;
      
      %if %length( &html_pg_header ) ne 0 %then %do;
        put "&html_pg_footer" /;
      %end;
    
      put "</body>";
      put "</html>";

    end;
    
  run;  

  
  *************************************;
  ****  Create file history pages  ****;
  *************************************;

  ** Add file names to history data **;
  
  data &meta_pre._history;
  
    set &meta_lib..&meta_pre._history;
    
    length html_file $ 255;
    
    html_file = cats( "&html_folder.&html_pre._", lowcase( library ), "_", lowcase( FileName ), "_h.&html_suf" );
  
  run;

  data _null_;
  
    length link cname $ 255;
  
    retain LastMetadataUpdated altrow 0;

    set &meta_pre._history; 
      by library filename;
        
    file hist_out filevar=html_file;
    
    library = %capitalize( library );
    filename = %capitalize( filename );
    
    cname = cats( library, ".", filename );
        
    if first.filename then do;
    
      LastMetadataUpdated = .;

      ** Page header **;
      
      put &html_doctype;
      put "<html>";
      put "<head>";
      put "  <title>&html_title " cname "revision history</title>";
      
      if "&html_stylesht" ~= "" then do;
        put "  <link rel=""stylesheet"" type=""text/css"" href=""..\&html_stylesht"">";
        put "  <link rel=""stylesheet"" type=""text/css"" href=""&html_stylesht"">";
      end;
        
      put &html_meta_tags;
      put "</head>";
      put ;
      put "<body>";
      put ;
      
      ** Copy user supplied header **;
    
      %if %length( &html_pg_header ) ne 0 %then %do;
        put "&html_pg_header" /;
      %end;
      
      ** Page title & nav bar **;
      
      put "<h1>&meta_title</h1>" /;

      put "<a href=""&html_folder.&html_pre._libraries.&html_suf"">Libraries</a>" ' &gt;';

      link = cats( "<a href=&html_folder.&html_pre._", lowcase( library ), ".&html_suf>", library, '</a> &gt;' );

      put link;

      link = cats( "<a href=&html_pre._", lowcase( library ), "_", lowcase( filename ), ".&html_suf>", filename, '</a> &gt;' );

      put link;

      put "<b>Revision history</b>" /;

      put "<h2>Revision history for " cname "</h2>" /;
      
      ** Start history **;
      
      put "<table border=""0"" width=""100%"" cellspacing=""0"" cellpadding=""4"">" /;
      
      put "<tr>";

      put "<th align=""left"" valign=""bottom"">Date/Time</th>";
      put "<th align=""left"" valign=""bottom"">Creator</th>";
      put "<th align=""left"" valign=""bottom"">Creator process</th>";
      put "<th align=""left"" valign=""bottom"">Revisions</th>";
      
      put "</tr>" /;
      
      altrow = 0;
    
    end;
    
    ** List of file revisions **;

    LastMetadataUpdated = max( LastMetadataUpdated, MetadataUpdated );

    dt = datepart( FileUpdated );
    tm = timepart( FileUpdated );
      
    if altrow and "&html_altbgcol" ~= "" then
      put "<tr bgcolor=""&html_altbgcol"">";
    else
      put "<tr>";
    
    link = put( dt, mmddyys8. ) || ' ' || put( tm, timeampm8. );
    link = tranwrd( trim( left( compbl( link ) ) ), ' ', '&nbsp;' );
    
    put "<td valign=""top"">" link "</td>";
    
    %if &creator_fmt ~= %then %do;
      link = tranwrd( put( lowcase( FileCreator ), &creator_fmt ), ' ', '&nbsp;' );
    %end;
    %else %do;
      link = FileCreator;
    %end;
    
    put "<td valign=""top"">" link "</td>";
    
    put "<td valign=""top"">" FileProcess "</td>";

    put "<td valign=""top"">" FileRevisions "</td>";
    
    altrow = mod( altrow + 1, 2 );

    ** Page footer **;
    
    if last.filename then do;

      put "</table>" /;

      dt = datepart( LastMetadataUpdated );
      tm = timepart( LastMetadataUpdated );

      put "<p><small><i>Metadata updated: " @;

      put dt worddatx12. ',&nbsp;' tm timeampm8. "</i></small><br>" /;
      
      put "<small><i>Web page updated: " @;

      put "&cur_dt," '&nbsp;' "&cur_tm</i></small></p>" /;
      
      %if %length( &html_pg_header ) ne 0 %then %do;
        put "&html_pg_footer" /;
      %end;
    
      put "</body>";
      put "</html>";

    end;
    
  run;  
  
  ******************************************;
  ****  Create latest file update page  ****;
  ******************************************;

  %if &update_months > 0 %then %do;

    ** Select and sort update records from history data **;
    
    data &meta_pre._updates;
    
      set &meta_lib..&meta_pre._history;
      
      where intck( 'month', datepart( FileUpdated ), date( ) ) <= &update_months;

    run;
    
    proc sort data=&meta_pre._updates;
      by descending FileUpdated;
      
    ** HTML update page **;

    filename updt_out "&html_folder.&html_pre._updates.&html_suf";
    
    data _null_;
    
      length link cname $ 255;
    
      retain altrow 0 prev_dt '01jan2060'd;

      set &meta_pre._updates end=eof; 
        by descending FileUpdated;
          
      file updt_out;
      
      library = %capitalize( library );
      filename = %capitalize( filename );
      
      cname = cats( library, ".", filename );
          
      if _n_ = 1 then do;
      
        ** Page header **;
        
        put &html_doctype;
        put "<html>";
        put "<head>";
        *put "  <title>&html_title " cname "recent updates</title>";
        put "  <title>&html_title Recent updates</title>";
        
        if "&html_stylesht" ~= "" then
          put "  <link rel=""stylesheet"" type=""text/css"" href=""&html_stylesht"">";
          
        put &html_meta_tags;
        put "</head>";
        put ;
        put "<body>";
        put ;
        
        ** Copy user supplied header **;
      
        %if %length( &html_pg_header ) ne 0 %then %do;
          put "&html_pg_header" /;
        %end;
        
        ** Page title & nav bar **;
        
        put "<h1>&meta_title</h1>" /;

        put "<a href=""&html_pre._libraries.&html_suf"">Libraries</a>" ' &gt;';

        put "<b>Recent updates</b>" /;

        put "<h2>Recent file updates (previous &update_months months)</h2>" /;
        
        ** Start update list **;
        
        put "<table border=""0"" width=""100%"" cellspacing=""0"" cellpadding=""4"">" /;
        
        put "<tr>";

        put "<th align=""left"" valign=""bottom"">Library/File</th>";
        put "<th align=""left"" valign=""bottom"">Date/Time</th>";
        put "<th align=""left"" valign=""bottom"">Creator</th>";
        put "<th align=""left"" valign=""bottom"">Revisions</th>";
        
        put "</tr>" /;
        
        altrow = 0;
      
      end;
      
      ** List of file updates **;

      dt = datepart( FileUpdated );
      tm = timepart( FileUpdated );
      
      ** Add month header, if new month **;
      
      *format prev_dt dt mmddyy10.;
      
      *put _n_= prev_dt= dt= ;
      
      if intck( 'month', prev_dt, dt ) <= -1 then do;
      
        put "<tr>";
        
        link = compbl( put( dt, monname12. ) || " " || put( dt, year4. ) );

        put "<th align=""left"" valign=""bottom"" colspan=""4"">" link "</th>";
        
        put "</tr>" /;
        
        altrow = 0;
        
      end;
        
      if altrow and "&html_altbgcol" ~= "" then
        put "<tr bgcolor=""&html_altbgcol"">";
      else
        put "<tr>";
        
      ** Link to library/file **;
      
      link = cats( "&html_pre._", lowcase( library ), "_", lowcase( FileName ), ".&html_suf" );

      put '<td valign="top"><a href="' link '">' cname "</a></td>";
      
      ** Date/time stamp for revision **;
      
      link = put( dt, mmddyys8. ) || ' ' || put( tm, timeampm8. );
      link = tranwrd( trim( left( compbl( link ) ) ), ' ', '&nbsp;' );
      
      put "<td valign=""top"">" link "</td>";
      
      ** File creator **;

      %if &creator_fmt ~= %then %do;
        link = tranwrd( put( lowcase( FileCreator ), &creator_fmt ), ' ', '&nbsp;' );
      %end;
      %else %do;
        link = FileCreator;
      %end;

      put "<td valign=""top"">" link "</td>";
      
      ** Revision description **;
      put "<td valign=""top"">" FileRevisions "</td>";
      
      altrow = mod( altrow + 1, 2 );

      ** Page footer **;
      
      if eof then do;

        put "</table>" /;

        put "<p><small><i>Web page updated: " @;

        put "&cur_dt," '&nbsp;' "&cur_tm</i></small></p>" /;
        
        %if %length( &html_pg_header ) ne 0 %then %do;
          put "&html_pg_footer" /;
        %end;
      
        put "</body>";
        put "</html>";

      end;
      
      prev_dt = datepart( FileUpdated );
      
    run;  
    
    
    %if %mparam_is_yes( &rss ) %then %do;
    
      /** Macro rss_std_dt - Start Definition **/

      %macro rss_std_dt( dt, tm, tz );

        put( &dt, weekdatx17. ) || ' ' || put( &tm, time8. ) || " %upcase(&tz)"

      %mend rss_std_dt;

      /** End Macro Definition **/
  
      ** RSS update page **;

      filename updt_xml "&html_folder.&html_pre._updates.xml";
      
      data _null_;
      
        length link cname $ 255;
      
        set &meta_pre._updates end=eof; 
          by descending FileUpdated;
            
        file updt_xml;
        
        library = %capitalize( library );
        filename = %capitalize( filename );
        
        cname = cats( library, ".", filename );
          
        dt = datepart( FileUpdated );
        tm = timepart( FileUpdated );
        
        if _n_ = 1 then do;
        
          ** Page header **;
          
          put "<?xml version=""1.0""?>";
          put "<rss version=""2.0"" xmlns:atom=""http://www.w3.org/2005/Atom"">";
          put "<channel>";
          put "  <title>&html_title Recent updates</title>";
          
          ** Page title & nav bar **;
          
          put "  <link>&rss_url/&html_pre._libraries.&html_suf</link>";

          put "  <description>Recent file updates (previous &update_months months)</description>";
          put "  <language>en-us</language>";
          
          link = %rss_std_dt( &cur_dt_raw, &cur_tm_raw, &rss_timezone );
          
          put "  <pubDate>" link "</pubDate>";
          
          link = %rss_std_dt( dt, tm, &rss_timezone );

          put "  <lastBuildDate>" link "</lastBuildDate>";
                    
          put "  <docs>http://www.rssboard.org/rss-specification</docs>";
          put "  <generator>SAS macro Create_metadata_html()</generator>";
          
          put "  <atom:link href=""&rss_url/&html_pre._updates.xml"" rel=""self"" type=""application/rss+xml"" />";
          
        end;
        
        ** Create RSS item **;

        put "      <item>";
        put "         <title>" cname "</title>";
        
        ** Link to library/file **;
        
        link = cats( "&rss_url/&html_pre._", lowcase( library ), "_", lowcase( FileName ), ".&html_suf" );

        put "         <link>" link "</link>";
        
        ** Revision description **;
        put "         <description>" FileRevisions "</description>";
        
        ** Date/time stamp for revision **;
        
        link = %rss_std_dt( dt, tm, &rss_timezone );
        
        put "         <pubDate>" link "</pubDate>";
        
        put "      </item>";
        
        ** Page footer **;
        
        if eof then do;

          put "   </channel>";
          put "</rss>";

        end;
        
      run;  
      
    %end;
  
  %end;
  %else %do;
  
    %Note_mput( macro=Create_metadata_html, msg=Update page not created because update_months= parameter not > 0. )
    
  %end;
    
  %exit:
  
  %***** ***** ***** CLEAN UP ***** ***** *****;

  %** Restore system options **;
  
  %Pop_option( obs )

  %Note_mput( macro=Create_metadata_html, msg=Macro exiting. )

%mend Create_metadata_html;


/************************ UNCOMMENT TO TEST ***************************

** NOTE: Requires running testing code for %Update_metadata_file() first
**       to create metadata files.
**;

** Autocall macros **;

filename uiautos "K:\Metro\PTatian\UISUG\Uiautos";
options sasautos=(uiautos sasautos) noxwait;

** Test folder **;

libname test "d:\temp\Update_metadata_file_test\";

%Create_metadata_html( 
         meta_lib= test,
         meta_pre= meta,
         meta_title= Test of Metadata System,
         update_months= 12,
         creator_fmt=,
         html_folder= d:\temp\Update_metadata_file_test\,
         html_pre= meta,
         html_suf= html,
         html_title= Test Metadata -,
         html_stylesht= 
       )

/**********************************************************************/
