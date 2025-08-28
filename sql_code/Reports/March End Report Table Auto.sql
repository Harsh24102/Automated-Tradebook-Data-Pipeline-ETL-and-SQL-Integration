CREATE PROCEDURE LoadDataIntoCommonReport
AS
BEGIN
    -- Step 1: Clear the Common Report Table 
    TRUNCATE TABLE Common_Report_Table;

    -- Step 2: Insert data from Tb_Opt Table
    INSERT INTO Common_Report_Table ([Server],[ManagerID],[UserID],[ClientID],[MemberID],[Token],[Exchange],[StrategyID],[SecurityType],
	[SecurityID],[Symbol],[ExpiryDate],[OptionType],[StrikePrice],[Side],[Quantity],[Price],[TradeDate],[BuyQuantity],[SellQuantity],[BuyAmount],[SellAmount])
    SELECT [Server],[ManagerID],[UserID],[ClientID],[MemberID],[Token],[Exchange],[StrategyID],[SecurityType],
	[SecurityID],[Symbol],[ExpiryDate],[OptionType],[StrikePrice],[Side],[Quantity],[Price],[ExchangeTradeTime],[BuyQuantity],[SellQuantity],[BuyAmount],[SellAmount]
    FROM TB_Opt 

    -- Step 3: Load data from the Club13 CSV file into a temp table
	CREATE PROCEDURE ImportCSV
	AS
	BEGIN
		DECLARE @FilePath NVARCHAR(255)
		DECLARE @FileExists INT
		DECLARE @SQL NVARCHAR(MAX)

		-- Generate file path dynamically based on today's date
		SET @FilePath = 'F:\DATA TEAM\Process NSE\CLUBSQL\club' + FORMAT(GETDATE(), 'dd') + '.csv'

		-- Check if file exists
		EXEC xp_fileexist @FilePath, @FileExists OUTPUT

		-- If file exists, proceed with BULK INSERT
		IF @FileExists = 1
		BEGIN
			SET @SQL = '
			BULK INSERT Temp_Club_890
			FROM ''' + @FilePath + '''
			WITH (
				FIELDTERMINATOR = '','',
				ROWTERMINATOR = ''\n'',
				FIRSTROW = 2
			);'
        
			EXEC sp_executesql @SQL
		END
		ELSE
		BEGIN
			PRINT 'File does not exist. Skipping import.'
		END
	END;

    -- Step 4: Insert the data from Temp_Club13 into Common_Report_Table
    INSERT INTO Common_Report_Table (
    [CompanyCode], [NetQuantity], [NetRate], [NetAmount], [ClosingPrice], [NotProfit], [TRADING_QUANTITY], [TRADING_AMOUNT]
	)
	SELECT 
    t1.[COMPANY_CODE], 
    t1.[NET_QUANTITY], 
    t1.[NET_RATE], 
    t1.[NET_AMOUNT], 
    t1.[CLOSING_PRICE], 
    t1.[NOT_PROFIT], 
    t1.[TRADING_QUANTITY], 
    t1.[TRADING_AMOUNT]
	FROM Temp_Club13 t1
	Left JOIN Common_Report_Table t2
    ON t1.[TradeDate] = t2.[TradeDate]
    AND t1.[ManagerID] = t2.[ManagerID]
    AND t1.[SCRIP_SYMBOL] = t2.[Symbol]
    AND t1.[ExpiryDate] = t2.[ExpiryDate]
    AND t1.[Strike_Price] = t2.[StrikePrice]
    AND t1.[Option_Type] = t2.[OptionType]
	WHERE t1.[COMPANY_CODE] = 'DERIVATIVES';

    -- Step 5: Load data from the Profit CSV file into a temp table
    BULK INSERT Temp_Profit
    FROM 'F:\path_to_your_file\Profit.csv'
    WITH (
        FIELDTERMINATOR = ',', 
        ROWTERMINATOR = '\n', 
        FIRSTROW = 2
    );

    -- Step 6: Insert the data from Temp_Profit into Common_Report_Table
    INSERT INTO Common_Report_Table (Column1, Column2)
    SELECT Column1, Column2
    FROM Temp_Profit;

    -- Optional: Clean up temp tables if needed
    DROP TABLE Temp_Club13;
    DROP TABLE Temp_Profit;
END;
