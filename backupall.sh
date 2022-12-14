#######################################################################################################################################################################################
## 					multi backup ALL  SQL databases to the .bak archives
## $1 - path of .bak files
## options:
##         -f for FULL BACKUP (DEFAULT DIFFERENTIAL)
##         -c for COPY_ONLY (FULL BACKUP OUTSIDE OD SHEDULER )  
##         -u for NO_COMPRESSION
##         -e for WITHFORMAT (ERASE OLD backups in target - use carefull! )

## examples:
## backupall.sh -f /srv/backup/				-create full backups .bak in /srv/backup/	()
## backupall.sh /srv/backup/diff/			-create differential backups .bak in /srv/backup/diff/
## backupall.sh -fcue /srv/backup/copies/               -create full backup with FORMAT,NO_COMPRESSION,COPY_ONLY to /srv/backup/copies/

# WOJCIECH KROL 2022-10-05
# lurk@lurk.com.pl
#########################################################################################################################################################################################
 
parameters=COMPRESSION,DIFFERENTIAL                        ## default
model=NORECOVERY
out=/dev/NULL
_spath=/root/scripts
nocompression=''
withformat=''
withinit=''
onlynew=all

while getopts 'fcuein' option; do      
	case "$option" in
		f) parameters=COMPRESSION;;
		c) parameters=COMPRESSION,COPY_ONLY;;
		u) nocompression=NO_;;
		e) withformat=FORMAT,;;
		i) withinit=INIT,;;
		n) onlynew=new;; 
		*) usage; exit 1;;
	esac
done
parameters=$nocompression$parameters   	#WITH COMPRESS OR WITH NO_COMPRESS
parameters=$withformat$parameters      	#WITH FORMAT OR WITHOUT
parameters=$withinit$parameters		#WITH INIT OR WITHOUT


echo "parameters of backups:" $parameters 

shift "$((OPTIND - 1))"

if [[ -z $1 ]]; then
	echo 'error: path of backups must be specified as the first argument' >&2
	exit 1
fi

/opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P 'Sq!201402' -i $_spath/backupall.sql -v _path=$1 -v _parameters=$parameters -v _onlynew=$onlynew


