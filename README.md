A package of .bash and .sql scripts for MSSQL for linux to perform an automatic backup of all working databases on MSSQL ended with generating the SQL query needed to restore this backup. The included scripts support differential and full backups, and the scripts that restore databases from copies can set them to norecovery or recovery mode.

The main application, is a complete backup with automatic recovery procedure.

The second application is to implement a backup of two or more SQL servers by automatically uploading differential backups of all running databases to the backup server. 

(E.g. between MSSQL Server for Linux and for Windows )


Scripts description:

1. backupall.sh -[option] [backup_path] -Backup all databases to the backup_path with options from bash uses backup.sql

        [options]:
		
	-f for FULL BACKUP (DEFAULT DIFFERENTIAL)
        -c for COPY_ONLY (FULL BACKUP OUTSIDE OF BACKUP PLAN)  
        -u for NO_COMPRESSION
        -e for FORMAT
	-i for INIT
	-n for only new databases created after last full backup
		
2. backup.sql - used by backupall.sh	-SQL query with options for create backup all databases on STDOUT

launch sql command:

sqlcmd -S [ip_sqlserver] -U sa -P [sqlpassword] -i backupall.sql -v _path="%2" -v _parameters=%1 -v onlynew="%3"

@path = '$(_path)'    	-- database backup directory
@par = '$(_parameters)'	-- parameters added for restore/attach option to generated script {a.k backupall.sh}
@onlynew - '$(_onlynew)'-- all or added databases after last full backup

3. gensql.sh -[option] [kind] [path of backups] [recovery|noreovery]

[options]:
	
	-n for only new databases created after last full backup
	-p FILES = parameter (not used yet, always is set to 1)

 $1 - kind of scripts on output (attach|restore|setrecovery) 
 $2 - path of backups (it must be finished by "/")
 $3 - state of restored databases by generated .sql query (RECOVERY/NORECOVERY, DEFAULT is NORECOVERY) 


4. gensql.sql	- used by gensql.sh		-SQL query with options to generate .sql scipt to the STDOUT for multiple operation on databases.

launched by command:

sqlcmd -S [ip_sqlserver] -U sa -P [sqlpassword] -i gensql.sql -v _what=restore -v _path="%2" -v _recovery=NORECOVERY -v _files=1 -v _onlynew=all -W >%2restoreall.sql


@folderpath = '$(_path)' 	-- Backup Location
@recovery = '$(_recovery)' 	-- model of recovery
@what = '$(_what)' 			-- Type of generated .sql script (attach|restore|setrecovery)
@files = '$(_files)' 		-- FILES parameter
@onlynew - '$(_onlynew)'-- all or added databases after last full backup

4.copy_mdf.sh $1		 	-- Copy all databas files from sql server data after stop sql server, than start sql server.

 $1 - destination path
 
I used scripts by Paul Hewson: https://www.sqlserversnippets.com/2013/10/generate-scripts-to-attach-multiple.html

Greg Robidoux: https://www.mssqltips.com/sqlservertip/1070/simple-script-to-backup-all-sql-server-databases/
_________________________________________________________________________________________________________________________________________________________________________________________

A working example:

	1. Path to scripts:		 			/root/scripts/
	2. Path of full backups: 			/srv/backup/
	3. Path od differential backups:	/srv/backup/diff/
	4. Path of copies .mdf and .ldf:    /srv/data/ 
	
		
Crontab description:
	
	1. every day at 23:00 copy_mdf.sh stops SQL Server than copies all database files *.mdf, *.ldf to /srv/data/
	
    	2. every day at 23:30 after restart sql server generate script attachall.sql placed with copied data half an hour earlier.
		
	3. At 23:15 on Saturday backupall.sh does a full backup with format and init parameter (-fei) to clear .bak file of the running databases into /srv/backup/ and generates the restoreall.sql query needed to restore them placing it with the backups folder. 
	
	4. every two hours every day from 10:00 a.m. to 10:00 p.m. backupall.sh creates differential copies with format parameter (-e) of all the databases in /srv/backup/diff/ and generates the restoreall.sql query needed to restore them with the NORECOVERY parameter (-r) and setrecoveryall.sql -script for swith 'databases for recovery state. 
	

The scenario of fully restoring the databases from a .bak copy consists of three stages: 

Stage 1: running an automatically generated .sql query restoreall.sql for recovery databases from .bak for FULL copies:
    
	/opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P 'sqlpassword' -i /srv/backups/restoreall.sql
	
	(Full copies, so the databases recovered in the first stage will be NORECOVERY. Since we assume that there are still differential copies waiting to be restored


Stage 2: running an automatically generated .sql query restoreall.sql From Differential Copies:
    
	/opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P 'sqlpassword' -i /srv/backups/diff/restoreall.sql
	
	The recovered databases in the second stage will be NORECOVERY (perheps to the next tasks of recovery )
	
     	
Stage 3: running an automatically generated query setrecoveryall.sql for switch all databases into RECOVERY state. 
_________________________________________________________________________________________________________________________________________________________________________________________

The alternative scenario appends to sql server all previously copied .mdf and.ldf files to the bases folder:
 
	Copy the .mdf and .ldf to the correct mssql data folder, then set correct linux  user and group for mssql server in linux:

	cp /srv/data/* /var/opt/mssql/data
	
	chown mssql /var/opt/mssql/data/*.bak
	
	chown mssql /var/opt/mssql/data/*.ldf
	
	chgrp mssql /var/opt/mssql/data/*.bak
	
	chgrp mssql /var/opt/mssql/data/*.ldf

	chmode 660 /var/opt/mssql/data/*
	
running an automatically generated .sql query that performs ATTACH for every databases: 

	/opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P 'sqlpassword' -i /srv/data/attachall.sql
	
You can use: runsql.sh /srv/data/attachall.sql  	
___________________________________________________________________________________________________________________________________________________________________________________________

importants:

1.Full copies are made with INIT,FORMAT parameters, resulting in the creation of a new file. bak and resetting the backup cycle with the writing of this information to the database.
 Differential copies are made with the FORMAT parameter. As a result, we have in the directories with backups the last full copy and the last differential copy.
 Which allows you to recover databases to the state after the full backup, or after the last differential. To recover databases to any point in the past, you need to add a mechanism for archiving directories with .bak. between backup tasks, or create them on a snapshot file system (ZFS, BTRFS). You can also exclude FORMAT and INIT parameters from the scripts, which will result in incrementing .bak files.
However, this will affect the correctness of the restoreall.sql query, which in this version does not support the FILES = n parameter yet, that allows you to specify the archive position in the continuos .bak file.
Implementing this mechanism is difficult because each database may be created at a different time , and thus will have a different FILES parameter at a given time.
 
 This version of the scripts allows you to extend the period between full backups, as I added a mechanism for identifying newly added databases (after the last full copy), and performing a full backup for them immediately (during a differential copy)
 
 
I hope that my work will help someone to implement and automate backup or mirror on SQL server for Windows with multiple databases. I would appreciate reporting bugs and suggestions for improving the procedure.
 

						WOJCIECH KROL
						lurk@lurk.com.pl
						2022-10-11



I hope that my work will help someone to implement and automate backup or mirror on SQL server for Linux with multiple databases. I am an ardent advocate of deploying MSSQL under Linux, which works better than under Windows, especially with applications using multiple databases in a single SQL server instance. The combination of automatic differential/full backups and ZFS file system gives a much higher level of security and flexibility. Recommended.
I am preparing a similar script package for Sql Server under Windows + CMD/PowerShell. I would appreciate reporting bugs and suggestions for improving the procedure.

Future scenario:
I want to implement parameter FILES = n to restoresql.sql query, which will allow to operate on continuos .bak file with many backups, and automatically restore the last differential from many others.
Problem is that every databases could have different numbers of backups in own .bak file.



 

						WOJCIECH KROL
						lurk@lurk.com.pl
						2022-10-11

