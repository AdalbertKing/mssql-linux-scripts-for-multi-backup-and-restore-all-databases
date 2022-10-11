DECLARE @name NVARCHAR(256) -- database name  
DECLARE @path NVARCHAR(512) -- path for backup files  
DECLARE @fileName NVARCHAR(512) -- filename for backup  
DECLARE @fileDate NVARCHAR(40) -- used for file name
DECLARE @par NVARCHAR(256) -- used for parameters

 
-- specify database backup directory
SET @path = '$(_path)'
SET @par = '$(_parameters)'
 
-- specify filename format
SELECT @fileDate = CONVERT(NVARCHAR(20),GETDATE(),112) 
 
DECLARE db_cursor CURSOR READ_ONLY FOR  
SELECT name 
FROM master.sys.databases 
WHERE name NOT IN ('master','model','msdb','tempdb')  -- exclude these databases
AND state = 0 -- database is online
AND is_in_standby = 0 -- database is not read only for log shipping
 
OPEN db_cursor   
FETCH NEXT FROM db_cursor INTO @name   
WHILE @@FETCH_STATUS = 0   
		BEGIN   
   			SET @fileName = @path + @name +'.bak'  
   			BACKUP DATABASE @name TO DISK = @fileName
 			WITH $(_parameters)
   			FETCH NEXT FROM db_cursor INTO @name   
		END


 
/* @par = 'DIFFERENTIAL'
	BEGIN
		WHILE @@FETCH_STATUS = 0   
		BEGIN   
   			SET @fileName = @path + @name +'.bak'  
   			BACKUP DATABASE @name TO DISK = @fileName
 			WITH DIFFERENTIAL,COMPRESSION 
   			FETCH NEXT FROM db_cursor INTO @name   
		END
	END   
ELSE
	BEGIN
		WHILE @@FETCH_STATUS = 0   
		BEGIN   
   			SET @fileName = @path + @name +'.bak'  
   			BACKUP DATABASE @name TO DISK = @fileName
 			WITH COMPRESSION 
   			FETCH NEXT FROM db_cursor INTO @name   
		END  
    	END
*/

CLOSE db_cursor   
DEALLOCATE db_cursor
