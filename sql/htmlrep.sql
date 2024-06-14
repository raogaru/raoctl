-- htmlrep.sql used by RPT.lib.sh
set markup HTML off
set pagesi 10000 linesi 1000 trimspool on head on
-- --------------------------------------------------------------------------------
prompt <html>
prompt <head>
prompt <title>RAOCTL_HTML_REPORT_TITLE_TAG</title>
-- --------------------------------------------------------------------------------
prompt <style type="text/css">
prompt body {font:bold 10pt Arial; color:Black; background:White;}
prompt p {font:bold 10pt Arial; color:Red; background:White;}
prompt h1 {font:bold 20pt Arial; color:Red; background:White; border-bottom:2px solid #cccc99; margin-top:0pt; margin-bottom:0pt; padding:0px 0px 0px 0px;}
prompt h2 {font:bold 14pt Arial; color:Red; background:White; border-top:2px solid #cccc99; margin-top:0pt; margin-bottom:0pt; padding:0px 0px 0px 0px;}
prompt h3 {font:bold 10pt Arial; color:Red; background:White; border-top:1px dotted #cccc99; margin-top:0pt; margin-bottom:0pt; padding:0px 0px 0px 0px;}
prompt h4 {font:8pt Arial; color:Black; background:White; border-bottom:2px solid #cccc99; margin-top:0pt; margin-bottom:0pt; padding:0px 0px 0px 0px;}
prompt th {font:10pt Arial; color:White; background:White; border-bottom:2px solid #cccc99; margin-top:0pt; margin-bottom:0pt; padding:4px 4px 2px 0px;}
prompt td {font:10pt Arial; color:Black; background:#F0F0F5; vertical-align:top;}
prompt a {font:bold 10pt Arial; color:Black; background:#F0F0F5; horizontal-align:right; vertical-align:top; margin-top:0pt; margin-bottom:0pt;}
prompt table.tdiff { border_collapse: collapse; }
prompt </style>
prompt </head>
prompt <body>
set markup html on entmap off
-- --------------------------------------------------------------------------------
prompt <h1>RAOCTL_HTML_REPORT_H1_TAG</h1>
-- --------------------------------------------------------------------------------
prompt  
prompt <a name="index"></a>
prompt <h2>INDEX</h2>
