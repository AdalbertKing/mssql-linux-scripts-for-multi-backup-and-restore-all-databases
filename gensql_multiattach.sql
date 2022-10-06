SELECT
'CREATE DATABASE [' + name +'] ON
( FILENAME = N''/var/opt/mssql/data/' + name + '.mdf'' ),
( FILENAME = N''/var/opt/mssql/data/' + name + '_log.ldf'' )
 FOR ATTACH
'
FROM master.dbo.sysdatabases
WHERE name not in ('master','msdb','model','tempdb')

ORDER BY name
GO
