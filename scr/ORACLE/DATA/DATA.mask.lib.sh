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
f_Prepare_SQL_from_REQ () {
[[ -z "${v_DATAMASK_REQ}" ]] && ERROR "v_DATAMASK_REQ not defined !"
[[ ! -f ${v_DATAMASK_REQ}.req ]] && ERROR "File ${v_DATAMASK_REQ}.req not found !"
i=0
SQLLINE "@${v_class_dir}/datamask/datamask.pre"
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
	DEBUG "#-----"

	case "${maskalg}" in
	# ----------------------------------------
	# NULL
	"FILL_NULL") valexpr="null" ;;

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
	# RANDOM POSTAL ADDRESS


	# ----------------------------------------
	# RANDOM NAMES


	# ----------------------------------------
	# 


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
	"BLOB_FIXED_SIZE") valexpr="to_blob(utl_raw.cast_to_raw(dbms_random.string('P',${valexpr})))" ;;
	# expect valexpr to have MMM,NNN format size precision from mmm to nnn
	"BLOB_VARIABLE_SIZE") valexpr="to_blob(utl_raw.cast_to_raw(dbms_random.string('P',round(dbms_random.value(${valexpr}),0))))" ;;

	# ----------------------------------------
	# DATE

	#"DATE_RANDOM") valexpr="to_date(trunc(dbms_random.value(to_char(DATE '1900-01-01','J'),to_char(DATE '3000-12-31','J'))),'J')" ;;
	"DATE_RANDOM") valexpr="round(sysdate)+round(dbms_random.value(-100*365,100*365),0)" ;;
	"DATE_FIXED") valexpr="to_date('${valexpr}','YYYY-MM-DD')" ;;
	"DATE_PAST") valexpr="trunc(sysdate-round(dbms_random.value(1,${valexpr}),0))" ;;
	"DATE_FUTURE") valexpr="trunc(sysdate+round(dbms_random.value(1,${valexpr}),0))" ;;

	"DATE_ADD_DD") valexpr="${colname}+${valexpr}" ;;
	"DATE_ADD_MM") valexpr="add_months(${colname},${valexpr})" ;;
	"DATE_ADD_YY") valexpr="add_months(${colname},${valexpr}*12)" ;;

	# ----------------------------------------
	# TIMESTAMP

	"TIME_RANDOM") valexpr="sysdate+dbms_random.value(-100*365,100*365)" ;;
	"TIME_FIXED") valexpr="to_timestamp('${valexpr}','YYYY-MM-DD HH24.MI.SS.FF')" ;;
	"TIME_PLUS_HH") valexpr="${colname}+(${valexpr}/24)" ;;
	"TIME_MINUS_HH") valexpr="${colname}-(${valexpr}/24)" ;;

	"TIME_PLUS_MI") valexpr="${colname}+(${valexpr}/24/60)" ;;
	"TIME_MINUS_MI") valexpr="${colname}-(${valexpr}/24/60)" ;;
	
	"TIME_PLUS_SS") valexpr="${colname}+(${valexpr}/24/60/60)" ;;
	"TIME_MINUS_SS") valexpr="${colname}-(${valexpr}/24/60/60)" ;;

	# ----------------------------------------
	# STRING

	"STR_FIXED_STRING") valexpr="'${valexpr}'" ;;
	"STR_FIXED_PREFIX") valexpr="'${valexpr}'||${colname}" ;;
	"STR_FIXED_SUFFIX") valexpr="${colname}||'${valexpr}'" ;;

	# expect valexpr in mmm,nnn format. for fixed length use mmm=nnn
	"STR_RANDOM_ALPHA_UPPER") valexpr="dbms_random.string('U',round(dbms_random.value(${valexpr}),0))" ;;
	"STR_RANDOM_ALPHA_LOWER") valexpr="dbms_random.string('L',round(dbms_random.value(${valexpr}),0))" ;;
	"STR_RANDOM_ALPHA_MIXED") valexpr="dbms_random.string('A',round(dbms_random.value(${valexpr}),0))" ;;
	"STR_RANDOM_ALPHANUM_MIXED") valexpr="dbms_random.string('X',round(dbms_random.value(${valexpr}),0))" ;;
	"STR_RANDOM_PRINTABLE_CHAR") valexpr="dbms_random.string('P',round(dbms_random.value(${valexpr}),0))" ;;

	# ----------------------------------------
	# NUMBER

	"NUM_FIXED") valexpr="${valexpr}" ;;
	"NUM_PLUS") valexpr="${colname}+${valexpr}" ;;
	"NUM_MINUS") valexpr="${colname}-${valexpr}" ;;

	# random integer with valexpr as number of digits
	"NUM_RANDOM_INTEGER_DIGITS") valexpr="round(dbms_random.value*power(10,${valexpr}),0)" ;;
	
	# expect valexpr to be in FROM,TO format
	"NUM_RANDOM_INTEGER_BETWEEN") valexpr="round(dbms_random.value(${valexpr}),0)" ;;

	# expect valexpr with PRECISION,SCALE format
	"NUM_RANDOM_DECIMAL")
		v_precision=$(echo ${valexpr}|cut -f1 -d",") 
		v_scale=$(echo ${valexpr}|cut -f2 -d",")
		valexpr="round(dbms_random.value*power(10,${v_precision}),${v_scale})" 
		;;

	# ----------------------------------------
	# ANYDATA

	"ANYDATA_TYPE_NULL") valexpr="SYS.ANYDATA.convertCHAR('')" ;;

	"ANYDATA_TYPE_MASK") valexpr="(
CASE sys.anydata.getTypeName(${colname})
WHEN 'CHAR'     THEN sys.anydata.convertCHAR(dbms_random.string('X',10))
WHEN 'VARCHAR2' THEN sys.anydata.convertVARCHAR2(dbms_random.string('X',round(dbms_random.value(10,50),0)))
WHEN 'NUMBER'   THEN sys.anydata.convertNUMBER(round(dbms_random.value(1000000,2000000),2))
WHEN 'DATE'     THEN sys.anydata.convertDATE(trunc(sysdate+dbms_random.value(0,366)))
WHEN 'TIMESTAMP'  THEN sys.anydata.convertTIMESTAMP(systimestamp+dbms_random.value(0,366))
WHEN 'CLOB'     THEN sys.anydata.convertCLOB(dbms_random.string('X',round(dbms_random.value(10,50),0)))
WHEN 'BLOB'     THEN sys.anydata.convertBLOB(to_blob(utl_raw.cast_to_raw(dbms_random.string('P',round(dbms_random.value(100,500),0)))))
WHEN 'RAW'      THEN sys.anydata.convertRAW(utl_raw.cast_to_raw(dbms_random.string('P',round(dbms_random.value(100,500),0))))
WHEN 'OBJECT'   THEN sys.anydata.convertOBJECT(T21_ANYDATA_emp_TYP('E','FirstName LastName',123, sysdate, systimestamp))
ELSE null
END
)" ;;

	# ----------------------------------------
	# CUSTOM FILEDS



	# ----------------------------------------
	esac

SQLLINE @${v_class_dir}/datamask/datamask.pls \"${rc_DATAMASK_SCHEMA}\" \"${tabname}\" \"${colname}\" \"${valexpr}\" \"${ifcond}\"
done
SQLLINE "@${v_class_dir}/datamask/datamask.pst"
}
