/*
	Queries a list of databases to find the maximum values of all columns for the supplied types.
	Useful for determining risk of overflow errors.

	TODO negative values, floats, reals, etc
*/
DECLARE @databaseList NVARCHAR(max) = 'AdventureWorks2012, northwind'; --databases to query
DECLARE @dataTypes NVARCHAR(max) = '''int'', ''smallint'', ''tinyint'''; --types to check
DECLARE @schemaQuery NVARCHAR(max);
DECLARE @currentTable NVARCHAR(max);
DECLARE @currentColumn NVARCHAR(max);
DECLARE @currentType NVARCHAR(10);
DECLARE @database NVARCHAR(max);
DECLARE @maxValSql NVARCHAR(max);
DECLARE @paramDefinition NVARCHAR(max) = N'@maxValueOut bigint OUTPUT';
DECLARE @maxValue BIGINT;
DECLARE @maxRows INT;
DECLARE @currentRow INT = 1;
DECLARE @maxTinyInt TINYINT = 255;
DECLARE @maxSmallInt SMALLINT = 32767;
DECLARE @maxInt INT = 2147483647;
DECLARE @maxBigInt BIGINT = 9223372036854775807;

DECLARE @columnInfo TABLE(
	rowId INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	tableName NVARCHAR(max),
	columnName NVARCHAR(max),
	dataType NVARCHAR(10),
	maxValue BIGINT DEFAULT(0),
	remainingValues BIGINT DEFAULT(0)
);

WHILE LEN(@databaseList) > 0
BEGIN
	--iterate over database list and find all columns of our types
	SET @database =  LTRIM(RTRIM(left(@databaseList, CHARINDEX(',', @databaseList+',')-1)));
	SET @databaseList = STUFF(@databaseList, 1, CHARINDEX(',', @databaseList+','), '');
	SET @schemaQuery = N'SELECT ''[''+ TABLE_CATALOG + ''].'' + ''[''+ TABLE_SCHEMA + ''].'' + ''[''+ TABLE_NAME + '']'', COLUMN_NAME, DATA_TYPE FROM [' + @database + ']' 
	+ '.[INFORMATION_SCHEMA].[COLUMNS] '
	+ 'WHERE DATA_TYPE IN (' + @dataTypes + ')';
	PRINT @schemaQuery

	--add query results to column info table variable
	INSERT @columnInfo (tableName, columnName, dataType)
	EXECUTE sp_executesql @schemaQuery;

	SET @maxRows = (SELECT max(RowId) FROM @columnInfo);
	
	--iterate over all columns for this database and get their max value
	WHILE (@currentRow <= @maxRows)
	BEGIN
		SELECT
			@currentTable = tableName
			,@currentColumn = columnName
			,@currentType = dataType
		FROM
			@columnInfo
		WHERE
			rowId = @currentRow;

		SET @maxValSql = N'SELECT @maxValueOut = max(' + @currentColumn + ') FROM ' + @currentTable

		EXECUTE sp_executesql @maxValSql, @paramDefinition, @maxValueOut=@maxValue OUTPUT;

		--Update max value and remaining value stats
		UPDATE @columnInfo
			SET maxValue = @maxValue
			,remainingValues = 
				CASE @currentType
					WHEN 'tinyint' THEN @maxTinyInt - @maxValue
					WHEN 'smallint' THEN @maxSmallInt - @maxValue
					WHEN 'int' THEN @maxInt - @maxValue
					WHEN 'bigint' THEN @maxBigInt - @maxValue
				END
		WHERE rowId = @currentRow;

		SET @currentRow = @currentRow + 1;
	END
 END


SELECT 
	tableName As 'Table Name'
	,columnName As 'Column Name'
	,dataType As 'Data Type'
	,maxValue As 'Max Value'
	,remainingValues As 'Remaining Values'
FROM 
	@columnInfo
WHERE 
	maxValue IS NOT NULL
ORDER BY 
	maxValue DESC;
