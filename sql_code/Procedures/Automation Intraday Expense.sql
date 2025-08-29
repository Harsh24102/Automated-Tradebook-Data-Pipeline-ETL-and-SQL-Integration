Use harsh_data;

--select * from [dbo].[Intraday_EXP_2];

DECLARE @TableName NVARCHAR(128) = 'Intraday_EXP_4'; 
DECLARE @SQL NVARCHAR(MAX);
DECLARE @colName NVARCHAR(100);

-- 1. Preview current data
--SET @SQL = 'SELECT TOP 10 * FROM [dbo].[' + @TableName + ']';
EXEC sp_executesql @SQL;

-- 2. Drop known expense columns if they exist
DECLARE @dropCols TABLE (ColName NVARCHAR(100));
INSERT INTO @dropCols VALUES
('TO_Charges_Buy'), ('GST_On_TO_Buy'), ('SD_Buy'), ('STT_CTT_Buy'), 
('SEBI_Buy'), ('GST_On_SEBI_Buy'), ('CL_Charges_Buy'), ('GST_On_CL_Buy'),
('TO_Charges_Sell'), ('GST_On_TO_Sell'), ('SD_Sell'), ('STT_CTT_Sell'), 
('SEBI_Sell'), ('GST_On_SEBI_Sell'), ('CL_Charges_Sell'), ('GST_On_CL_Sell'),
('Total_Expense');

DECLARE drop_cursor CURSOR FOR SELECT ColName FROM @dropCols;
OPEN drop_cursor;
FETCH NEXT FROM drop_cursor INTO @colName;
WHILE @@FETCH_STATUS = 0
BEGIN
    IF COL_LENGTH('dbo.' + @TableName, @colName) IS NOT NULL
    BEGIN
        SET @SQL = 'ALTER TABLE [dbo].[' + @TableName + '] DROP COLUMN [' + @colName + '];';
        EXEC sp_executesql @SQL;
    END
    FETCH NEXT FROM drop_cursor INTO @colName;
END
CLOSE drop_cursor;
DEALLOCATE drop_cursor;

-- 3. Alter columns to DATE and normalize them
SET @SQL = '
ALTER TABLE [dbo].[' + @TableName + '] ALTER COLUMN TradeDate DATE;
ALTER TABLE [dbo].[' + @TableName + '] ALTER COLUMN ExpiryDate DATE;

UPDATE [dbo].[' + @TableName + ']
SET TradeDate = CAST(TradeDate AS DATE), ExpiryDate = CAST(ExpiryDate AS DATE);
';
EXEC sp_executesql @SQL;

-- 4. Add and update Position column
IF COL_LENGTH('dbo.' + @TableName, 'Position') IS NULL
BEGIN
    SET @SQL = 'ALTER TABLE [dbo].[' + @TableName + '] ADD Position VARCHAR(20);';
    EXEC sp_executesql @SQL;
END

SET @SQL = '
UPDATE [dbo].[' + @TableName + ']
SET Position = CASE
    WHEN TradeDate = ExpiryDate AND NetQuantity != 0 THEN ''Settle''
    ELSE ''Intra''
END;';
EXEC sp_executesql @SQL;

-- 5. Add missing expense columns
DECLARE @expenseCols TABLE (ColName NVARCHAR(100));
INSERT INTO @expenseCols VALUES
('TO_Charges_Buy'), ('GST_On_TO_Buy'), ('SD_Buy'), ('STT_CTT_Buy'),
('SEBI_Buy'), ('GST_On_SEBI_Buy'), ('CL_Charges_Buy'), ('GST_On_CL_Buy'),
('TO_Charges_Sell'), ('GST_On_TO_Sell'), ('SD_Sell'), ('STT_CTT_Sell'),
('SEBI_Sell'), ('GST_On_SEBI_Sell'), ('CL_Charges_Sell'), ('GST_On_CL_Sell'),
('Total_Expense');

DECLARE add_cursor CURSOR FOR SELECT ColName FROM @expenseCols;
OPEN add_cursor;
FETCH NEXT FROM add_cursor INTO @colName;
WHILE @@FETCH_STATUS = 0
BEGIN
    SET @SQL = '
    IF COL_LENGTH(''dbo.' + @TableName + ''', ''' + @colName + ''') IS NULL
    BEGIN
        ALTER TABLE [dbo].[' + @TableName + '] ADD [' + @colName + '] FLOAT;
    END;';
    EXEC sp_executesql @SQL;
    FETCH NEXT FROM add_cursor INTO @colName;
END
CLOSE add_cursor;
DEALLOCATE add_cursor;

-- 6. BUY Expense Calculation
SET @SQL = '
UPDATE [dbo].[' + @TableName + ']
SET
    TO_Charges_Buy = CASE
        WHEN Exchange = ''NSEFO'' AND SecurityType IN (''FUTIDX'', ''FUTSTK'') THEN BuyAmount * 0.0000173
        WHEN Exchange = ''NSEFO'' AND SecurityType IN (''OPTIDX'', ''OPTSTK'') THEN BuyAmount * 0.0003503
        WHEN Exchange = ''BSEFO'' AND SecurityType IN (''OPTIDX'', ''OPTSTK'') THEN BuyAmount * 0.00005
        ELSE 0 END,

    GST_On_TO_Buy = CASE
        WHEN Exchange = ''NSEFO'' AND SecurityType IN (''FUTIDX'', ''FUTSTK'') THEN BuyAmount * 0.000003114
        WHEN Exchange = ''NSEFO'' AND SecurityType IN (''OPTIDX'', ''OPTSTK'') THEN BuyAmount * 0.000063054
        WHEN Exchange = ''BSEFO'' AND SecurityType IN (''OPTIDX'', ''OPTSTK'') THEN BuyAmount * 0.000009
        ELSE 0 END,

    SD_Buy = CASE
        WHEN SecurityType IN (''FUTIDX'', ''FUTSTK'') THEN BuyAmount * 0.00002
        WHEN SecurityType IN (''OPTIDX'', ''OPTSTK'') THEN BuyAmount * 0.00003
        ELSE 0 END,

    STT_CTT_Buy = 0,

    SEBI_Buy = BuyAmount * 0.0000015,
    GST_On_SEBI_Buy = BuyAmount * 0.00000027,

    CL_Charges_Buy = CASE
        WHEN SecurityType IN (''OPTIDX'', ''OPTSTK'') THEN BuyAmount * 0.0001
        ELSE BuyAmount * 0.0000015 END,

    GST_On_CL_Buy = CASE
        WHEN SecurityType IN (''OPTIDX'', ''OPTSTK'') THEN BuyAmount * 0.000018
        ELSE BuyAmount * 0.00000027 END;';
EXEC sp_executesql @SQL;

-- 7. SELL Expense Calculation
SET @SQL = '
UPDATE [dbo].[' + @TableName + ']
SET
    TO_Charges_Sell = CASE
        WHEN Exchange = ''NSEFO'' AND SecurityType IN (''FUTIDX'', ''FUTSTK'') THEN SellAmount * 0.0000173
        WHEN Exchange = ''NSEFO'' AND SecurityType IN (''OPTIDX'', ''OPTSTK'') THEN SellAmount * 0.0003503
        WHEN Exchange = ''BSEFO'' AND SecurityType IN (''OPTIDX'', ''OPTSTK'') THEN SellAmount * 0.00005
        ELSE 0 END,

    GST_On_TO_Sell = CASE
        WHEN Exchange = ''NSEFO'' AND SecurityType IN (''FUTIDX'', ''FUTSTK'') THEN SellAmount * 0.000003114
        WHEN Exchange = ''NSEFO'' AND SecurityType IN (''OPTIDX'', ''OPTSTK'') THEN SellAmount * 0.000063054
        WHEN Exchange = ''BSEFO'' AND SecurityType IN (''OPTIDX'', ''OPTSTK'') THEN SellAmount * 0.000009
        ELSE 0 END,

    SD_Sell = 0,

    STT_CTT_Sell = CASE
        WHEN SecurityType IN (''FUTIDX'', ''FUTSTK'') THEN SellAmount * 0.0002
        WHEN SecurityType IN (''OPTIDX'', ''OPTSTK'') THEN SellAmount * 0.001
        ELSE 0 END,

    SEBI_Sell = SellAmount * 0.0000015,
    GST_On_SEBI_Sell = SellAmount * 0.00000027,

    CL_Charges_Sell = CASE
        WHEN SecurityType IN (''OPTIDX'', ''OPTSTK'') THEN SellAmount * 0.0001
        ELSE SellAmount * 0.0000015 END,

    GST_On_CL_Sell = CASE
        WHEN SecurityType IN (''OPTIDX'', ''OPTSTK'') THEN SellAmount * 0.000018
        ELSE SellAmount * 0.00000027 END;';
EXEC sp_executesql @SQL;

-- 8. Total Expense Calculation
SET @SQL = '
UPDATE [dbo].[' + @TableName + ']
SET Total_Expense = 
    ISNULL(TO_Charges_Buy, 0) + ISNULL(GST_On_TO_Buy, 0) + ISNULL(SD_Buy, 0) + ISNULL(STT_CTT_Buy, 0) +
    ISNULL(SEBI_Buy, 0) + ISNULL(GST_On_SEBI_Buy, 0) + ISNULL(CL_Charges_Buy, 0) + ISNULL(GST_On_CL_Buy, 0) +
    ISNULL(TO_Charges_Sell, 0) + ISNULL(GST_On_TO_Sell, 0) + ISNULL(SD_Sell, 0) + ISNULL(STT_CTT_Sell, 0) +
    ISNULL(SEBI_Sell, 0) + ISNULL(GST_On_SEBI_Sell, 0) + ISNULL(CL_Charges_Sell, 0) + ISNULL(GST_On_CL_Sell, 0);';
EXEC sp_executesql @SQL;

-- Final step: Output all processed records
SET @SQL = 'SELECT * FROM [dbo].[' + @TableName + '];';
EXEC sp_executesql @SQL;
