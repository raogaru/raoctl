# ############################################################
# RAOCTL CODE - CRYPT FUNCTIONS
# ############################################################
# ------------------------------------------------------------
# CODE CRYPT actions
action_L1="product class module "
action_L2="usage "
action_L3="gen_module_man "
action_L="$action_L1 $action_L2 $action_L3"
# ------------------------------------------------------------
# USAGE DATA
usage_L=" \
class,class_name,check_for_module_scripts_and_help_files \
module,class_name:module_name,check_for_action_functions_and_help_files \
"
# ------------------------------------------------------------
# local variables

# ------------------------------------------------------------
f_crypt_product () {
INPUT
v_product=${input1}

DEBUG "product_A: ${input1}"
for v_product in ${input1}
do
	SQLLINE "<ul>"
	DEBUG "Product=${v_product}"
	assign_classes
	DEBUG "class_A=${class_L}"
	for v_class in ${class_L}
	do
		DEBUG "Class=${v_class}"
		assign_modules
		DEBUG "module_A: ${module_L}"
		for v_module in ${module_L}
		do
			t_module_scr=${SCR_DIR}/${v_class}.${v_module}.sh
			if [ -f ${t_module_scr} ]; then
				. ${t_module_scr}
				DEBUG "Module=${v_module}"
				assign_actions
				DEBUG "action_A: ${action_L}"
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
f_crypt_module () {
INPUT 2
ECHO "Code validation for class=${input1} module=${input2}"
v_class=${input1}
v_module=${input2}
#validate_class
assign_modules
validate_module
include_module_script
assign_actions
ECHO "action_A: ${action_A[@]}"
for t_action in ${action_A[@]}
do
# -- check for function definition
export v_function=f_${v_module}_${t_action}
typeset -f ${v_function} > /dev/null
[[ $? -ne 0 ]] && ECHO "action function ${v_function} not defined.!"
# -- check for help file
t_action_hlp=${MAN_DIR}/html/${v_class}.${v_module}.${t_action}.html
[[ ! -f ${t_action_hlp} ]] && ECHO  "action help file NOT FOUND : ${t_action_hlp}"
done
}
# ------------------------------------------------------------
