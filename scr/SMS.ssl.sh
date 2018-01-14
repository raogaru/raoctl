# ############################################################
# SMS - SSL Maintenance functions
# ############################################################
# ------------------------------------------------------------
# SMS SSL actions
action_L1="gen_1 gen_n "
action_L1="list count "
action_L="$action_L1 $action_L2 $action_L3"
# ------------------------------------------------------------
# USAGE DATA
usage_L=" \
add,id:name,Add_new_user \
"
# ------------------------------------------------------------
# local variables
v_debug=0
# ------------------------------------------------------------
INCLIB_c
PRV_SSL=${TMP}/ssl.$$.prv
PUB_SSL=${TMP}/ssl.$$.pub
# ------------------------------------------------------------
f_ssl_list () { 
SMS_q "select id, sndr_ssl, rcvr_ssl from ssl where status='N' order by id;"
}
# ------------------------------------------------------------
f_ssl_count () { 
SMS_q "select status, count(1) ssl_status_count from ssl group by status;"
}
# ------------------------------------------------------------
f_ssl_gen_1 () { 
#gen priv key
/usr/bin/openssl genrsa -out $PRV_SSL 2048 2>/dev/null
[[ $? -ne 0 ]] && ERROR "Failed to genrate openssl private key"
# extract public key from priv key
/usr/bin/openssl rsa -in $PRV_SSL -out $PUB_SSL -outform PEM -pubout 2>/dev/null
[[ $? -ne 0 ]] && ERROR "Failed to extract openssl public key from private key"
#strip header and footers
x1=$(grep -v "PUBLIC KEY" $PUB_SSL)
x2=$(grep -v "RSA PRIVATE KEY" $PRV_SSL)
#insert into ssl table
SMSPKG_p "ssl_add('${x1}','${x2}')"
}
# ------------------------------------------------------------
f_ssl_gen_n () { 
INPUT
i=0
while [ $i -lt ${input1} ]
do
	f_ssl_gen_1
	(( i = i+1 ))
done
}
# ------------------------------------------------------------
