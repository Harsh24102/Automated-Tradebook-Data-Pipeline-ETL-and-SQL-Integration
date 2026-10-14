Use harsh_data;

--select * from [dbo].[OP_EXP_2];

DECLARE @TableName NVARCHAR(128) = 'OP_EXP_4'; 
DECLARE @SQL NVARCHAR(MAX);

-- View current data
--SET @SQL = 'SELECT * FROM [dbo].[' + @TableName + ']';
EXEC sp_executesql @SQL;

-- Drop Total_Expense if exists
IF COL_LENGTH('dbo.' + @TableName, 'Total_Expense') IS NOT NULL
BEGIN
    SET @SQL = 'ALTER TABLE [dbo].[' + @TableName + '] DROP COLUMN Total_Expense;';
    EXEC sp_executesql @SQL;
END

-- Alter Date columns
SET @SQL = '
    ALTER TABLE [dbo].[' + @TableName + '] ALTER COLUMN ExpiryDate DATE;
    ALTER TABLE [dbo].[' + @TableName + '] ALTER COLUMN TradeDate DATE;

    UPDATE [dbo].[' + @TableName + '] 
    SET TradeDate = CAST(TradeDate AS DATE),
        ExpiryDate = CAST(ExpiryDate AS DATE);
';
EXEC sp_executesql @SQL;

-- Add Position column if not exists
IF COL_LENGTH('dbo.' + @TableName, 'Position') IS NULL
BEGIN
    SET @SQL = 'ALTER TABLE [dbo].[' + @TableName + '] ADD Position VARCHAR(20);';
    EXEC sp_executesql @SQL;
END

-- Update Position values
SET @SQL = '
    UPDATE [dbo].[' + @TableName + '] 
    SET Position = 
        CASE 
            WHEN TradeDate = ExpiryDate AND NetQuantity != 0 THEN ''Settle''
            ELSE ''Open''
        END;';
EXEC sp_executesql @SQL;

-- Add expense columns if not exist
IF COL_LENGTH('dbo.' + @TableName, 'TO_Charges_Buy') IS NULL
BEGIN
    SET @SQL = '
        ALTER TABLE [dbo].[' + @TableName + '] ADD 
            TO_Charges_Buy FLOAT, GST_On_TO_Buy FLOAT, 
            TO_Charges_Sell FLOAT, GST_On_TO_Sell FLOAT,
            SD_Buy FLOAT, SD_Sell FLOAT,
            STT_CTT_Buy FLOAT, STT_CTT_Sell FLOAT,
            SEBI_Buy FLOAT, GST_On_SEBI_Buy FLOAT, 
            SEBI_Sell FLOAT, GST_On_SEBI_Sell FLOAT,
            CL_Charges_Buy FLOAT, GST_On_CL_Buy FLOAT,
            CL_Charges_Sell FLOAT, GST_On_CL_Sell FLOAT;
    ';
    EXEC sp_executesql @SQL;
END

-- Default values to 0
SET @SQL = '
    UPDATE [dbo].[' + @TableName + ']
    SET 
        TO_Charges_Buy = 0, GST_On_TO_Buy = 0, SD_Buy = 0, STT_CTT_Buy = 0,
        TO_Charges_Sell = 0, GST_On_TO_Sell = 0, SD_Sell = 0, STT_CTT_Sell = 0,
        SEBI_Buy = 0, GST_On_SEBI_Buy = 0, SEBI_Sell = 0, GST_On_SEBI_Sell = 0,
        CL_Charges_Buy = 0, GST_On_CL_Buy = 0, CL_Charges_Sell = 0, GST_On_CL_Sell = 0;
';
EXEC sp_executesql @SQL;

-- Add Total_Expense column if not exists
IF COL_LENGTH('dbo.' + @TableName, 'Total_Expense') IS NULL
BEGIN
    SET @SQL = 'ALTER TABLE [dbo].[' + @TableName + '] ADD Total_Expense FLOAT;';
    EXEC sp_executesql @SQL;
END

-- Calculate Total Expense
SET @SQL = '
    UPDATE [dbo].[' + @TableName + ']
    SET Total_Expense = 
        ISNULL(TO_Charges_Buy, 0) + ISNULL(GST_On_TO_Buy, 0) +
        ISNULL(SD_Buy, 0) + ISNULL(STT_CTT_Buy, 0) + ISNULL(SEBI_Buy, 0) + ISNULL(GST_On_SEBI_Buy, 0) +
        ISNULL(CL_Charges_Buy, 0) + ISNULL(GST_On_CL_Buy, 0) +
        ISNULL(TO_Charges_Sell, 0) + ISNULL(GST_On_TO_Sell, 0) +
        ISNULL(SD_Sell, 0) + ISNULL(STT_CTT_Sell, 0) + ISNULL(SEBI_Sell, 0) + ISNULL(GST_On_SEBI_Sell, 0) +
        ISNULL(CL_Charges_Sell, 0) + ISNULL(GST_On_CL_Sell, 0);
';
EXEC sp_executesql @SQL;

-- Final step: Output all processed records
SET @SQL = 'SELECT * FROM [dbo].[' + @TableName + '];';
EXEC sp_executesql @SQL;
