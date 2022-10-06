# genrating sql script for multiattach all databases .mdf with .ldf in other clean sql server in different location
# warning !!! -generated .sql script has an error inside. You have to cut first and last line of text line from it

_mdfpath="/var/opt/mssql/data/"

/opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P 'SqlPassword' -i gensql_mulitiattach.sql -W > multiattach.sql -v _path=$1

cp multiattach.* $1

# Copy all databases from DATA folder to backup folder 
systemctl stop mssql-server & process_id=$!
wait $process_id
echo "SQL server stopped"
cp -a $_mdfpath $1
systemctl start mssql-server
echo "SQL server launched"

