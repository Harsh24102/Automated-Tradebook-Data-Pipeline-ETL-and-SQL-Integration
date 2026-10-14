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
    -- Step 1: Add columns for Sell Side if they do not exist
    DECLARE @colName NVARCHAR(100);
    DECLARE @cols TABLE (ColName NVARCHAR(100));
    
    INSERT INTO @cols (ColName) VALUES
        ('TO_Charges_Sell'), ('GST_On_TO_Sell'), ('SD_Sell'), ('STT_CTT_Sell'), 
        ('SEBI_Sell'), ('GST_On_SEBI_Sell'), ('CL_Charges_Sell'), ('GST_On_CL_Sell');

    DECLARE col_cur CURSOR FOR SELECT ColName FROM @cols;
    OPEN col_cur;
    FETCH NEXT FROM col_cur INTO @colName;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @sql = '
        IF COL_LENGTH(N''' + @tableName + ''', N''' + @colName + ''') IS NULL
        BEGIN
            ALTER TABLE ' + @tableName + ' ADD ' + QUOTENAME(@colName) + ' FLOAT;
        END;';
        EXEC sp_executesql @sql;

        FETCH NEXT FROM col_cur INTO @colName;
    END;

    CLOSE col_cur;
    DEALLOCATE col_cur;

    -- Step 2: Update Sell Side calculations
    SET @sql = '
    UPDATE ' + @tableName + '
    SET
        TO_Charges_Sell = CASE
            WHEN Exchange = ''NSEFO'' AND SecurityType IN (''FUTIDX'', ''FUTSTK'') THEN SellAmount * 0.0000173000
            WHEN Exchange = ''NSEFO'' AND SecurityType IN (''OPTIDX'', ''OPTSTK'') THEN SellAmount * 0.0003503000
            WHEN Exchange = ''BSEFO'' AND SecurityType IN (''FUTIDX'', ''FUTSTK'') THEN SellAmount * 0.0000000000
            WHEN Exchange = ''BSEFO'' AND SecurityType IN (''OPTIDX'', ''OPTSTK'') THEN SellAmount * 0.0000500000
            ELSE 0 END,

        GST_On_TO_Sell = CASE
            WHEN Exchange = ''NSEFO'' AND SecurityType IN (''FUTIDX'', ''FUTSTK'') THEN SellAmount * 0.000003114
            WHEN Exchange = ''NSEFO'' AND SecurityType IN (''OPTIDX'', ''OPTSTK'') THEN SellAmount * 0.000063054
            WHEN Exchange = ''BSEFO'' AND SecurityType IN (''FUTIDX'', ''FUTSTK'') THEN SellAmount * 0.000000000
            WHEN Exchange = ''BSEFO'' AND SecurityType IN (''OPTIDX'', ''OPTSTK'') THEN SellAmount * 0.000009000
            ELSE 0 END,

        SD_Sell = 0,

        STT_CTT_Sell = CASE
            WHEN Exchange IN (''NSEFO'',''BSEFO'') AND SecurityType IN (''FUTIDX'',''FUTSTK'') THEN SellAmount * 0.00020000
            WHEN Exchange IN (''NSEFO'',''BSEFO'') AND SecurityType IN (''OPTIDX'',''OPTSTK'') THEN SellAmount * 0.00100000
            ELSE 0 END,

        SEBI_Sell = CASE
            WHEN Exchange = ''NSEFO'' THEN SellAmount * 0.000001500
            WHEN Exchange = ''BSEFO'' THEN SellAmount * 0.000001500
			WHEN Exchange =''BSEFO'' AND SecurityType IN (''OPTIDX'',''OPTSTK'') AND Position = ''Settle'' THEN SellAmount * 0.000001500
			WHEN Exchange =''NSEFO'' AND SecurityType IN (''OPTIDX'',''OPTSTK'') AND Position = ''Settle'' THEN SellAmount * 0.000001500
            ELSE 0 END,

        GST_On_SEBI_Sell = CASE
            WHEN Exchange = ''NSEFO'' THEN SellAmount * 0.00000027
            WHEN Exchange = ''BSEFO'' THEN SellAmount * 0.00000027
			WHEN Exchange =''BSEFO'' AND SecurityType IN (''OPTIDX'',''OPTSTK'') AND Position = ''Settle'' THEN SellAmount * 0.00000027000
			WHEN Exchange =''NSEFO'' AND SecurityType IN (''OPTIDX'',''OPTSTK'') AND Position = ''Settle'' THEN SellAmount * 0.00000027000
            ELSE 0 END,

        CL_Charges_Sell = CASE
            WHEN Exchange = ''NSEFO'' AND SecurityType IN (''FUTIDX'',''FUTSTK'') THEN SellAmount * 0.0000015000
            WHEN Exchange = ''NSEFO'' AND SecurityType IN (''OPTIDX'',''OPTSTK'') THEN SellAmount * 0.000100000
            WHEN Exchange = ''BSEFO'' AND SecurityType IN (''FUTIDX'',''FUTSTK'') THEN SellAmount * 0.0000015000
            WHEN Exchange = ''BSEFO'' AND SecurityType IN (''OPTIDX'',''OPTSTK'') THEN SellAmount * 0.000100000
			WHEN Exchange =''BSEFO'' AND SecurityType IN (''OPTIDX'',''OPTSTK'') AND Position = ''Settle'' THEN SellAmount * 0.000100000
			WHEN Exchange =''NSEFO'' AND SecurityType IN (''OPTIDX'',''OPTSTK'') AND Position = ''Settle'' THEN SellAmount * 0.000100000
            ELSE 0 END,

        GST_On_CL_Sell = CASE
            WHEN Exchange = ''NSEFO'' AND SecurityType IN (''FUTIDX'',''FUTSTK'') THEN SellAmount * 0.000000270
            WHEN Exchange = ''NSEFO'' AND SecurityType IN (''OPTIDX'',''OPTSTK'') THEN SellAmount * 0.00001800
            WHEN Exchange = ''BSEFO'' AND SecurityType IN (''FUTIDX'',''FUTSTK'') THEN SellAmount * 0.000000270
            WHEN Exchange = ''BSEFO'' AND SecurityType IN (''OPTIDX'',''OPTSTK'') THEN SellAmount * 0.00001800
			WHEN Exchange =''BSEFO'' AND SecurityType IN (''OPTIDX'',''OPTSTK'') AND Position = ''Settle'' THEN SellAmount * 0.000018
			WHEN Exchange =''NSEFO'' AND SecurityType IN (''OPTIDX'',''OPTSTK'') AND Position = ''Settle'' THEN SellAmount * 0.000018
            ELSE 0 END;
    ';
    EXEC sp_executesql @sql;

    FETCH NEXT FROM cur INTO @tableName;
END;

CLOSE cur;
DEALLOCATE cur;
