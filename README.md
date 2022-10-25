A package of .bash and .sql scripts for MSSQL for linux to automate the process of creating backups of all databases running on SQL Server and automatically generated .sql queries needed to restore them. The included scripts support differential and full backups, and the scripts that restore databases from copies can set them to norecovery or recovery mode.
The main application, is a complete backup with automatic recovery procedure.
The second application is to implement a mirror of two or more SQL servers by automatically uploading differential backups of all running databases to the backup server.
(E.g. between MSSQL Server for Linux and for Windows )

Scripts description:

1. backupall.sh -[option] [backup_path] -Backup all databases to the backup_path with options from bash uses backup.sql

        [options]:
		
		-f for FULL BACKUP (DEFAULT DIFFERENTIAL)
        -c for COPY_ONLY (FULL BACKUP OUTSIDE OD SHEDULER )  
        -u for NO_COMPRESSION
        -e for FORMAT
		-i for INIT
		
2. backup.sql - used by backupall.sh	-SQL query with options for create backup all databases on STDOUT

launch sql command:

/opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P 'sqlpassword' -i $_spath/backupall.sql -v _path=$1 -v _parameters=$parameters

@path = '$(_path)'    	-- database backup directory
@par = '$(_parameters)'	-- parameters added for restore/attach option to generated script {a.k backupall.sh}

3. gensql.sh $1 $2 $3 $4

 $1 - kind of scripts on output (attach|restore|setrecovery) 
 $2 - path of backups (it must be finished by "/")
 $3 - state of restored databases by generated .sql query (RECOVERY/NORECOVERY, DEFAULT is NORECOVERY) 
 $4 - In restore mode it's Number of file from  backup media .bak(FILES = n -absent equal to 1 )   

4. gensql.sql	- used by gensql.sh		-SQL query with options to generate .sql scipt to the STDOUT for multiple operation on databases.

launched by command:

/opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P 'sqlpassword' -i $_spath/gensql.sql -v _what=$1 -v _path=$2 -v _recovery=$recovery -v _files=$files -W|sed '1,2d;/affected/d;/^$/d'

@folderpath = '$(_path)' 	-- Backup Location
@recovery = '$(_recovery)' 	-- model of recovery
@what = '$(_what)' 			-- Type of generated .sql script (attach|restore|setrecovery)
@files = '$(_files)' 		-- FILES parameter

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
	
running an automatically generated .sql query that performs ATTACH for every databases: 

	/opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P 'sqlpassword' -i /srv/data/attachall.sql
	
You can use: runsql.bat /srv/data/attachall.sql  	
___________________________________________________________________________________________________________________________________________________________________________________________

I hope that my work will help someone to implement and automate backup or mirror on SQL server for Linux with multiple databases. I am an ardent advocate of deploying MSSQL under Linux, which works better than under Windows, especially with applications using multiple databases in a single SQL server instance. The combination of automatic differential/full backups and ZFS file system gives a much higher level of security and flexibility. Recommended.
I am preparing a similar script package for Sql Server under Windows + CMD/PowerShell. I would appreciate reporting bugs and suggestions for improving the procedure.

Future scenario:
I want to implement parameter FILES = n to restoresql.sql query, which will allow to operate on continuos .bak file with many backups, and automatically restore the last differential from many others.
Problem is that every databases could have different numbers of backups in own .bak file.



 

						WOJCIECH KROL
						lurk@lurk.com.pl
						2022-10-11

