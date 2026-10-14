USE harsh_data;


DECLARE @TableList TABLE (TableName NVARCHAR(256));
INSERT INTO @TableList (TableName) VALUES
('[Intraday_EXP_30]')
;

DECLARE @tableName NVARCHAR(256);
DECLARE @sql NVARCHAR(MAX);

DECLARE cur CURSOR FOR SELECT TableName FROM @TableList;
OPEN cur;
FETCH NEXT FROM cur INTO @tableName;

WHILE @@FETCH_STATUS = 0
BEGIN
    -- Step 1: Ensure Total_Expense column exists
    SET @sql = '
    IF COL_LENGTH(N''' + @tableName + ''', ''Total_Expense'') IS NULL
    BEGIN
        ALTER TABLE ' + @tableName + ' ADD Total_Expense FLOAT;
    END;';
    EXEC sp_executesql @sql;

    -- Step 2: Safely update Total_Expense
    SET @sql = '
    UPDATE ' + @tableName + '
    SET Total_Expense = 
        ISNULL(TO_Charges_Buy, 0) +
        ISNULL(GST_On_TO_Buy, 0) +
        ISNULL(SD_Buy, 0) +
        ISNULL(STT_CTT_Buy, 0) +
        ISNULL(SEBI_Buy, 0) +
        ISNULL(GST_On_SEBI_Buy, 0) +
        ISNULL(CL_Charges_Buy, 0) +
        ISNULL(GST_On_CL_Buy, 0) +
        ISNULL(TO_Charges_Sell, 0) +
        ISNULL(GST_On_TO_Sell, 0) +
        ISNULL(SD_Sell, 0) +
        ISNULL(STT_CTT_Sell, 0) +
        ISNULL(SEBI_Sell, 0) +
        ISNULL(GST_On_SEBI_Sell, 0) +
        ISNULL(CL_Charges_Sell, 0) +
        ISNULL(GST_On_CL_Sell, 0);
    ';
    EXEC sp_executesql @sql;

    FETCH NEXT FROM cur INTO @tableName;
END;

CLOSE cur;
DEALLOCATE cur;
