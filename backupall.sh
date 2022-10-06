#######################################################################################################################################################################################
## 					multi backup ALL  SQL databases to the .bak archives
## $1 - path of .bak files
## $2 - generated sql script on STDOUT for automatical restore .bak files after operation
## -f  -SWITCH parameters for FULL backup ("COMPRESS") DEFAULT IS "DIFFERENTIAL,COMPRESS" - TYPICAL FOR DIFFERENTIAL
## -r  -SWITCH parameters to "RECOVERY" of future restored databases state by auto generated SQL recovery script (DEFAULT IS "NORECOVERY)")

## examples:
## backupall.sh -f /srv/backup/ restoreall.sql      -create full backups .bak and SQL query "restoreall.sql" for restore them with NORECOVERY state in /srv/backup/
## backupall.sh -r /srv/backup/diff/ restoreall.sql -create differential backups .bak and SQL query "restoreall.sql" for restore them with RECOVERY state in /srv/backup/diff
## backupall.sh -rf /srv/backup/ restoreall.sql- USUALLY FOR EVERYDAY FULL BACKUP -create full backups .bak and SQL query "restoreall.sql" for restore them with RECOVERY state in /srv/backup/
## backupall.sh -f /srv/backup/  full backup without generating recovery scripts  

# WOJCIECH KROL 2022-10-05
# lurk@lurk.com.pl
#########################################################################################################################################################################################
 
date
parameters=DIFFERENTIAL,COMPRESSION
model=NORECOVERY
out=/dev/NULL

while getopts 'fr' option; do
	case "$option" in
		f) parameters=COMPRESSION;;
		r) model=RECOVERY;;
		*) usage; exit 1;;
	esac
done
shift "$((OPTIND - 1))"

if [[ -z $1 ]]; then
	echo 'error: path of backups must be specified as the first argument' >&2
	exit 1
fi

if [[ $2 ]]; then
	out=$2
fi

echo "path of BACKUPS:" $1
echo "parameters of backups:" $parameters 
echo "state of future recovered bases by generated script:" $model 
echo "STDOUT:" $out

#rm $1*.BAK
#rm $2*.BAK

/opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P 'SqlPassword' -i /root/scripts/backupall.sql -v _path=$1 -v _parameters=$parameters
/opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P 'SqlPassword' -i /root/scripts/gensql.sql -v _path=$1 -v _recovery=$model -W >$out

cp $out $1
