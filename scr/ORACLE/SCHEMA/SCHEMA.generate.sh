# ############################################################
# SCHEMA GENERATE FUNCTIONS - Generate Random Schema Tables
# ############################################################
# ------------------------------------------------------------
# <CLASS> <MODULE> actions
action_L1="show_cfg create_tables drop_tables"
action_L2="yy "
action_L3="zz "
action_L="$action_L1 $action_L2 $action_L3"
# ------------------------------------------------------------
# USAGE DATA
usage_L=" \
xx,none,xx_description \
yy,none,yy_description \
zz,none,zz_description \
"
# ------------------------------------------------------------
# Global variable overwrites
rc_RANDOM_SCHEMA_TABLE_COUNT=${rc_RANDOM_SCHEMA_TABLE_COUNT:=10}	# need N tables
rc_RANDOM_COLUMN_COUNT_RANGE=${rc_RANDOM_COLUMN_COUNT_RANGE:=3,20}	# table with M to N columns
rc_RANDOM_ROWCOUNT_RANGE=${rc_RANDOM_ROWCOUNT_RANGE:=10k,1m}
rc_RANDOM_SCHEMA_TABLE_PREFIX=${rc_RANDOM_SCHEMA_TABLE_PREFIX:=TABLE}

# ------------------------------------------------------------
# Module specific environment variables
vCreateTable=""
vColumnCount=0

# ------------------------------------------------------------
# Module specific common functions
fAddColumns () {
iColumn=0
while [ $iColumn -lt $vColumnCount ]
do
	(( iColumn=iColumn+1 ))
	DEBUG "Adding column# C$iColumn"
	
	x=$(( $RANDOM % 16 ))			# randomly assign data type - 16 different so far
	case $x in 
	0) # Integer
		vDataType="INTEGER"
	;;
	1) # number without precision or scale
		vDataType="NUMBER"
	;;
	2) # number with precision
		p=$(( $RANDOM % 38 + 1 )) 	# randomly find precisio for NUMBER data type
		vDataType="NUMBER($p)"
	;;
	3) # number with precision,scale
		p=$(( $RANDOM % 20 + 1 )) 	# randomly find precisio for NUMBER data type
		s=$(( $RANDOM % 10 + 1 ))  	# randomly find scale for NUMBER data type
		vDataType="NUMBER($p,$s)"
	;;
	4) # CHAR data type - defaults to size 1 - always not null
		vDataType="CHAR not null"
	;;
	5) # CHAR data type with length
		y=$(( $RANDOM % 10 + 1 )) 	# randomly find length for CHAR data type
		vDataType="CHAR($y)"
	;;
	6) # VARCHAR2 data type with length between 1 and 95 with 5 increment
		y=$(( $RANDOM % 20 + 1 )) 	# randomly find length for VARCHAR2 data type
		z=$(( $y * 5 )) 	
		vDataType="VARCHAR2($y)"
	;;
	7) # VARCHAR2 data type with length 100, 200, 300 .... 2000
		y=$(( $RANDOM % 20 + 1)) 	# randomly find length for VARCHAR2 data type
		z=$(( $y * 100 )) 	
		vDataType="VARCHAR2($z)"
	;;
	8) # DATE data type
		vDataType="DATE"
	;;
	9) # DATE data type with SYSDATE default 
		vDataType="DATE default sysdate not null"
	;;
	10) # DATE data type with not null
		vDataType="DATE not null"
	;;
	11) # TIMESTAMP data type 
		vDataType="TIMESTAMP"
	;;
	12) # TIMESTAMP data type with SYSTIMTSTAMP default 
		vDataType="TIMESTAMP default systimestamp not null"
	;;
	13) # TIMESTAMP data type with not null
		vDataType="TIMESTAMP not null"
	;;
	14) vDataType="CLOB"
	;;
	15) vDataType="BLOB"
	;;
	esac
	vCreateTable="${vCreateTable} ,C${iColumn} ${vDataType} "
done
}
# ------------------------------------------------------------
f_generate_show_cfg () {
ECHO "rc_RANDOM_SCHEMA_TABLE_COUNT=$rc_RANDOM_SCHEMA_TABLE_COUNT"
ECHO "rc_RANDOM_COLUMN_RANGE=$rc_RANDOM_COLUMN_RANGE"
ECHO "rc_RANDOM_ROWCOUNT_RANGE=$rc_RANDOM_ROWCOUNT_RANGE"
}
# ------------------------------------------------------------
f_generate_tables () {
iTable=0
while [ $iTable -lt ${rc_RANDOM_SCHEMA_TABLE_COUNT} ]
do
	(( iTable=iTable+1 ))
	DEBUG "Generating Random Table# $iTable"
	vCreateTable="CREATE TABLE ${rc_RANDOM_SCHEMA_TABLE_PREFIX}${iTable} ("
	vCreateTable="${vCreateTable} id number"
	x=$(echo $rc_RANDOM_COLUMN_COUNT_RANGE | cut -f1 -d",")	# mininum columns
	y=$(echo $rc_RANDOM_COLUMN_COUNT_RANGE | cut -f2 -d",") # maximum columns
	z=$(( $RANDOM % (($y-$x)) ))
	(( vColumnCount=$x+$z )) 			# number of columns for this table
	DEBUG "    ${iTable} will have ${vColumnCount} columns + id column"
	fAddColumns $vColumnCount
	vCreateTable="${vCreateTable} );"
	ECHO "${vCreateTable}"
	SQLRUN "${vCreateTable}"
done
}
# ------------------------------------------------------------
f_generate_drop_tables () {
iTable=0
while [ $iTable -lt ${rc_RANDOM_SCHEMA_TABLE_COUNT} ]
do
	(( iTable=iTable+1 ))
	ECHO "drop Random Table# $iTable"
	SQLRUN "drop table sys.TABLE$iTable;"
done
}
# ------------------------------------------------------------
