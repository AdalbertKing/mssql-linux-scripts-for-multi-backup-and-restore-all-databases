##             
##  generating SQL Query for restoring  all .bak files from list of current working databases
## $1 - path of .bak files  
## $2 - state of restored databases (RECOVERY/NORECOVERY) 
## 		WARNING!!: Before use SQL query  generated from this script should be fixed by deleteing line with "-" and with sentence "(..  row affected)" 
##  
/opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P 'SqlPassword' -i /root/scripts/gensql.sql -v _path=$1 -v _recovery=$2 -W

