# Copy all .mdf .ldf files from SQL server after stop to the $1 
# Copy all databases from SQL DATA folder to backup folder 
_mdfpath="/var/opt/mssql/data/"

systemctl stop mssql-server & process_id=$!
wait $process_id
echo "SQL server stopped"
cp -a $_mdfpath/* $1
systemctl start mssql-server
echo "SQL server launched"

