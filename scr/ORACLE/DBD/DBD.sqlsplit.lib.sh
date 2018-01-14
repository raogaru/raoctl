# ------------------------------------------------------------
# Global variable overwrites
rc_SPLITSQL_REMOVE_CSTYLE_COMMENTS=YES
rc_SPLITSQL_REMOVE_DOCUMENT_COMMENTS=YES
rc_SPLITSQL_REMOVE_EMPTY_LINES=YES
rc_SPLITSQL_REMOVE_PROMPT_LINES=YES
rc_SPLITSQL_REMOVE_DOUBLE_HIPHEN_LINES=YES
rc_SPLITSQL_REMOVE_MULTIPLE_WHITESPACES=YES
# ------------------------------------------------------------
# Module specific environment variables
sStr=""				# sql string

# ------------------------------------------------------------
# Module specific common functions

# ------------------------------------------------------------
# Split input sqlfile into multiple files
f_split_sql_to_files () {
v_debug=0
l_FileName=$1 #input file
sNum=0 #SQL Count
typeset sStr=""
l_FileLineNum=0
l_SqlLineNum=0
sLineCnt=0
lStr=""
cCnt=0

DEBUG Processing ${l_FileName}

CHKFILE ${l_FileName}

# remove multi-line comments starting with /* and ending with */  
if [ "${rc_SPLITSQL_REMOVE_CSTYLE_COMMENTS}" != "NO" ]; then
	DEBUG "Removing C-Style multi-line comments"
	cat ${l_FileName} | perl -p0e 's!/\*.*?\*/!!sg' > ${TMPFILE3}
else
	cp ${l_FileName} ${TMPFILE3}
fi

# remove multi-line comments starting with DOC and ending with #
if [ "${rc_SPLITSQL_REMOVE_DOCUMENT_COMMENTS}" != "NO" ]; then
	DEBUG "Removing DOC-# multi-line comments"
	cat ${TMPFILE3} | perl -p0e 's!DOCUMENT.*?#!!sg' | perl -p0e 's!document.*?#!!sg'> ${TMPFILE4}
else
	cp ${TMPFILE3} ${TMPFILE4}
fi

# remove empty lines
if [ "${rc_SPLITSQL_REMOVE_EMPTY_LINES}" != "NO" ]; then
	DEBUG "Removing empty lines"
	cat ${TMPFILE4} | grep -v "^$" > ${TMPFILE3}
else
	cp ${TMPFILE4}  ${TMPFILE3}
fi

# remove prompt statements
if [ "${rc_SPLITSQL_REMOVE_PROMPT_LINES}" != "NO" ]; then
	DEBUG "Removing PROMPT lines"
	cat ${TMPFILE3} |grep -iv "^[ 	]*prompt" > ${TMPFILE4}
else
	cp ${TMPFILE3}  ${TMPFILE4}
fi

# remove double hiphen comments
if [ "${rc_SPLITSQL_REMOVE_DOUBLE_HIPHEN_LINES}" != "NO" ]; then
	DEBUG "Removing DOUBLE HIPHEN comments"
	cat ${TMPFILE4} |sed -e 's/--.*$//' > ${TMPFILE3}
else
	cp ${TMPFILE4}  ${TMPFILE3}
fi

# remove leading and trailing whitespaces
if [ "${rc_SPLITSQL_REMOVE_MULTIPLE_WHITESPACES}" != "NO" ]; then
	DEBUG "Removing multiple whitespaces"
	# 1.replace tabs 2.leading spaces 3.trailing spaces 4.multiplespaces with one"
	cat ${TMPFILE3} | sed -e 's/[	]/ /g' -e 's/^[ 	]*//g' -e 's/[ 	]*$//g' -e 's/[ ][ ]*/ /g' > ${TMPFILE4}
else
	cp ${TMPFILE3}  ${TMPFILE4}
fi

#final copy in ${TMPFILE3} before processing line by line
cp ${TMPFILE4} ${TMPSCR}
rm -f ${TMPFILE3} ${TMPFILE4}
DEBUG "SQL File is ${TMPSCR} before processing line by line"
ECHO "${cLINE2}"

# processing begins - read full line into lStr
while read -r lStr
do
	(( l_FileLineNum=l_FileLineNum+1 ))
	(( l_SqlLineNum=l_SqlLineNum+1 ))

	# increment char count by length of line
	((cCnt=cCnt+${#lStr}))

	# first char of line
	sChar1=${lStr:0:1}

	# last char of line
	sChar2=${lStr:(-1)}

	#DEBUG "c1=$sChar1"
	#DEBUG "c2=$sChar2"

	# if first char is "/" for First line of SQL then previous sql statement is of PLSQL type 
	[[ "${sChar1}" = "/" && ${l_SqlLineNum} -eq 1 ]] && l_SqlLineNum=0 && continue
	
	# enable this debug line if problem parsing sql file due to bad characters
	DEBUG "FileLine#${l_FileLineNum} : SqlLine#${l_SqlLineNum} : Chars=${cCnt} : ${lStr} "

	# replace first char is slash then end SQL
	if [ "${sChar1}" = "/" ]; then
		 sChar1=";"
		sStr="${sStr} ;"
	else
		sStr="${sStr} ${lStr}"
	fi

	# start new SQL if first char is semi-color or slash OR last char is semi-colon
	if [[ "${sChar1}" == ";" || "${sChar1}" == "/" || "${sChar2}" == ";" ]]; then

		# trim leading whitespaces
		sStr="${sStr#"${sStr%%[![:space:]]*}"}"

		DEBUG "${cLINE4}"
		(( sNum=sNum+1 ))
		DEBUG "SQL#${sNum} : ${sStr}"
		# create sql file per statement - use this split sql file for execution 
		ECHO "${sStr}" > ${TMPSQL}.${sNum}
		DEBUG "SQL#${sNum} file is ${TMPSQL}.${sNum}"

		DEBUG "${cLINE1}"
		# start new sql string
		sStr=""
		l_SqlLineNum=0
		cCnt=0
	fi
done < ${TMPSCR} 

ECHO "${cLINE2}"
ECHO "Summary:"
ECHO "Input Script ${l_FileName}"
ECHO "Trimmed Script ${TMPSCR}"
ECHO "Number of lines : ${l_FileLineNum}"
ECHO "Number of SQLs : ${sNum}"
v_debug=0
}
# ------------------------------------------------------------
