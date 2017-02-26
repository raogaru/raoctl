# ############################################################
# DEVOPS AMCHARTS CONFIG FUNCTIONS - Liquibase Database Deploymen Tool Installation
# ############################################################
# ------------------------------------------------------------
# AMCHARTS CONFIG actions
action_L1="sql csv json cmd "
action_L2=" "
action_L3=" "
action_L="$action_L1 $action_L2 $action_L3"
# ------------------------------------------------------------
# USAGE DATA
usage_L=" \
sql,sql_file_name,Collect_Data_From_DB_using_SQL_file \
csv,csv_data_file_name,Generate_HTML_using_input_CSV_data_file \
json,json_data_file_name,Generate_HTML_using_input_JSON_data_file \
cmd,command_string,run_shell_command_and_use_output \
"
# ------------------------------------------------------------
# Global variable overwrites
DEVOPS_HOME=${RAOHOME}/raogaru/devops
DEVOPS_CFG=${DEVOPS_HOME}/cfg
. ${DEVOPS_CFG}/devops.env
# ------------------------------------------------------------
# Module specific environment variables
rc_CHART_CATEGORY=rc_category
rc_CHART_VALUE=rc_value
rc_CHART_TEMPLATE_DIR=${DEVOPS_HOME}/amcharts/templates
#rc_CHART_HTML=${RPT_DIR}/AMCHARTS_REPORT_$(date +%Y%m%d_%H%M%S).html
RPT_DIR=${AMCHARTS_HOME}/reports
rc_CHART_HTML=${RPT_DIR}/r.html

# ------------------------------------------------------------
# Module specific common functions

# ------------------------------------------------------------
CollectDataFromDB () {
DEBUG "Collect Graph Data from DB - started"
v_sql_file=${1}
ECHO v_sqlfile=$v_sqlfile
SQLNEWF 
SQLLINE "set pagesi 0 linesi 2000 trims on echo off heading off feedback off verify off termout on serveroutput on size 10000"
#SQLLINE "@chart_${rc_CHART_TYPE}.sql"
SQLLINE "@${v_sql_file}"
SQLEXEC > ${TMPDAT}
DEBUG "Collect Graph Data from DB - completed"
DEBUG "Graph data CSV file ${TMPDAT}"
}
# ------------------------------------------------------------
ConvertToJsonFormat () {
DEBUG "Convert CSV data to Json format - started"
v_dat_file=${1}
r_num=0
r_comma=" "
cat ${v_dat_file}| while read x_input_data
do
	[[ $r_num -gt 0 ]] && r_comma=","
	echo -n "${r_comma}{"

	c_num=1
	c_comma=" "
	while [ $c_num -le $x_input_count ]
	do
		[[ $c_num -gt 1 ]] && c_comma=","
		echo -n ${c_comma} \"$(echo $x_input_names|cut -f${c_num} -d",")\":\"$(echo $x_input_data|cut -f${c_num} -d":")\" 
		((c_num=c_num+1))
	#-----------
	done
	echo  "}"
	((r_num=r_num+1))
done > ${TMPJSON}
DEBUG "Convert CSV data to Json format - complete"
DEBUG "chartData file is ${TMPJSON}"
}
# ------------------------------------------------------------
PrepareAmChartsHtml () {
DEBUG "Use template and insert core data - started"
v_json_file=${1}
cat ${rc_CHART_TEMPLATE_DIR}/${rc_CHART_TYPE}.html.tem | \
	sed -e "/RAOGARU_DEVOPS_AMCHARTS_DATA_BEGIN/r ${v_json_file}" \
	> ${rc_CHART_HTML}
	#sed -e "s/RAOGARU_DEVOPS_AMCHARTS_X_TITLE/${rc_CHART_X_AXIS}/" | \
	#sed -e "s/RAOGARU_DEVOPS_AMCHARTS_Y_TITLE/${rc_CHART_Y_AXIS}/" | \
	#sed -e "s/RAOGARU_DEVOPS_AMCHARTS_TITLE/${rc_CHART_TITLE}/" | \
DEBUG "Use template and insert core data - completed"
}
# ------------------------------------------------------------
f_report_common () {
rc_CHART_TITLE="My Chart Title"
rc_CHART_X_AXIS="My X-axis Title"
rc_CHART_Y_AXIS="My Y-axis Title"

CHKFILE ${rc_CHART_TEMPLATE_DIR}/${rc_CHART_TYPE}.html.tem

x_line=$(grep "^${rc_CHART_TYPE}:" ${CFG_DIR}/amcharts.cfg)
[[ -z $x_line ]] && ERROR "${rc_CHART_TYPE} not found in ${CFG_DIR}/amcharts.cfg file"

x_input_count=$(echo $x_line|cut -f2 -d":")
DEBUG "chartData should contain ${x_input_count} inputs"

x_input_names=$(echo $x_line|cut -f3 -d":")
DEBUG "chartData input names are ${x_input_names} "

}
# ------------------------------------------------------------
f_report_sql () {
INPUT 2
rc_CHART_TYPE=${input1}
CHKFILE ${input2}
f_report_common
CollectDataFromDB ${input2}
ConvertToJsonFormat ${TMPDAT}
PrepareAmChartsHtml ${TMPJSON}
ECHO "Report is ${rc_CHART_HTML}"
}
# ------------------------------------------------------------
f_report_csv () {
INPUT 2
rc_CHART_TYPE=${input1}
CHKFILE ${input2}
f_report_common
ConvertToJsonFormat ${input2}
PrepareAmChartsHtml ${TMPJSON}
ECHO "Report is ${rc_CHART_HTML}"
}
# ------------------------------------------------------------
f_report_json () {
INPUT 2
rc_CHART_TYPE=${input1}
CHKFILE ${input2}
f_report_common
PrepareAmChartsHtml ${input2}
ECHO "Report is ${rc_CHART_HTML}"
}
# ------------------------------------------------------------
f_report_cmd () {
ECHO "not coded yet"
}
# ------------------------------------------------------------
