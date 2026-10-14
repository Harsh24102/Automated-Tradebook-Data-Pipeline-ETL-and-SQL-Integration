use harsh_data;

DECLARE @CutoffDate DATE = '2025-04-17';
DECLARE @CutoffDay INT = DAY(@CutoffDate);

DECLARE @ToDrop TABLE (TableName NVARCHAR(128));

-- Loop through all dates from 1 to @CutoffDay
DECLARE @i INT = 1;
WHILE @i <= @CutoffDay
BEGIN
    DECLARE @DayStr VARCHAR(2) = RIGHT('0' + CAST(@i AS VARCHAR), 2);
    DECLARE @DatePattern VARCHAR(10) = 'April_' + CAST(@i AS VARCHAR);
    DECLARE @MonthShortPattern VARCHAR(20) = 'APRIL_' + CAST(@i AS VARCHAR);
    DECLARE @ddmmyyPattern VARCHAR(6) = @DayStr + '0425';

    -- Insert matching tables except ALLOVER
    INSERT INTO @ToDrop (TableName)
    SELECT DISTINCT name  -- DISTINCT added here
    FROM sys.tables
    WHERE (
        name LIKE '%_IntraDay_%' OR
        name LIKE '%_Open_Position_%' OR
        name LIKE 'Tradebook_%' OR
        name LIKE 'G_T_Bhavcopy_FO_%' OR
        name LIKE 'BHAVCOPY%'
    )
    AND (
        name LIKE '%' + @DatePattern + '%' OR
        name LIKE '%' + @MonthShortPattern + '%' OR
        name LIKE '%' + @ddmmyyPattern + '%'
    )
    AND name NOT IN (
        'ALL_' + @DatePattern + '_RS',
        'NFT_' + @DatePattern + '_RS',
        'EXP_' + @DatePattern + '_RS'
    );

    SET @i += 1;
END;

-- Drop the selected tables
DECLARE @sql NVARCHAR(MAX);
DECLARE cur CURSOR FOR SELECT TableName FROM @ToDrop;

OPEN cur;
FETCH NEXT FROM cur INTO @sql;

WHILE @@FETCH_STATUS = 0
BEGIN
    BEGIN TRY
        EXEC('DROP TABLE [' + @sql + ']');
        PRINT 'Dropped: ' + @sql;
    END TRY
    BEGIN CATCH
        PRINT 'Could not drop: ' + @sql + ' - ' + ERROR_MESSAGE();
    END CATCH;

    FETCH NEXT FROM cur INTO @sql;
END

CLOSE cur;
DEALLOCATE cur;

