# ############################################################
# RAOCTL CODE VALIDATIONS - CHECK FUNCTIONS
# ############################################################
# ------------------------------------------------------------
# CODE CHECK actions
action_L1="class module usage gen_module_man "
action_L2="x "
action_L3="y "
action_L="$action_L1 $action_L2 $action_L3"
# ------------------------------------------------------------
# USAGE DATA
usage_L=" \
class,product_name:class_name,check_for_module_scripts_and_help_files \
module,class_name:module_name,check_for_action_functions_and_help_files \
"
# ------------------------------------------------------------
# local variables

# ------------------------------------------------------------
f_check_class () {
INPUT 2
v_product=${input1}
v_class=${input2}
ECHO "Code validation for product=${input1} class=${input2}"
#validate_class
assign_modules
ECHO "module_A: ${module_L}"
#.sh is module-script
#.des is manpage description file
#.1.gz is manpage file
#.htm is manpage html file
#.rcx is raoctl example file
#.rex is real sql example file
for t_module in ${module_L}
do
for x in ${SCR_DIR}/${v_class}.${t_module}.sh ${MSG_DIR}/${v_class}.${t_module}.des ${MAN_DIR}/html/${v_class}.${t_module}.html ${MSG_DIR}/${v_class}.${t_module}.syn ${MSG_DIR}/${v_class}.${t_module}.rcx ${MAN_DIR}/man1/${v_class}.${t_module}.1.gz 
do
[[ ! -f ${x} ]] && ECHO  "module=${v_module} File ${x} NOT FOUND"
done
done
}
# ------------------------------------------------------------
f_check_module () {
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
#t_action_hlp=${MAN_DIR}/html/${v_class}.${v_module}.${t_action}.html
#[[ ! -f ${t_action_hlp} ]] && ECHO  "action help file NOT FOUND : ${t_action_hlp}"
done
}
# ------------------------------------------------------------
f_check_usage () {
INPUT 2
ECHO "Code validation for class=${input1} module=${input2}"
v_class=${input1}
v_module=${input2}
assign_modules
validate_module
include_module_script
assign_actions
ECHO "action_A: ${action_A[@]}"
for u in ${USAGE_DATA[@]}
do
ECHO "$(echo ${u} | cut -f1 -d",")\t-i $(echo ${u} | cut -f2 -d",")\t $(echo ${u} | cut -f3 -d","|sed -e 's/[_]/ /g')"
#ECHO "${cLINE3}"
done
ECHO "${cLINE4}"
}
# ------------------------------------------------------------
