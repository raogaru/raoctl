# ############################################################
# REPORT LIBRARY FUNCTIONS
# ############################################################
# ------------------------------------------------------------
## USAGE DATA
#set -A USAGE_DATA 
set -A A_h2_links
set -A A_h2_headers
set -A A_h3_details
# ------------------------------------------------------------
v_debug=0
# ------------------------------------------------------------
ADD_H2_LINK () {
	DEBUG "Adding to A_h2_links: \"$*\""
	set -A A_h2_links ${A_h2_links[*]} $(echo $*|sed -e 's/[ ]/_/g')
}
# ------------------------------------------------------------
ADD_H2_HEADER () {
	DEBUG "Adding to A_h2_headers: \"$*\""
	set -A A_h2_headers ${A_h2_headers[*]} $(echo $*|sed -e 's/[ ]/_/g')
}
# ------------------------------------------------------------
ADD_H3_DETAIL () {
	DEBUG "Adding to A_h3_details \"$*\""
	set -A A_h3_details ${A_h3_details[*]} $*
}
# ------------------------------------------------------------
# NOTES on f_html_report
# Input: 3 arguments: 1) html file name   2) HTML Window Title  3) HTML Report Header
# How to use?: 
#     Source RPT.lib.sh. 
#     ADD_H2_LINK, ADD_H2_HEADER, ADD_H3_DETAIL functions - for each section
#     Then call f_html_report with 3 arguments
#     Then call SQLEXEC or its equivalent
# ------------------------------------------------------------
f_html_report () {
if [ -z "$1" ]; then
	v_rptfile=${RPT_DIR}/test.html
else
	v_rptfile=${RPT_DIR}/${1}.html
fi
v_rpttitle="${2}"
v_rpthead="${3}"
v_rpttitle=${v_rpttitle:=RAOCTL HTML REPORT WINDOW TITLE}
v_rpthead=${v_rpthead:=RAOCTL HTML REPORT HEADER}

DEBUG "Report Filename=$v_rptfile"
DEBUG "Report Title=$v_rpttitle"
DEBUG "Report Header=$v_rpthead"

SQLNEWF
SQLLINE "spool ${v_rptfile}"
cat ${SQL_DIR}/htmlrep.sql \
	| sed -e "s/RAOCTL_HTML_REPORT_TITLE_TAG/${v_rpttitle}/" \
	| sed -e "s/RAOCTL_HTML_REPORT_H1_TAG/${v_rpthead}/" \
        >> ${TMPSQL}

# RAO
DEBUG A_h2_links : ${A_h2_links[*]}
DEBUG A_h2_headers: ${A_h2_headers[*]}
DEBUG A_h3_details: ${A_h3_details[*]}

# Print Report Index links
i=0 
while [ $i -lt ${#A_h2_links[*]} ]
do
	DEBUG "Links loop:  i=${i} A_h2_links[$i] = ${A_h2_links[$i]}"
	(( vGrpHref=1000+i*1000 ))
	SQLLINE "prompt <a href=\"#${vGrpHref}\">$(echo ${A_h2_links[$i]}|sed -e 's/_/ /g')</a>"
	(( i = i+1 ))
done
SQLLINE "-- ${cLINE5}"

# Print Report Details
i=0 
while [ $i -lt ${#A_h2_links[*]} ]
do
	(( vGrpHref=1000+i*1000 ))
	DEBUG "\n${cLINE4}\nHeaders loop i=${i} A_h2_headers[$i] = ${A_h2_headers[$i]}"
	SQLLINE "-- ${cLINE5}"
	SQLLINE "prompt <a name=\"${vGrpHref}\"></a><h2>$(echo ${A_h2_headers[$i]}|sed -e 's/_/ /g')</h2> <a href=\"#index\">Index </a>"
	SQLLINE ""
	set -A v_h3_token_A $(echo ${A_h3_details[$i]}|sed -e 's/,/ /g')
	if [ ${#v_h3_token_A[*]} -eq 0 ]; then
		ERROR "A_h3_details has less number of entries compared to A_h2_links"
	fi
	DEBUG "v_h3_token_A=${v_h3_token_A[*]}"
	j=0
	while [ $j -lt ${#v_h3_token_A[*]} ]
	do
		(( v_h3_href=1000+10+i*1000+j*10 ))
		t_h3_name=$(echo ${v_h3_token_A[$j]} | cut -f1 -d":")
		t_h3_sql=$(echo ${v_h3_token_A[$j]} | cut -f2 -d":")
		DEBUG "\t j=$j \n\tv_h3_string=${v_h3_token_A[$j]} \n\tt_h3_name=$t_h3_name \n\tt_h3_sql=$t_h3_sql \n\tv_h3_href=$v_h3_href"
		[[ -z "$t_h3_name" ]] && ERROR "t_h3_name is null"
		[[ -z "$t_h3_sql" ]] && ERROR "t_h3_sql is null"
		#SQLLINE "prompt <a name=\"${v_h3_href}\"></a><h3>${t_h3_name}</h3><a href=\"#${vGrpHref}\">GroupHeader</a>"
		SQLLINE "prompt <a name=\"${v_h3_href}\"></a><h3>$(echo ${A_h2_headers[$i]}|sed -e 's/_/ /g') :: $(echo ${t_h3_name}|sed -e 's/_/ /g')</h3>"
		SQLLINE "@${t_h3_sql}"
		SQLLINE "-- ${cLINE5}"
		(( j = j+1 ))
	done
	#fi
	(( i = i+1 ))
done
SQLLINE "-- ${cLINE5}"
SQLLINE "prompt END OF REPORT"
SQLLINE "prompt </body></html>"
SQLLINE "spool off"
}
# ------------------------------------------------------------
f_html_codehelp () {
v_debug=1
if [ -z "$1" ]; then
	v_rptfile=${RPT_DIR}/test.html
else
	v_rptfile=${RPT_DIR}/${1}.html
fi
v_rpttitle="${2}"
v_rpthead="${3}"
v_rpttitle=${v_rpttitle:=RAOCTL HTML REPORT WINDOW TITLE}
v_rpthead=${v_rpthead:=RAOCTL HTML REPORT HEADER}

DEBUG "Report Filename=$v_rptfile"
DEBUG "Report Title=$v_rpttitle"
DEBUG "Report Header=$v_rpthead"

SQLNEWF
cat ${SQL_DIR}/htmlhelp.css \
	| sed -e "s/RAOCTL_HTML_REPORT_TITLE_TAG/${v_rpttitle}/" \
	| sed -e "s/RAOCTL_HTML_REPORT_H1_TAG/${v_rpthead}/" \
        >> ${TMPSQL}

# RAO
DEBUG A_h2_links : ${A_h2_links[*]}
DEBUG A_h2_headers: ${A_h2_headers[*]}
DEBUG A_h3_details: ${A_h3_details[*]}

# Print Report Index links
i=0 
while [ $i -lt ${#A_h2_links[*]} ]
do
	DEBUG "Links loop:  i=${i} A_h2_links[$i] = ${A_h2_links[$i]}"
	(( vGrpHref=1000+i*1000 ))
	SQLLINE "<a href=\"#${vGrpHref}\">$(echo ${A_h2_links[$i]}|sed -e 's/_/ /g')</a>"
	(( i = i+1 ))
done
SQLLINE "<!-- ${cLINE1}-->"

# Print Report Details
i=0 
while [ $i -lt ${#A_h2_links[*]} ]
do
	(( vGrpHref=1000+i*1000 ))
	DEBUG "\n${cLINE4}\nHeaders loop i=${i} A_h2_headers[$i] = ${A_h2_headers[$i]}"
	SQLLINE "<a name=\"${vGrpHref}\"></a><h2>$(echo ${A_h2_headers[$i]}|sed -e 's/_/ /g')</h2> <a href=\"#index\">Index </a>"
	SQLLINE ""
	set -A v_h3_token_A $(echo ${A_h3_details[$i]}|sed -e 's/,/ /g')
	if [ ${#v_h3_token_A[*]} -eq 0 ]; then
		ERROR "A_h3_details has less number of entries compared to A_h2_links"
	fi
	DEBUG "v_h3_token_A=${v_h3_token_A[*]}"
	j=0
	while [ $j -lt ${#v_h3_token_A[*]} ]
	do
		(( v_h3_href=1000+10+i*1000+j*10 ))
		t_h3_name=$(echo ${v_h3_token_A[$j]} | cut -f1 -d":")
		t_h3_sql=$(echo ${v_h3_token_A[$j]} | cut -f2 -d":")
		DEBUG "\t j=$j \n\tv_h3_string=${v_h3_token_A[$j]} \n\tt_h3_name=$t_h3_name \n\tt_h3_sql=$t_h3_sql \n\tv_h3_href=$v_h3_href"
		[[ -z "$t_h3_name" ]] && ERROR "t_h3_name is null"
		[[ -z "$t_h3_sql" ]] && ERROR "t_h3_sql is null"
		#SQLLINE "<a name=\"${v_h3_href}\"></a><h3>${t_h3_name}</h3><a href=\"#${vGrpHref}\">GroupHeader</a>"
		SQLLINE "<a name=\"${v_h3_href}\"></a><h3>$(echo ${A_h2_headers[$i]}|sed -e 's/_/ /g') :: $(echo ${t_h3_name}|sed -e 's/_/ /g')</h3>"
		SQLLINE "@${t_h3_sql}"
		SQLLINE "<!-- ${cLINE1}-->"
		(( j = j+1 ))
	done
	#fi
	(( i = i+1 ))
done
SQLLINE "<!-- ${cLINE1}-->"
SQLLINE "END OF REPORT"
SQLLINE "</body></html>"
}
# ------------------------------------------------------------
f_html_menu () {
v_debug=0
if [ -z "$1" ]; then
	v_rptfile=${RPT_DIR}/test.html
else
	v_rptfile=${RPT_DIR}/${1}.html
fi
v_rpttitle="${2}"
v_rpthead="${3}"
v_rpttitle=${v_rpttitle:=RAOCTL HTML REPORT WINDOW TITLE}
v_rpthead=${v_rpthead:=RAOCTL HTML REPORT HEADER}

DEBUG "Report Filename=$v_rptfile"
DEBUG "Report Title=$v_rpttitle"
DEBUG "Report Header=$v_rpthead"

SQLNEWF
cat ${SQL_DIR}/htmlmenu.tem \
	| sed -e "s/RAOCTL_HTML_REPORT_TITLE_TAG/${v_rpttitle}/" \
	| sed -e "s/RAOCTL_HTML_REPORT_H1_TAG/${v_rpthead}/" \
        >> ${TMPSQL}

SQLLINE "<!-- ${cLINE1}-->"

# RAO
DEBUG A_h2_links : ${A_h2_links[*]}
DEBUG A_h2_headers: ${A_h2_headers[*]}
DEBUG A_h3_details: ${A_h3_details[*]}

# Print Report Index links
i=0 
while [ $i -lt ${#A_h2_links[*]} ]
do
	DEBUG "Links loop:  i=${i} A_h2_links[$i] = ${A_h2_links[$i]}"
	(( vGrpHref=1000+i*1000 ))
	SQLLINE "<a href=\"#${vGrpHref}\">$(echo ${A_h2_links[$i]}|sed -e 's/_/ /g')</a>"
	(( i = i+1 ))
done
SQLLINE "<!-- ${cLINE1}-->"

# Print Report Details
i=0 
while [ $i -lt ${#A_h2_links[*]} ]
do
	(( vGrpHref=1000+i*1000 ))
	DEBUG "\n${cLINE4}\nHeaders loop i=${i} A_h2_headers[$i] = ${A_h2_headers[$i]}"
	SQLLINE "<li class='active'><a href=#${A_h2_headers[$i]}>$(echo ${A_h2_headers[$i]}|sed -e 's/_/ /g')</a>"
	SQLLINE ""
	set -A v_h3_token_A $(echo ${A_h3_details[$i]}|sed -e 's/,/ /g')
	if [ ${#v_h3_token_A[*]} -eq 0 ]; then
		ERROR "A_h3_details has less number of entries compared to A_h2_links"
	fi
	DEBUG "v_h3_token_A=${v_h3_token_A[*]}"
	j=0
	while [ $j -lt ${#v_h3_token_A[*]} ]
	do
		(( v_h3_href=1000+10+i*1000+j*10 ))
		t_h3_name=$(echo ${v_h3_token_A[$j]} | cut -f1 -d":")
		t_h3_sql=$(echo ${v_h3_token_A[$j]} | cut -f2 -d":")
		DEBUG "\t j=$j \n\tv_h3_string=${v_h3_token_A[$j]} \n\tt_h3_name=$t_h3_name \n\tt_h3_sql=$t_h3_sql \n\tv_h3_href=$v_h3_href"
		[[ -z "$t_h3_name" ]] && ERROR "t_h3_name is null"
		[[ -z "$t_h3_sql" ]] && ERROR "t_h3_sql is null"
		#SQLLINE "<a name=\"${v_h3_href}\"></a><h3>${t_h3_name}</h3><a href=\"#${vGrpHref}\">GroupHeader</a>"
		SQLLINE "<a name=\"${v_h3_href}\"></a><h3>$(echo ${A_h2_headers[$i]}|sed -e 's/_/ /g') :: $(echo ${t_h3_name}|sed -e 's/_/ /g')</h3>"
		SQLLINE "@${t_h3_sql}"
		SQLLINE "<!-- ${cLINE1}-->"
		(( j = j+1 ))
	done
	#fi
	(( i = i+1 ))
done
SQLLINE "<!-- ${cLINE1}-->"
SQLLINE "END OF REPORT"
SQLLINE "</body></html>"
}
# ------------------------------------------------------------
