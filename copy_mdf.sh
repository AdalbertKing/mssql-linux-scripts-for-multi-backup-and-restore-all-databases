## Copy all .mdf .ldf files from SQL server after stop to the $1 
_mdfpath="/var/opt/mssql/data/"
_
#Copy all databases from SQL DATA folder to backup folder 
systemctl stop mssql-server & process_id=$!
wait $process_id
echo "SQL server stopped"
cp -a $_mdfpath/* $1
systemctl start mssql-server
echo "SQL server launched"

