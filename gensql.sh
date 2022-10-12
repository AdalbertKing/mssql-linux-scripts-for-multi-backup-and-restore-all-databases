##             
##  generating SQL Query for restoring  all .bak files from list of current working databases
## $1 - kind of scripts on output (attach|restore|setrecovery)
## $2 - path of backups
## $3 - state of restored databases by generated .sql query (RECOVERY/NORECOVERY, DEFAULT is NORECOVERY) 
## $4 - In restore mode it's Number of file from  backup media .bak(FILES = $4 -absent equal to 1 )

_spath=/root/scripts
files=1
recovery=NORECOVERY

if [[ -z $1 ]]; then
	echo 'error: variant of gerated .sql query maust be specified as the first argument (attach|restore|setrecovery)' >&2
	exit 1
fi

if [[ -z $2 ]]; then
	echo 'error: path of backups must be specified as the first argument' >&2
	exit 1
fi

if [[ $3 ]]; then
	recovery=$3
fi

if [[ $4 ]]; then
	files=$4
fi
/opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P 'Sq!201402' -i $_spath/gensql.sql -v _what=$1 -v _path=$2 -v _recovery=$recovery -v _files=$files -W|sed '1,2d;/affected/d;/^$/d'

