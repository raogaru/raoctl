# ############################################################
# DISK FDISK FUNCTIONS - partition management
# ############################################################
# ------------------------------------------------------------
# DISK FDISK actions
action_L1="info list create drop create_n "
action_L2="xxx yyy zzz "
action_L3="www "
action_L="$action_L1 $action_L2 $action_L3"
# ------------------------------------------------------------
# USAGE DATA
usage_L=" \
list,NONE,List_Disk_Partitions \
create,diskname,Create_1_Disk_Partition \
drop,diskname,Drop_Disk_Partition_1 \
create_n,diskname:partition_count,Create_N_Disk_Partitions \
drop_n,diskname,Drop_N_Disk_Partitions \
"
# ------------------------------------------------------------
# local variables
v_diskname=""
# ------------------------------------------------------------
fGetPartCount () {
p=0
for i in 1 2 3 4
do
[[ -b "${v_diskname}$i" ]] && p=$i
done
echo $p
}
# ------------------------------------------------------------
fGetDiskCylinderCount () {
echo $(/sbin/fdisk -l ${v_diskname}|grep heads |grep sectors|grep cylinders|cut -f3 -d","|sed -e 's/ cylinders//')
}
# ------------------------------------------------------------
f_fdisk_list () { 
ls -l /dev/sd*
}
# ------------------------------------------------------------
f_fdisk_info () { 
INPUT
/sbin/fdisk -l /dev/sd${input1}
}
# ------------------------------------------------------------
f_fdisk_create () { 
INPUT
v_diskname=/dev/sd${input1}
[[ ! -b "$v_diskname" ]] && ERROR "Device $v_diskname not found"
p_count=$(fGetPartCount)
[[ $p_count -gt 0 ]] && ERROR "$p Partition(s) already exists"

ECHO $cLINE3
v_cylinders=$(fGetDiskCylinderCount)
ECHO "creating primary partition 1 with $v_cylinders cylinders"
echo "
n
p
1
1
$v_cylinders
w
" | /sbin/fdisk ${v_diskname}
/sbin/fdisk -l ${v_diskname}
}
# ------------------------------------------------------------
f_fdisk_drop () { 
INPUT
v_diskname=/dev/sd${input1}
[[ ! -b "$v_diskname" ]] && ERROR "Device $v_diskname not found"

p_count=$(fGetPartCount)
[[ $p_count -eq 0 ]] && ERROR "Partition(s) not exists"

ECHO $cLINE3
ECHO "drop primary partition 1"
echo "
p
d
w
" | /sbin/fdisk ${v_diskname}
/sbin/fdisk -l ${v_diskname}
}
# ------------------------------------------------------------
f_fdisk_create_n () { 
INPUT 2
v_diskname=/dev/sd${input1}
[[ ! -b "$v_diskname" ]] && ERROR "Device $v_diskname not found"

p_count=$(fGetPartCount)
[[ $p_count -gt 0 ]] && ERROR "$p Partition(s) already exists"

ECHO $cLINE3
t_cylinders=$(fGetDiskCylinderCount)
typeset -i v_cylinders=$t_cylinders/${input2}
ECHO "creating $input2 partition(s) with $v_cylinders cylinders in each partition"

i=1
while [[ $i -le $input2 ]]
do
	(( start_cylinder=(i-1)*v_cylinders+1 ))
	(( end_cylinder= i*v_cylinders ))
	ECHO $cLINE4
	ECHO "creating partition $i with $v_cylinders cylinders start=$start_cylinder end=$end_cylinder"
echo "
n
p
$i
$start_cylinder
$end_cylinder
w
" | /sbin/fdisk ${v_diskname}

	(( i=i+1 ))
done

/sbin/fdisk -l ${v_diskname}
}
# ------------------------------------------------------------
