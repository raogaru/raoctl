#
# DATA.mask.lib.sh
#

v_MASK_TRANSLATE_NUMERIC="'0123456789','5307168942'"
v_MASK_TRANSLATE_ALPHA_UPPER="'ABCDEFGHIJKLMNOPQRSTUVWXYZ','OPKQSTFUVWMXZRYBEGAHIDJLNC'"
v_MASK_TRANSLATE_ALPHA_LOWER="'abcdefghijklmnopqrstuvwxyz','kstfuopvqwmxrybegzhdjlnaci'"
v_MASK_TRANSLATE_ALPHA_MIXED="'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz','OPKQSTFUVWMXZRYBEGAHIDJLNCkstfuopvqwmxrybegzhdjlnaci'"

v_MASK_TRANSLATE_ALPHANUM_UPPER="'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789','OPKQSTFUVWMXZRYBEGAHIDJLNC5307168942'"
v_MASK_TRANSLATE_ALPHANUM_LOWER="'abcdefghijklmnopqrstuvwxyz0123456789','kstfuopvqwmxrybegzhdjlnaci5307168942'"
v_MASK_TRANSLATE_ALPHANUM_MIXED="'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789','OPKQSTFUVWMXZRYBEGAHIDJLNCkstfuopvqwmxrybegzhdjlnaci5307168942'"

v_MASK_TRANSLATE_SPECIAL_CHAR="'~!@#$%^&*()_+-={}|[]\:;<>?,./','~$%^*@)+-&={(!|_[]:}#;<?,./\>'"

# ----------------------------------------------------------------------
TOFILE () {
ECHO "$*" >> ${v_MAIN_DATAMASK_RUN}
}
# ----------------------------------------------------------------------
f_Prepare_SQL_from_REQ () {
[[ -z "${v_DATAMASK_REQ}" ]] && ERROR "v_DATAMASK_REQ not defined !"
[[ ! -f ${v_DATAMASK_REQ}.req ]] && ERROR "File ${v_DATAMASK_REQ}.req not found !"
i=0
TOFILE "@${v_class_dir}/datamask/pre_datamask_run.sql"
cat ${v_DATAMASK_REQ}.req |grep -v "^#" | grep -v "^$" | while read line
do
	(( i=i+1 ))
	DEBUG "Processing #${i}"
	
	maskalg=$(echo ${line} | cut -f1 -d":")
	[[ -z "${maskalg}" ]] && ERROR "Invalid mask type"
	DEBUG "Masking Type : ${maskalg}"

	tabname=$(echo ${line} | cut -f2 -d":")
	[[ -z "${tabname}" ]] && ERROR "Invalid table name "
	DEBUG "Table Name   : ${tabname}"

	colname=$(echo ${line} | cut -f3 -d":")
	[[ -z "${colname}" ]] && ERROR "Invalid column name "
	DEBUG "Column Name  : ${colname}"

	valexpr=$(echo ${line} | cut -f4 -d":")
	DEBUG "Value Expression : ${valexpr}"

	ifcond=$(echo ${line} | cut -f5 -d":")
	[[ -z "${ifcond}" ]] && ifcond="1=1"
	DEBUG "If Condition : ${ifcond}"

	# ----------------------------------------
#	case "${maskalg}" in
#	"1") scrname="generic" ;;
#	"2") scrname="const" ;;
#	"3") scrname="text" ;;
#	"4") scrname="usrid" ;;
#	"5") scrname="genchr" ;;
#	"6") scrname="gennum" ;;
#	"7") scrname="genchrif" ;;
#	"8") scrname="textif" ;;
#	  *) scrname="generic" ;;
#	esac

	case "${maskalg}" in
	# ----------------------------------------
	# SSN - SOCIAL SECURITY NUMBER

	"SSN_HASH_ALL") valexpr="'###-##-####'" ;;
	"SSN_HASH_LAST_4") valexpr="substr(${colname},1,7)||'####'" ;;
	"SSN_HASH_LAST_5") valexpr="substr(${colname},1,5)||'#-####'" ;;
	"SSN_HASH_LAST_6") valexpr="substr(${colname},1,4)||'##-####'" ;;

	"SSN_STAR_ALL") valexpr="'***-**-****'" ;;
	"SSN_STAR_LAST_4") valexpr="substr(${colname},1,7)||'****'" ;;
	"SSN_STAR_LAST_5") valexpr="substr(${colname},1,5)||'*-****'" ;; 
	"SSN_STAR_LAST_6") valexpr="substr(${colname},1,4)||'**-****'" ;;

	"SSN_MASK_ALL") valexpr="translate(${colname},${v_MASK_TRANSLATE_NUMERIC})" ;;
	"SSN_MASK_LAST_4") valexpr="substr(${colname},1,7)||translate(substr(${colname},8,4),${v_MASK_TRANSLATE_NUMERIC})" ;;
	"SSN_MASK_LAST_5") valexpr="substr(${colname},1,5)||translate(substr(${colname},6,6),${v_MASK_TRANSLATE_NUMERIC})" ;;
	"SSN_MASK_LAST_6") valexpr="substr(${colname},1,4)||translate(substr(${colname},5,7),${v_MASK_TRANSLATE_NUMERIC})" ;;

	# ----------------------------------------
	# CC - VISA CREDIT CARD

	"CC_VISA_HASH_ALL") valexpr="'####-####-####-####'" ;;
	"CC_VISA_HASH_LAST_4") valexpr="substr(${colname},1,15)||'####'" ;;
	"CC_VISA_HASH_LAST_6") valexpr="substr(${colname},1,12)||'##-####'" ;;
	"CC_VISA_HASH_LAST_8") valexpr="substr(${colname},1,10)||'####-####'" ;;

	"CC_VISA_STAR_ALL") valexpr="'****-****-****-****'" ;;
	"CC_VISA_STAR_LAST_4") valexpr="substr(${colname},1,15)||'****'" ;;
	"CC_VISA_STAR_LAST_6") valexpr="substr(${colname},1,12)||'**-****'" ;;
	"CC_VISA_STAR_LAST_8") valexpr="substr(${colname},1,10)||'****-****'" ;;

	"CC_VISA_MASK_ALL") valexpr="translate(${colname},${v_MASK_TRANSLATE_NUMERIC})" ;;
	"CC_VISA_MASK_LAST_4") valexpr="substr(${colname},1,15)||translate(substr(${colname},16,4),${v_MASK_TRANSLATE_NUMERIC})" ;;
	"CC_VISA_MASK_LAST_6") valexpr="substr(${colname},1,12)||translate(substr(${colname},13,7),${v_MASK_TRANSLATE_NUMERIC})" ;;
	"CC_VISA_MASK_LAST_8") valexpr="substr(${colname},1,10)||translate(substr(${colname},11,9),${v_MASK_TRANSLATE_NUMERIC})" ;;

	# ----------------------------------------
	# CC - AMEX CREDIT CARD

	"CC_AMEX_HASH_ALL") valexpr="'####-######-#####'" ;;
	"CC_AMEX_HASH_LAST_5") valexpr="substr(${colname},1,12)||'#####'" ;;
	"CC_AMEX_HASH_LAST_8") valexpr="substr(${colname},1,8)||'###-####'" ;;
	"CC_AMEX_HASH_LAST_11") valexpr="substr(${colname},1,5)||'######-####'" ;;

	"CC_AMEX_STAR_ALL") valexpr="'****-******-*****'" ;;
	"CC_AMEX_STAR_LAST_5") valexpr="substr(${colname},1,12)||'*****'" ;;
	"CC_AMEX_STAR_LAST_8") valexpr="substr(${colname},1,8)||'***-****'" ;;
	"CC_AMEX_STAR_LAST_11") valexpr="substr(${colname},1,5)||'******-****'" ;;

	"CC_AMEX_MASK_ALL") valexpr="translate(${colname},${v_MASK_TRANSLATE_NUMERIC})" ;;
	"CC_AMEX_MASK_LAST_5") valexpr="substr(${colname},1,12)||translate(substr(${colname},13,5),${v_MASK_TRANSLATE_NUMERIC})" ;;
	"CC_AMEX_MASK_LAST_8") valexpr="substr(${colname},1,8)||translate(substr(${colname},9,9),${v_MASK_TRANSLATE_NUMERIC})" ;;
	"CC_AMEX_MASK_LAST_11") valexpr="substr(${colname},1,5)||translate(substr(${colname},6,12),${v_MASK_TRANSLATE_NUMERIC})" ;;
	# ----------------------------------------
	# PHONE NUMBERS

	"PHONE_HASH_ALL") valexpr="translate(${colname},'0123456789','##########')" ;;
	"PHONE_HASH_LAST_4") valexpr="substr(${colname},1,length(${colname})-4)||'####'" ;;
	"PHONE_HASH_LAST_7") valexpr="substr(${colname},1,length(${colname})-8)||'###-####'" ;;

	"PHONE_STAR_ALL") valexpr="translate(${colname},'0123456789','**********')" ;;
	"PHONE_STAR_LAST_4") valexpr="substr(${colname},1,length(${colname})-4)||'****'" ;;
	"PHONE_STAR_LAST_7") valexpr="substr(${colname},1,length(${colname})-8)||'***-****'" ;;

	"PHONE_MASK_ALL") valexpr="translate(${colname},${v_MASK_TRANSLATE_NUMERIC})" ;;
	"PHONE_MASK_LAST_4") valexpr="substr(${colname},1,length(${colname})-4)||translate(substr(${colname},-4,4),${v_MASK_TRANSLATE_NUMERIC})" ;;
	"PHONE_MASK_LAST_7") valexpr="substr(${colname},1,length(${colname})-8)||translate(substr(${colname},-8,8),${v_MASK_TRANSLATE_NUMERIC})" ;;

	# ----------------------------------------
	# DOB - DATE OF BIRTH


	# ----------------------------------------
	# CLOB

	"CLOB_NULL") valexpr="empty_clob()" ;;
	# clob size of value
	"CLOB_FIXED_SIZE") valexpr="dbms_random.string('X',${valexpr})" ;;
	# expect valexpr to have MMM,NNN format size precision from mmm to nnn
	"CLOB_VARIABLE_SIZE") valexpr="dbms_random.string('X',round(dbms_random.value(${valexpr}),0))" ;;

	# ----------------------------------------
	# BLOB

	"BLOB_NULL") valexpr="empty_blob()" ;;
	# blob size of value
	"BLOB_RANDOM_FIXED_SIZE") valexpr="dbms_random.string('P',${valexpr})" ;;
	# expect valexpr to have MMM,NNN format size precision from mmm to nnn
	"BLOB_RANDOM_VARIABLE_SIZE") valexpr="dbms_random.string('P',round(dbms_random.value(${valexpr}),0))" ;;


	# ----------------------------------------
	# DATE

	"DATE_RANDOM") valexpr="to_date(trunc(dbms_random.value(to_char(DATE '1900-01-01','J'),to_char(DATE '3000-12-31','J'))),'J')" ;;
	"DATE_FIXED") valexpr="to_date('${valexpr}','YYYY-MM-DD')" ;;
	"DATE_PAST") valexpr="trunc(sysdate-round(dbms_random.value(1,${valexpr}),0))" ;;
	"DATE_FUTURE") valexpr="trunc(sysdate+round(dbms_random.value(1,${valexpr}),0))" ;;

	"DATE_ADD_DD") valexpr="${colname}+${valexpr}" ;;
	"DATE_ADD_MM") valexpr="add_months(${colname},${valexpr})" ;;
	"DATE_ADD_YY") valexpr="add_months(${colname},${valexpr}*12)" ;;

	# ----------------------------------------
	# TIMESTAMP

	"TIME_RANDOM") valexpr="to_date(dbms_random.value(to_char(DATE '1900-01-01','J'),to_char(DATE '3000-12-31','J')),'J')" ;;
	"TIME_SAME_DAY") valexpr="to_char(TIMESTAMP dbms_random.value(trunc(${colname}),trunc(${colname})+1))" ;;

	# ----------------------------------------
	# STRING

	"STR_FIXED_STRING") valexpr="'${valexpr}'" ;;

	# generate random values for a given length
	"STR_RANDOM_ALPHA_UPPER") valexpr="dbms_random.string('U',${valexp})" ;;
	"STR_RANDOM_ALPHA_LOWER") valexpr="dbms_random.string('L',${valexp})" ;;
	"STR_RANDOM_ALPHA_MIXED") valexpr="dbms_random.string('A',${valexp})" ;;
	"STR_RANDOM_ALPHANUM_MIXED") valexpr="dbms_random.string('X',${valexp})" ;;
	"STR_RANDOM_PRINTABLE_CHAR") valexpr="dbms_random.string('P',${valexp})" ;;

	"STR_FIXED_PREFIX") valexpr="'${valexpr}||${colname}'" ;;
	"STR_FIXED_SUFFIX") valexpr="${colname}||'${valexpr}'" ;;

	# ----------------------------------------
	# NUMBER

	"NUM_FIXED") valexpr="${valexpr}" ;;
	"NUM_ADD") valexpr="${colname}+${valexpr}" ;;
	"NUM_SUBSTRACT") valexpr="${colname}-${valexpr}" ;;
	"NUM_MULTIPLY") valexpr="${colname}*${valexpr}" ;;
	"NUM_DIVIDE") valexpr="${colname}/${valexpr}" ;;

	# expect valexpr to be the power of 10
	"NUM_RANDOM_INTEGER") valexpr="round(dbms_random.value*power(10,${valexpr}),0)" ;;
	
	# expect valexpr to be in MMMM,NNNN format
	"NUM_RANDOM_INTEGER_BETWEEN") valexpr="round(dbms_random.value(${valexpr}),0)" ;;

	# expect valexpr with PRECISION,SCALE format
	"NUM_RANDOM_DECIMAL")
		v_precision=$(echo ${valexpr}|cut -f1 -d",") 
		v_scale=$(echo ${valexpr}|cut -f2 -d",")
		valexpr="round(dbms_random.value*power(10,${v_precision}),${v_scale})" 
		;;

	# expect valexpr with PRECISION,SCALE format
	"NUM_RANDOM_DECIMAL_BETWEEN") 
		v_precision=$(echo ${valexpr}|cut -f1 -d",") 
		v_scale=$(echo ${valexpr}|cut -f2 -d",")
		valexpr="-round(dbms_random.value*power(10,${v_precision}),${v_scale})" 
		;;

	# ----------------------------------------
	# GENERAL EXPRESSION

	# ----------------------------------------
	esac

TOFILE @${v_class_dir}/datamask/datamask.pls \"${tabname}\" \"${colname}\" \"${valexpr}\" \"${ifcond}\"
done
TOFILE "@${v_class_dir}/datamask/pst_datamask_run.sql"
}
