# ############################################################
# DATA GENERATE Random Schema Tables+Data
# ############################################################
# ------------------------------------------------------------
# DATA GENERATE actions
action_L1="show_cfg create drop"
action_L2="yy "
action_L3="zz "
action_L="$action_L1 $action_L2 $action_L3"
# ------------------------------------------------------------
# USAGE DATA
usage_L=" \
show_cfg,none,Show_Confguration \
create,none,Create_Scripts_for_Random_Schema_Tables_and_Data \
drop,none,Drop_Random_Schema_Tables \
"
# ------------------------------------------------------------
# Global variable overwrites
rc_RANDOM_SCHEMA_NAME=${rc_RANDOM_SCHEMA_NAME:=RAO}	# need N tables
rc_RANDOM_SCHEMA_TABLE_COUNT=${rc_RANDOM_SCHEMA_TABLE_COUNT:=10}	# need N tables
rc_RANDOM_COLUMN_COUNT_RANGE=${rc_RANDOM_COLUMN_COUNT_RANGE:=4,20}	# table with M to N columns
rc_RANDOM_ROWCOUNT=${rc_RANDOM_ROWCOUNT:=1000}
rc_RANDOM_SCHEMA_TABLE_PREFIX=${rc_RANDOM_SCHEMA_TABLE_PREFIX:=T}
rc_RANDOM_SCHEMA_COLUMN_PREFIX=${rc_RANDOM_SCHEMA_COLUMN_PREFIX:=C}
rc_RANDOM_SCHEMA_SCRIPT_ONLY=${rc_RANDOM_SCHEMA_SCRIPT_ONLY:=YES}
rc_RANDOM_SCHEMA_CREATE_SCRIPT=${rc_RANDOM_SCHEMA_CREATE_SCRIPT:=${TMP}/cre.sql}
rc_RANDOM_SCHEMA_INSERT_SCRIPT=${rc_RANDOM_SCHEMA_INSERT_SCRIPT:=${TMP}/ins.sql}
rc_RANDOM_SCHEMA_DROP_SCRIPT=${rc_RANDOM_SCHEMA_DROP_SCRIPT:=${TMP}/drp.sql}
rc_RANDOM_SCHEMA_DML_SCRIPT=${rc_RANDOM_SCHEMA_DML_SCRIPT:=${TMP}/dml.sql}

mkdir -p ${TMP}/dml
rm -f ${TMP}/dml/*.sql
rm -f ${rc_RANDOM_SCHEMA_CREATE_SCRIPT}
rm -f ${rc_RANDOM_SCHEMA_INSERT_SCRIPT}

# ------------------------------------------------------------
# Module specific environment variables
vColumnCount=0

# ------------------------------------------------------------
# Module specific common functions

# ------------------------------------------------------------
TableScript () {
echo "$*" >> ${rc_RANDOM_SCHEMA_CREATE_SCRIPT}
}
# ------------------------------------------------------------
InsertScript () {
echo "$*" >> ${rc_RANDOM_SCHEMA_INSERT_SCRIPT}
}
# ------------------------------------------------------------
DropScript () {
echo "$*" >> ${rc_RANDOM_SCHEMA_DROP_SCRIPT}
}
# ------------------------------------------------------------
DmlScript () {
echo "$*" >> ${rc_RANDOM_SCHEMA_DML_SCRIPT}
}
# ------------------------------------------------------------
# validate configuration

[[ ${rc_RANDOM_SCHEMA_TABLE_COUNT} -lt 1 || ${rc_RANDOM_SCHEMA_TABLE_COUNT} -gt 1000 ]] && ERROR "rc_RANDOM_SCHEMA_TABLE_COUNT must be set between 1 to 1000"

rc_RANDOM_COLUMN_COUNT_MIN=$(echo $rc_RANDOM_COLUMN_COUNT_RANGE | cut -f1 -d",")	# mininum number of columns
[[ ${rc_RANDOM_COLUMN_COUNT_MIN} -lt 1 ]] && ERROR "set rc_RANDOM_COLUMN_COUNT_RANGE low value cannot be less than 1"

rc_RANDOM_COLUMN_COUNT_MAX=$(echo $rc_RANDOM_COLUMN_COUNT_RANGE | cut -f2 -d",") 	# maximum number of columns
[[ ${rc_RANDOM_COLUMN_COUNT_MAX} -gt 255 ]] && ERROR "rc_RANDOM_COLUMN_COUNT_RANGE high value cannot be more than 255"

[[ ${rc_RANDOM_ROWCOUNT} -lt 1 || ${rc_RANDOM_ROWCOUNT} -gt 10000000000 ]] && ERROR "rc_RANDOM_ROWCOUNT  must be between 1 and 1000,000,000"

rc_RANDOM_SCHEMA_CREATE_SCRIPT=${rc_RANDOM_SCHEMA_CREATE_SCRIPT:=${TMP}/cre.sql}
rc_RANDOM_SCHEMA_INSERT_SCRIPT=${rc_RANDOM_SCHEMA_INSERT_SCRIPT:=${TMP}/ins.sql}
rc_RANDOM_SCHEMA_DROP_SCRIPT=${rc_RANDOM_SCHEMA_DROP_SCRIPT:=${TMP}/drp.sql}

# ------------------------------------------------------------
fAddColumns () {
iColumn=0
while [ $iColumn -lt $vColumnCount ]
do
	(( iColumn=iColumn+1 ))
	DEBUG "Adding column# ${rc_RANDOM_SCHEMA_COLUMN_PREFIX}${iColumn}"
	
	x=$(( $RANDOM % 16 ))			# randomly assign data type - 16 different so far
	case $x in 
	0) # Integer
		vDataType="INTEGER"
		vColValues="round(dbms_random.value*power(10,8),0)"
	;;
	1) # number without precision or scale
		vDataType="NUMBER"
		vColValues="round(dbms_random.value*power(10,8),0)"
	;;
	2) # number with precision
		p=$(( $RANDOM % 38 + 1 )) 	# randomly find precisio for NUMBER data type
		vDataType="NUMBER($p)"
		vColValues="round(dbms_random.value*power(10,((${p}-1))),0)" 
	;;
	3) # number with precision,scale
		p=$(( $RANDOM % 20 + 1 )) 	# randomly find precisio for NUMBER data type
		s=$(( $RANDOM % 10 + 1 ))  	# randomly find scale for NUMBER data type
		vDataType="NUMBER($p,$s)"
		vColValues="round(dbms_random.value*power(10,((${p}-${s}-1))),${s})"
	;;
	4) # CHAR data type - defaults to size 1 - always not null
		vDataType="CHAR not null"
		vColValues="dbms_random.string('U',1)"
	;;
	5) # CHAR data type with length
		y=$(( $RANDOM % 10 + 1 )) 	# randomly find length for CHAR data type
		vDataType="CHAR($y)"
		vColValues="dbms_random.string('U',$y)"
	;;
	6) # VARCHAR2 data type with length between 1 and 95 with 5 increment
		y=$(( $RANDOM % 20 + 1 )) 	# randomly find length for VARCHAR2 data type
		z=$(( $y * 5 )) 	
		vDataType="VARCHAR2($z)"
		vColValues="dbms_random.string('X',$z)"
	;;
	7) # VARCHAR2 data type with length 100, 200, 300 .... 2000
		y=$(( $RANDOM % 20 + 1)) 	# randomly find length for VARCHAR2 data type
		z=$(( $y * 100 )) 	
		vDataType="VARCHAR2($z)"
		vColValues="dbms_random.string('X',$z)"
	;;
	8) # DATE data type
		vDataType="DATE"
		vColValues="round(sysdate)+round(dbms_random.value(-100*365,100*365),0)" 
	;;
	9) # DATE data type with SYSDATE default 
		vDataType="DATE default sysdate not null"
		vColValues="round(sysdate)+round(dbms_random.value(-100*365,100*365),0)" 
	;;
	10) # DATE data type with not null
		vDataType="DATE not null"
		vColValues="round(sysdate)+round(dbms_random.value(-100*365,100*365),0)" 
	;;
	11) # TIMESTAMP data type 
		vDataType="TIMESTAMP"
		vColValues="sysdate+dbms_random.value(-100*365,100*365)"
	;;
	12) # TIMESTAMP data type with SYSTIMTSTAMP default 
		vDataType="TIMESTAMP default systimestamp not null"
		vColValues="sysdate+dbms_random.value(-100*365,100*365)"
	;;
	13) # TIMESTAMP data type with not null
		vDataType="TIMESTAMP not null"
		vColValues="sysdate+dbms_random.value(-100*365,100*365)"
	;;
	14) # CLOB
		vDataType="CLOB"
		vColValues="dbms_random.string('X',round(dbms_random.value(100,1000),0))"
	;;
	15) # BLOB
		vDataType="BLOB"
		vColValues="to_blob(utl_raw.cast_to_raw(dbms_random.string('P',round(dbms_random.value(100,1000),0))))"
	;;
	esac
	TableScript ",${rc_RANDOM_SCHEMA_COLUMN_PREFIX}${iColumn} ${vDataType}"
	InsertScript ",/*${rc_RANDOM_SCHEMA_COLUMN_PREFIX}${iColumn}*/ ${vColValues}"
	DmlScript "update ${rc_RANDOM_SCHEMA_TABLE_PREFIX}${iTable} set ${rc_RANDOM_SCHEMA_COLUMN_PREFIX}${iColumn} = ${vColValues} where id = round(dbms_random.value(1,${rc_RANDOM_ROWCOUNT}),0);"
	mv ${rc_RANDOM_SCHEMA_DML_SCRIPT} ${TMP}/dml/${rc_RANDOM_SCHEMA_TABLE_PREFIX}${iTable}_${rc_RANDOM_SCHEMA_COLUMN_PREFIX}${iColumn}.sql
done
}
# ------------------------------------------------------------
f_generate_show_cfg () {
ECHO "rc_RANDOM_SCHEMA_NAME=$rc_RANDOM_SCHEMA_NAME"
ECHO "rc_RANDOM_SCHEMA_TABLE_COUNT=$rc_RANDOM_SCHEMA_TABLE_COUNT"
ECHO "rc_RANDOM_COLUMN_RANGE=$rc_RANDOM_COLUMN_RANGE"
ECHO "rc_RANDOM_ROWCOUNT=$rc_RANDOM_ROWCOUNT"
ECHO "rc_RANDOM_SCHEMA_TABLE_PREFIX=${rc_RANDOM_SCHEMA_TABLE_PREFIX}"
ECHO "rc_RANDOM_SCHEMA_COLUMN_PREFIX=${rc_RANDOM_SCHEMA_COLUMN_PREFIX}"
}
# ------------------------------------------------------------
f_generate_create () {
vColValues=""
iTable=0
while [ $iTable -lt ${rc_RANDOM_SCHEMA_TABLE_COUNT} ]
do
	(( iTable=iTable+1 ))
	DEBUG "Generating Random Table# $iTable"

	#begin CreateTable statement
	TableScript "-- ${cLINE2}"
	TableScript "PROMPT Create Table ${rc_RANDOM_SCHEMA_TABLE_PREFIX}${iTable} ..."
	TableScript "CREATE TABLE ${rc_RANDOM_SCHEMA_TABLE_PREFIX}${iTable} ("
	TableScript " ID number(12)"

	#begin InsertTable statement
	InsertScript "-- ${cLINE2}"
	InsertScript "PROMPT Insert into ${rc_RANDOM_SCHEMA_TABLE_PREFIX}${iTable} ... "
	InsertScript "insert /*+ append nologging */"
	InsertScript "into ${rc_RANDOM_SCHEMA_TABLE_PREFIX}${iTable} "
	InsertScript "with a as (select 1 from dual connect by level <=1000)"
	InsertScript "select rownum"

	#randomize column count within requested column count range
	vColumnCount=$(( ${rc_RANDOM_COLUMN_COUNT_MIN}+ (($RANDOM % ((${rc_RANDOM_COLUMN_COUNT_MIN}-${rc_RANDOM_COLUMN_COUNT_MAX})) )) ))
	DEBUG "${iTable} will have ${vColumnCount} columns + id column"

	# add columns
	fAddColumns $vColumnCount

	# end CreateTable statement
	TableScript " );"
	TableScript ""
	TableScript "CREATE INDEX ${rc_RANDOM_SCHEMA_TABLE_PREFIX}${iTable}_PK"
	TableScript "ON ${rc_RANDOM_SCHEMA_TABLE_PREFIX}${iTable} (ID) REVERSE;"
	TableScript "-- ${cLINE2}"

	# end InsertTable statement
	InsertScript "from a a1, a a2"
	InsertScript "where rownum<${rc_RANDOM_ROWCOUNT};"
	InsertScript "commit;"
	InsertScript "-- ${cLINE2}"

done
ECHO "Create Table Script: ${rc_RANDOM_SCHEMA_CREATE_SCRIPT}"
ECHO "Insert Table Script: ${rc_RANDOM_SCHEMA_INSERT_SCRIPT}"
[[ "${rc_RANDOM_SCHEMA_SCRIPT_ONLY}" != "YES" ]] && SQLRUN "@${rc_RANDOM_SCHEMA_CREATE_SCRIPT}"
[[ "${rc_RANDOM_SCHEMA_SCRIPT_ONLY}" != "YES" ]] && SQLRUN "@${rc_RANDOM_SCHEMA_INSERT_SCRIPT}"
}
# ------------------------------------------------------------
f_generate_drop () {
iTable=0
while [ $iTable -lt ${rc_RANDOM_SCHEMA_TABLE_COUNT} ]
do
	(( iTable=iTable+1 ))
	ECHO "drop Random Table# $iTable"
	DropScript "drop table ${rc_RANDOM_SCHEMA_TABLE_PREFIX}${iTable} purge;"
	[[ "${rc_RANDOM_SCHEMA_SCRIPT_ONLY}" != "YES" ]] && SQLRUN "@${rc_RANDOM_SCHEMA_DROP_SCRIPT}"
done
ECHO "Drop Table Script: ${rc_RANDOM_SCHEMA_DROP_SCRIPT}"
}
# ------------------------------------------------------------
