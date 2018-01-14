# ############################################################
# RAOCTL CODE - CONFIG FUNCTIONS
# ############################################################
# ------------------------------------------------------------
# CODE CONFIG actions
action_L1="list p_list c_list m_list a_list  "
action_L2="p_enable p_disable c_enable c_disable m_enable m_disable a_enable a_disable  "
action_L3="ppp "
action_L="$action_L1 $action_L2 $action_L3"
# ------------------------------------------------------------
# USAGE DATA
usage_L=" \
p_list,product_name,check_for_module_scripts_and_help_files \
c_list,product,check_for_module_scripts_and_help_files \
m_list,product:class,check_for_action_functions_and_help_files \
a_list,class_name:module_name,check_for_action_functions_and_help_files \
"
# ------------------------------------------------------------
# local variables

# ------------------------------------------------------------
f_config_EXAMPLE () { # example code to walk through p,c,m,a
INPUT
product_L=$(GETCFG 2 raoctl.product.list)
DEBUG "product_L: ${product_L}"
for v_product in ${product_L}
do
	DEBUG "Product=${v_product}"
	assign_classes
	DEBUG "class_L=${class_L}"
	for v_class in ${class_L}
	do
		DEBUG "Class=${v_class}"
		assign_modules
		DEBUG "module_L: ${module_L}"
		for v_module in ${module_L}
		do
			t_module_scr=${SCR_DIR}/${v_class}.${v_module}.sh
			if [ -f ${t_module_scr} ]; then
				. ${t_module_scr}
				DEBUG "Module=${v_module}"
				assign_actions
				DEBUG "action_L: ${action_L}"
				for v_action in ${action_L}
				do
					DEBUG "Action=${v_action}"
					echo "p=${v_product} c=${v_class} m=${v_module} a=${v_action}" 
				done
			else
				DEBUG  "module script NOT FOUND : ${t_module_scr}"
			fi
			action_L=""
		done
		module_L=""
	done
	class_L=""
done
}
# ------------------------------------------------------------
f_config_list () {
INPUT
v_list_type=${input1}
[[ ! "${v_list_type}" = @(p|c|m|a) ]] && ERROR "Valid values are p|c|m|a"
product_L=$(GETCFG 2 raoctl.product.list)
DEBUG "product_L: ${product_L}"
for v_product in ${product_L}
do
	ECHO "LIST_PRODUCT: ${v_product}"
	[[ "${v_list_type}" = "p" ]] && continue
	DEBUG "Product=${v_product}"
	assign_classes
	DEBUG "class_L=${class_L}"
	for v_class in ${class_L}
	do
		ECHO "LIST_CLASS: ${v_product}:${v_class}"
		[[ "${v_list_type}" = "c" ]] && continue
		DEBUG "Class=${v_class}"
		assign_modules
		DEBUG "module_L: ${module_L}"
		for v_module in ${module_L}
		do
			ECHO "LIST_MODULE: ${v_product}:${v_class}:${v_module}"
			[[ "${v_list_type}" = "m" ]] && continue
			t_module_scr=${SCR_DIR}/${v_class}.${v_module}.sh
			if [ -f ${t_module_scr} ]; then
				. ${t_module_scr}
				DEBUG "Module=${v_module}"
				assign_actions
				DEBUG "action_L: ${action_L}"
				for v_action in ${action_L}
				do
					DEBUG "Action=${v_action}"
					ECHO "${v_product}:${v_class}:${v_module}:${v_action}" 
				done
			else
				DEBUG  "module script NOT FOUND : ${t_module_scr}"
			fi
			action_L=""
		done
		#fi
		module_L=""
	done
	class_L=""
done
}
# ------------------------------------------------------------
