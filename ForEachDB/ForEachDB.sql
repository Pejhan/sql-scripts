
SET QUOTED_IDENTIFIER OFF
SET NOCOUNT ON

DECLARE @Query VARCHAR(MAX) = "
select count(*) c
from cmn.policyver pv
join lf.lifebnver lb on lb.policyid = pv.policyid and lb.tranno = pv.tranno
where lb.VPrmSum is null and pv.reshte = 103 and pv.vno is not null
having count(*) > 0
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
SELECT name FROM sys.databases db WHERE (name LIKE 'Main%' OR name LIKE 'Developer%')

OPEN db_crsr
FETCH NEXT FROM db_crsr
INTO @db
WHILE @@FETCH_STATUS = 0
BEGIN 
	BEGIN TRY
	    DECLARE @cmd_ VARCHAR(MAX) = "USE " + @db + CHAR(10) +
		"DECLARE @Query VARCHAR(MAX) = """ + @Query + """" + CHAR(10) +
		"EXEC tls.sp_GetOptimizedCmd @Query OUTPUT
		
		DECLARE @cmd1 VARCHAR(MAX) = ""
		INSERT ##RESULT
		SELECT db_name() as db_name,*
		FROM ("" + @Query + "") A
		""
		--PRINT @cmd1
		EXEC (@cmd1)"
		PRINT(@cmd_)
		EXEC (@cmd_)
		--PRINT '	' + @db
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

--SELECT c.COLUMN_NAME, c.ORDINAL_POSITION, c.DATA_TYPE
--FROM tempdb.INFORMATION_SCHEMA.COLUMNS c
--WHERE c.TABLE_NAME = '##result'
