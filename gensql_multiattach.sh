##             
##  generating SQL Query for attach all .mdf files 
## $1 - path of .bak files  
## 
## WARNING!!: Before use SQL query  generated from this script should be fixed by deleteing line with "-" and with sentence "(..  row affected)" 
##  
/opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P 'Sqlpassword' -i /root/scripts/multiattach.sql -v _path=$1 -W

