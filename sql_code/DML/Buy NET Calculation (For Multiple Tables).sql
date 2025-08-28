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
    -- Step 1: Add columns if not exist
    DECLARE @colName NVARCHAR(100);
    DECLARE @cols TABLE (ColName NVARCHAR(100));
    
    INSERT INTO @cols (ColName) VALUES
        ('TO_Charges_Buy'), ('GST_On_TO_Buy'), ('SD_Buy'), ('STT_CTT_Buy'), 
        ('SEBI_Buy'), ('GST_On_SEBI_Buy'), ('CL_Charges_Buy'), ('GST_On_CL_Buy');

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

    -- Step 2: Now update the columns
    SET @sql = '
    UPDATE ' + @tableName + '
    SET
        TO_Charges_Buy = CASE
            WHEN Exchange = ''NSEFO'' AND SecurityType IN (''FUTIDX'', ''FUTSTK'') THEN BuyAmount * 0.0000173000
            WHEN Exchange = ''NSEFO'' AND SecurityType IN (''OPTIDX'', ''OPTSTK'') THEN BuyAmount * 0.0003503000
            WHEN Exchange = ''BSEFO'' AND SecurityType IN (''FUTIDX'', ''FUTSTK'') THEN BuyAmount * 0.0000000000
            WHEN Exchange = ''BSEFO'' AND SecurityType IN (''OPTIDX'', ''OPTSTK'') THEN BuyAmount * 0.0000500000
            ELSE 0 END,

        GST_On_TO_Buy = CASE
            WHEN Exchange = ''NSEFO'' AND SecurityType IN (''FUTIDX'', ''FUTSTK'') THEN BuyAmount * 0.000003114
            WHEN Exchange = ''NSEFO'' AND SecurityType IN (''OPTIDX'', ''OPTSTK'') THEN BuyAmount * 0.000063054
			WHEN Exchange = ''BSEFO'' AND SecurityType IN (''FUTIDX'', ''FUTSTK'') THEN BuyAmount * 0.000000000
            WHEN Exchange = ''BSEFO'' AND SecurityType IN (''OPTIDX'', ''OPTSTK'') THEN BuyAmount * 0.000009000
            ELSE 0 END,

        SD_Buy = CASE
            WHEN Exchange IN (''NSEFO'',''BSEFO'') AND SecurityType IN (''FUTIDX'',''FUTSTK'') THEN BuyAmount * 0.00002000
            WHEN Exchange IN (''NSEFO'',''BSEFO'') AND SecurityType IN (''OPTIDX'',''OPTSTK'') THEN BuyAmount * 0.00003000
            ELSE 0 END,

        STT_CTT_Buy = 0,

        SEBI_Buy = CASE
            WHEN Exchange = ''NSEFO'' THEN BuyAmount * 0.000001500
            WHEN Exchange = ''BSEFO'' THEN BuyAmount * 0.000001500
			WHEN Exchange =''BSEFO'' AND SecurityType IN (''OPTIDX'',''OPTSTK'') AND Position = ''Settle'' THEN BuyAmount * 0.000001500
			WHEN Exchange =''NSEFO'' AND SecurityType IN (''OPTIDX'',''OPTSTK'') AND Position = ''Settle'' THEN BuyAmount * 0.000001500
            ELSE 0 END,

        GST_On_SEBI_Buy = CASE
            WHEN Exchange = ''NSEFO'' THEN BuyAmount * 0.00000027
            WHEN Exchange = ''BSEFO'' THEN BuyAmount * 0.00000027
			WHEN Exchange =''BSEFO'' AND SecurityType IN (''OPTIDX'',''OPTSTK'') AND Position = ''Settle'' THEN BuyAmount * 0.00000027000
			WHEN Exchange =''NSEFO'' AND SecurityType IN (''OPTIDX'',''OPTSTK'') AND Position = ''Settle'' THEN BuyAmount * 0.00000027000
            ELSE 0 END,

        CL_Charges_Buy = CASE
            WHEN Exchange = ''NSEFO'' AND SecurityType IN (''FUTIDX'',''FUTSTK'') THEN BuyAmount * 0.0000015000
            WHEN Exchange = ''NSEFO'' AND SecurityType IN (''OPTIDX'',''OPTSTK'') THEN BuyAmount * 0.000100000
            WHEN Exchange = ''BSEFO'' AND SecurityType IN (''FUTIDX'',''FUTSTK'') THEN BuyAmount * 0.0000015000
            WHEN Exchange = ''BSEFO'' AND SecurityType IN (''OPTIDX'',''OPTSTK'') THEN BuyAmount * 0.000100000
			WHEN Exchange =''BSEFO'' AND SecurityType IN (''OPTIDX'',''OPTSTK'') AND Position = ''Settle'' THEN BuyAmount * 0.000100000
			WHEN Exchange =''NSEFO'' AND SecurityType IN (''OPTIDX'',''OPTSTK'') AND Position = ''Settle'' THEN BuyAmount * 0.000100000
            ELSE 0 END,

        GST_On_CL_Buy = CASE
            WHEN Exchange = ''NSEFO'' AND SecurityType IN (''FUTIDX'',''FUTSTK'') THEN BuyAmount * 0.00000027000
            WHEN Exchange = ''NSEFO'' AND SecurityType IN (''OPTIDX'',''OPTSTK'') THEN BuyAmount * 0.0000180000
            WHEN Exchange = ''BSEFO'' AND SecurityType IN (''FUTIDX'',''FUTSTK'') THEN BuyAmount * 0.00000027000
            WHEN Exchange = ''BSEFO'' AND SecurityType IN (''OPTIDX'',''OPTSTK'') THEN BuyAmount * 0.0000180000
			WHEN Exchange =''BSEFO'' AND SecurityType IN (''OPTIDX'',''OPTSTK'') AND Position = ''Settle'' THEN BuyAmount * 0.000018
			WHEN Exchange =''NSEFO'' AND SecurityType IN (''OPTIDX'',''OPTSTK'') AND Position = ''Settle'' THEN BuyAmount * 0.000018
            ELSE 0 END;
    ';
    EXEC sp_executesql @sql;

    FETCH NEXT FROM cur INTO @tableName;
END;

CLOSE cur;
DEALLOCATE cur;
