DECLARE @folderpath VARCHAR (1000)
DECLARE @recovery VARCHAR (12)
SELECT @folderpath = '$(_path)' -- Backup Location
SELECT @recovery = '$(_recovery)' -- model of recovery

SELECT 'RESTORE DATABASE['+NAME+'] FROM DISK = ''' +@folderpath + "" + name+'.bak'' WITH $(_recovery),
REPLACE, STATS = 5'
FROM master.sys.databases
WHERE name NOT IN ('master','model','msdb','tempdb','distribution')

