# mssql linux scripts for  multi backup and restore all databases
 mssql linux scripts for  multi backup and restore all databases

A package of automatic .bash scripts and .sql queries for MSSQL Server for Linux included automatic .bak backups of all databases running on the server, with a mechanism included to generate ready-made .SQL queries for the reverse operation, i.e. restoring the archives.
NOTE! all .sql queries (restoreall.sql, multiattach.sql) generated automatically during backups should be corrected manually before use by deleting wrong lines:
1. -
2. ( rows affected)
I had no idea how to modify the .SQL queries generating them so that these lines are removed during the creation process.
I used scripts by Paul Hewson:
https://www.sqlserversnippets.com/2013/10/generate-scripts-to-attach-multiple.html
Greg Robidoux:
https://www.mssqltips.com/sqlservertip/1070/simple-script-to-backup-all-sql-server-databases/

A working example:
Path to scripts: /root/scripts/
Crontab file:
{
SHELL=/bin/bash
PATH=/etc:/bin:/sbin:/usr/bin:/usr/sbin:/root/scripts
0 23 * * * /root/scripts/copy_mdf.sh /srv/data/. 
5 0 * * * 0 rm /srv/backup/*.bak ; /root/scripts/backupall.sh -f /srv/backup/ /root/scripts/restoreall.sql;rm /srv/backup/diff/*.bak  
0 10,12,14,16,18,19,20,21,22 * * 1-7 /root/scripts/backupall.sh -r /srv/backup/diff/ /root/scripts/restoreall.sql 
}

Crontab description:
1. every day at 23:00 copy_mdf.sh stops SQL Server and copies all database files *.mdf, *.ldf to /srv/data/ and generates the multiattach.sql query needed to connect the database files to the server with the ATTACH command placing it with the copies.
2. once a week on Sunday 00:05:00 backupall.sh does a full backup (-f) of the running databases to /srv/backup/ and generates the restoreall.sql query needed to restore them placing it with the backups. After which it removes the old differential copies from the /srv/backup/diff/*.bak directory
3. every two hours every day from 10:00 a.m. to 10:00 p.m. backupall.sh creates differential copies (no -f) of all the databases in /srv/backup/diff/ and generates the restoreall.sql query needed to restore them with the RECOVERY parameter (-r) 


The scenario of fully restoring the databases from a .bak copy consists of two stages: 
Stage 1: From full copies:
Correct the /srv/backup/restore.sql script by removing unnecessary lines created during the creation process:
This:-.
RESTORE DATABASE[AUTOPARTNER] FROM DISK = '/srv/backup/AUTOPARTNER.bak' WITH NORECOVERY,
REPLACE, STATS = 5
RESTORE DATABASE[KR_L_WOJCIECH_LURK] FROM DISK = '/srv/backup/KR_L_WOJCIECH_LURK.bak' WITH NORECOVERY,
REPLACE, STATS = 5
And This:(2 rows affected)
And after correction script, let’s run tchem with the command:
/opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P 'Passwordofsql' -i /srv/backups/restoreall.sql
(Full copies, so the databases recovered in the first stage will be NORECOVERY
Stage 2: From Differential Copies:
Correct the /srv/backup/diff/restore.sql script as in the previous stage:
RESTORE DATABASE[AUTOPARTNER] FROM DISK = '/srv/backup/diff/AUTOPARTNER.bak' WITH RECOVERY,
REPLACE, STATS = 5
RESTORE DATABASE[KR_L_WOJCIECH_LURK] FROM DISK = '/srv/backup/diff/KR_L_WOJCIECH_LURK.bak' WITH RECOVERY,
REPLACE, STATS = 5
And we run with the command:
/opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P 'Passwordofsql' -i /srv/backups/diff/restoreall.sql
The recovered databases in the second stage will be RECOVERY and ready to work.


Bash session:
root@mssql:/srv/backup/diff# /opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P 'Sqlpassword' -i /srv/backup/diff/restoreall.sql
26 percent processed.
52 percent processed.
78 percent processed.
100 percent processed.
Processed 496 pages for database 'KR_L_WOJCIECH_LURK', file 'KR_L_WOJCIECH__LURK_' on file 1.
Processed 2 pages for database 'KR_L_WOJCIECH_LURK', file 'KR_L_WOJCIECH__LURK__log' on file 1.
RESTORE DATABASE successfully processed 498 pages in 0.331 seconds (11.742 MB/sec).
root@mssql:/srv/backup/diff# cd ..
root@mssql:/srv/backup# /opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P 'Sqlpassword' -i /srv/backup/restoreall.sql
5 percent processed.
10 percent processed.
15 percent processed.
20 percent processed.
25 percent processed.
30 percent processed.
35 percent processed.
40 percent processed.
45 percent processed.
50 percent processed.
55 percent processed.
60 percent processed.
65 percent processed.
70 percent processed.
75 percent processed.
80 percent processed.
85 percent processed.
90 percent processed.
95 percent processed.
100 percent processed.
Processed 46448 pages for database 'KR_L_WOJCIECH_LURK', file 'KR_L_WOJCIECH__LURK_' on file 1.
Processed 2 pages for database 'KR_L_WOJCIECH_LURK', file 'KR_L_WOJCIECH__LURK__log' on file 1.
RESTORE DATABASE successfully processed 46450 pages in 3.051 seconds (118.940 MB/sec).
root@mssql:/srv/backup# cd diff
root@mssql:/srv/backup/diff# /opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P 'Sqlpassword' -i /srv/backup/diff/restoreall.sql
26 percent processed.
52 percent processed.
78 percent processed.
100 percent processed.
Processed 496 pages for database 'KR_L_WOJCIECH_LURK', file 'KR_L_WOJCIECH__LURK_' on file 1.
Processed 2 pages for database 'KR_L_WOJCIECH_LURK', file 'KR_L_WOJCIECH__LURK__log' on file 1.
RESTORE DATABASE successfully processed 498 pages in 0.334 seconds (11

Scenario of connecting (multiattach) .mdf and .ldf database files to a working server : 
Copy the .mdf and .ldf files from the copy directory to the directory with the databases after stopping the SQL server:
systemctl stop mssql-server 
 cp /srv/data/* /var/opt/mssql/data
systemctl start mssql-server
Run the query that performs the connection of databases via ATTACH: 
/opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P 'Passwordofsql' -i /srv/data/multiattach.sql
WOJCIECH KRÓL
lurk@lurk.com.pl
2022-10-02
