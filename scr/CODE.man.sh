# ############################################################
# RAOCTL CODE DOCUMENTATION - MAN PAGE FUNCTIONS
# ############################################################
# ------------------------------------------------------------
# CODE CHECK actions
action_L1="module "
action_L="$action_L1 $action_L2 $action_L3"
# ------------------------------------------------------------
# USAGE DATA
usage_L=" \
module,product_name:class_name:module_name,Generate_Man_page_for_given_class_and_module \
"
# ------------------------------------------------------------
# local variables
rc_CODE_gen_man_force=${rc_CODE_gen_man_force:=1}
rc_CODE_gen_html_force=${rc_CODE_gen_html_force:=1}
v_debug=0
# ------------------------------------------------------------
MANLINE () {
echo $* >> ${v_manfile}
}
# ============================================================
f_man_module () {
INPUT 3
ECHO "Generate Man page for product=${input1} class=${input2} module=${input3}"
v_product=${input1}
v_class=${input2}
v_module=${input3}
assign_modules
validate_module
include_module_script
assign_actions
# ----------
mkdir -p ${MAN_DIR}/man1
v_manfile=${MAN_DIR}/man1/${v_class}.${v_module}.1
[[ -f ${v_manfile} ]] && [[ ${rc_CODE_gen_man_force} = 0 ]] && ERROR "man file ${v_manfile} already exists"
[[ -f ${v_manfile}.gz ]] && [[ ${rc_CODE_gen_man_force} = 0 ]] && ERROR "man file ${v_manfile} already exists"
[[ -f ${v_manfile} ]] && DEBUG "Deleting existing man file ${v_manfile}" && rm -f ${v_manfile} ${v_manfile}
[[ -f ${v_manfile}.gz ]] && DEBUG "Deleting existing man file ${v_manfile}.gz" && rm -f ${v_manfile}.gz

MANLINE ".\\\" ${cLINE2}"
MANLINE ".\\\" raoctl man page for class=${v_class} module=${v_module}"
MANLINE ".\\\" ${cLINE2}"
MANLINE ".TH man 1 \"$(date)\" \"1.0\" \"raoctl man page\" "

MANLINE ".SH NAME"
MANLINE ".BR raoctl.${v_class}.${v_module}"

MANLINE ".SH SYNOPSIS"
MANLINE ".BR raoctl"
MANLINE "man page for class"
MANLINE ".BR ${v_class}"
MANLINE "module"
MANLINE ".BR ${v_module}"

MANLINE ".SH DESCRIPTION"
if [ -f ${MSG_DIR}/${v_class}.${v_module}.des ]; then
	DEBUG "using ${MSG_DIR}/${v_class}.${v_module}.des file"  
	cat ${MSG_DIR}/${v_class}.${v_module}.des >> ${v_manfile} 
else
	MANLINE "description file ${MSG_DIR}/${v_class}.${v_module}.des not found"
fi

MANLINE ".SH RAOCTL SYNTAX"
if [ -f ${MSG_DIR}/${v_class}.${v_module}.syn ]; then
	DEBUG "using ${MSG_DIR}/${v_class}.${v_module}.syn file"  
	cat ${MSG_DIR}/${v_class}.${v_module}.syn >> ${v_manfile} 
else
	MANLINE "raoctl example file not found"
fi

MANLINE ".SH COMMAND EXAMPLE"
if [ -f ${MSG_DIR}/${v_class}.${v_module}.rcx ]; then
	DEBUG "using ${MSG_DIR}/${v_class}.${v_module}.rcx file"  
	cat ${MSG_DIR}/${v_class}.${v_module}.rcx >> ${v_manfile} 
else
	MANLINE "command example file not found"
fi

MANLINE ".SH ACTIONS"

DEBUG "action_A: ${action_A[@]}"
for u in ${USAGE_DATA[@]}
do
ECHO "${cLINE3}"
ECHO "$(echo ${u} | cut -f1 -d",")\t-i $(echo ${u} | cut -f2 -d",")\t $(echo ${u} | cut -f3 -d","|sed -e 's/[_]/ /g')"
t_act=$(echo ${u} | cut -f1 -d",")
t_inp_A=$(echo ${u} | cut -f2 -d",")
t_desc=$(echo ${u} | cut -f3 -d","|sed -e 's/[_]/ /g')

MANLINE ".BR ${t_act}"
MANLINE "- ${t_desc}"
i=0
for t_inp in $(echo ${t_inp_A}|sed -e 's/:/ /g')
do
	(( i=i+1 ))
	MANLINE ".P"
	MANLINE "argument ${i} :"
	MANLINE ".I ${t_inp}"
done
MANLINE ".P"

done
ECHO "${cLINE4}"

MANLINE ".SH RAOCTL"
[[ -f ${MSG_DIR}/${v_class}.${v_module}.msg ]] && DEBUG "using ${MSG_DIR}/${v_class}.${v_module}.msg file"  && cat ${MSG_DIR}/${v_class}.${v_module}.msg >> ${v_manfile} 


MANLINE ".SH BUGS"
MANLINE "No known bugs"

MANLINE ".SH ENVIRONMENT"
MANLINE "Requires raoctl environment variables"

MANLINE ".SH FILES"
MANLINE "Shell script raoctl"
MANLINE ".P"
MANLINE "Shell script ${v_class}.${v_module}.sh"
MANLINE ".P"
MANLINE "HTML page ${v_class}.${v_module}.html"
MANLINE ".P"
MANLINE "Man page ${v_class}.${v_module}.1"

MANLINE ".SH AUTHOR"
MANLINE "Rao Vangaru ("
MANLINE ".I rao@oracle-guru.com"
MANLINE ")"

MANLINE ".SH COPYRIGHT"
MANLINE "Copyrights are reserved by Rao Vangaru and OracleGuru Inc."

MANLINE ".\\\" ${cLINE2}"

ECHO "Man page ${v_manfile} generated"

# compress man page
ECHO "gzip'ing of man file ..."
gzip -f ${v_manfile}
ls -l  ${v_manfile}*

# prepare .html file from man page file
typeset v_htmlfile=${MAN_DIR}/html/${v_class}.${v_module}.html
[[ -f ${v_htmlfile} ]] && [[ ${rc_CODE_gen_html_force} = 0 ]] && ERROR "HTML Man file ${v_htmlfile} already exists"
#[[ ${rc_CODE_gen_html_force} = 1 ]] && 
zcat ${v_manfile}.gz | groff -mandoc -Thtml > ${v_htmlfile}

}
# ------------------------------------------------------------
