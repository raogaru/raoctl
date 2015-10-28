# ############################################################
# CODE HTML FUNCTIONS
# ############################################################
# ------------------------------------------------------------
# CODE HELP actions
action_L1="gen_menu "
action_L2="xx "
action_L3="yy "
action_L="$action_L1 $action_L2 $action_L3"
# ------------------------------------------------------------
# USAGE DATA
usage_L=" \
gen_menu,raoctl_product,Generate_HTML_Menu_for_given_raoctl_Product_Name \
"
# ------------------------------------------------------------
# local variables
v_debug=0
# ------------------------------------------------------------
f_html_gen_menu () {
v_gen_class_html=0
v_gen_module_html=0
v_gen_action_html=0
INPUT
SQLNEWF
DEBUG "product_A: ${input}"
for v_product in ${input}
do
	SQLLINE "<ul>"
	DEBUG "Product=${v_product}"
	assign_classes
	DEBUG "class_A=${class_A[@]}"
	for v_class in ${class_A[@]}
	do
		c_href="htm/${v_product}.${v_class}.html"
		if [ $v_gen_class_html -eq 1 ];then
			echo "File = ${m_href}" >${RPT_DIR}/${c_href}
			echo "p=${v_product} c=${v_class} " >>${RPT_DIR}/${c_href}
		fi
		SQLLINE "<!-- ${cLINE1}-->"
		SQLLINE "\t<li class='active'><a href='${c_href}'>${v_class}</a>"
		SQLLINE "\t<ul>"
		DEBUG "Class=${v_class}"
		assign_modules
		DEBUG "module_A: ${module_A[@]}"
		for v_module in ${module_A[@]}
		do
			m_href="htm/${v_product}.${v_class}.${v_module}.html"
			if [ $v_gen_module_html -eq 1 ];then
				echo "File = ${m_href}" >${RPT_DIR}/${m_href}
				echo "p=${v_product} c=${v_class} m=${v_module} " >>${RPT_DIR}/${m_href}
			fi
			SQLLINE "<!-- ${cLINE2}-->"
			SQLLINE "\t\t<li>"
			SQLLINE "\t\t<a href='${m_href}'>${v_module}</a>"
			SQLLINE "\t\t<ul>"
			t_module_scr=${SCR_DIR}/${v_class}.${v_module}.sh
			if [ -f ${t_module_scr} ]; then
				. ${t_module_scr}
				DEBUG "Module=${v_module}"
	            assign_actions
				DEBUG "action_A: ${action_A[@]}"
				for v_action in ${action_A[@]}
				do
					a_href="htm/${v_product}.${v_class}.${v_module}.${v_action}.html"
					if [ $v_gen_action_html -eq 1 ];then
						echo "File = ${a_href}" >${RPT_DIR}/${a_href}
						echo "p=${v_product} c=${v_class} m=${v_module} a=${v_action}" >>${RPT_DIR}/${a_href}
					fi
					SQLLINE "\t\t\t<li><a href='${a_href}'>${v_action}</a></li>"
					DEBUG "Action=${v_action}"
				done
			else
				DEBUG  "module script NOT FOUND : ${t_module_scr}"
			fi
			SQLLINE "\t\t</ul>"
			SQLLINE "\t\t</li>"
			set -A action_A
		done
		SQLLINE "\t</ul>"
		set -A module_A
	done
	SQLLINE "</ul>"
	set -A class_A
done

cp $TMPSQL $RPT_DIR/x
cat ${SQL_DIR}/htmlmenu.tem \
	| sed -e "s/RAOCTL_HTML_REPORT_TITLE_TAG/RAOCTL ${v_product}/" \
	| sed -e "s/RAOCTL_HTML_REPORT_H1_TAG/Oracle Guru (under construction)/" \
	| sed -e "s/RAOCTL_HTML_REPORT_H2_TAG/RAOCTL ${v_product}/" \
	> ${TMPSQL}.2

cat ${TMPSQL}.2 ${TMPSQL} > ${RPT_DIR}/raoctl.${v_product}.html

echo "</div>" >> ${RPT_DIR}/raoctl.${v_product}.html
echo "</body>" >> ${RPT_DIR}/raoctl.${v_product}.html
echo "</html>" >> ${RPT_DIR}/raoctl.${v_product}.html

#	| sed "/RAOCTL_HTML_MENU_CONTENT_TAG/ { r $TMPSQL; d; }" >> ${RPT_DIR}/raoctl.${v_product}.html

}
# ------------------------------------------------------------
