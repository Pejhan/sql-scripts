
SET QUOTED_IDENTIFIER OFF
SET NOCOUNT ON

DECLARE @Query VARCHAR(MAX) = "
select db_name() c
"



DECLARE @DDL NVARCHAR(max) = "
	IF EXISTS (
		SELECT *
		FROM tempdb.sys.sysobjects
		WHERE name ='##RESULT'
	) 
		DROP TABLE ##RESULT

	SELECT CONVERT(VARCHAR(25), '') AS Comp, *
	INTO ##RESULT
	FROM (" + @Query + ") A
	WHERE 1 = 0
"

EXEC (@DDL)


DECLARE @db NVARCHAR(35)
DECLARE db_crsr CURSOR FOR 
SELECT db.name 
FROM sys.databases db 
WHERE db.state = 0

OPEN db_crsr
FETCH NEXT FROM db_crsr
INTO @db
WHILE @@FETCH_STATUS = 0
BEGIN 
	BEGIN TRY
	    DECLARE @cmd_ VARCHAR(MAX) = "USE " + @db + CHAR(10) +
		"
		INSERT ##RESULT
		SELECT db_name() as db_name,*
		FROM (" + @Query + ") A
		"
		EXEC (@cmd_)
		PRINT '	' + @db
	END TRY
	BEGIN CATCH
	    PRINT 'X	' + @db + '				' + ERROR_MESSAGE()
	END CATCH
	

	FETCH NEXT FROM db_crsr
	INTO @db

END 
CLOSE db_crsr
DEALLOCATE db_crsr


SELECT *
FROM ##RESULT WITH (NOLOCK)

SELECT c.COLUMN_NAME, c.ORDINAL_POSITION, c.DATA_TYPE
FROM tempdb.INFORMATION_SCHEMA.COLUMNS c
WHERE c.TABLE_NAME = '##RESULT'
