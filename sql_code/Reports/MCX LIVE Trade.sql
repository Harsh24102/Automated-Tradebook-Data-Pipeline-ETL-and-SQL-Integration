USE [2526 MCXVIVA]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[MCXVIVALive]
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Clear staging table
        DELETE FROM [dbo].[UPLOAD];

        -- Construct file path dynamically
        DECLARE @FileName NVARCHAR(400);
        DECLARE @Sql NVARCHAR(MAX);

        SET @FileName = 'E:\DATA\2025-2026\TRADEBOOK\MCX\Trade' 
                        + CONVERT(VARCHAR(4), YEAR(GETDATE())) 
                        + RIGHT('00' + CONVERT(VARCHAR(2), MONTH(GETDATE())), 2) 
                        + RIGHT('00' + CONVERT(VARCHAR(2), DAY(GETDATE())), 2) 
                        + '.csv';

        -- Check if file exists
        DECLARE @Exists INT;
        EXEC master.dbo.xp_fileexist @FileName, @Exists OUTPUT;

        IF @Exists = 0
        BEGIN
            PRINT 'CSV file not found for today: ' + @FileName;
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Perform BULK INSERT
        SET @Sql = 'BULK INSERT [dbo].[UPLOAD] FROM ''' + @FileName + ''' ' +
                   'WITH (FIELDTERMINATOR = '','', ROWTERMINATOR = ''\n'', FIRSTROW = 2, TABLOCK);';

        EXEC sp_executesql @Sql;

        -- Delete today's data from StoreData
        DELETE FROM [dbo].[StoreData]
        WHERE ExchangeTradeTime LIKE '%' + CONVERT(VARCHAR(4), YEAR(GETDATE())) 
                                       + RIGHT('00' + CONVERT(VARCHAR(2), MONTH(GETDATE())), 2) 
                                       + RIGHT('00' + CONVERT(VARCHAR(2), DAY(GETDATE())), 2) + '%';

        -- Insert new data into StoreData
        INSERT INTO [dbo].[StoreData]
               ([Server], [UserID], [MAINTradeID], [MAINOrderID], [OrderID], [ExchangeOrderNo], [ExchangeTradeID],
                [OrderTime], [ExchangeOrderTime], [ExchangeTradeTime], [Exchange], [SecurityID], [Symbol],
                [ExpiryDate], [SecurityType], [Side], [OrderType], [Quantity], [PendingQuantity], [Price], 
                [StrikePrice], [ClientID], [ReferenceText], [CTCLID], [MemberID], [StrategyID], [OptionType], 
                [OpenClose], [ProductType], [ManagerID], [Pancard], [TerminalInfo], [AlgoID], [AlgoCategory], 
                [ParticipantID], [Multiplier])
        SELECT 
               [Server], [UserID], [MAINTradeID], [MAINOrderID], [OrderID], [ExchangeOrderNo], [ExchangeTradeID],
               [OrderTime], [ExchangeOrderTime], [ExchangeTradeTime], [Exchange], [SecurityID], [Symbol],
               [ExpiryDate], [SecurityType], [Side], [OrderType], [Quantity], [PendingQuantity], [Price], 
               [StrikePrice], [ClientID], [ReferenceText], [CTCLID], [MemberID], [StrategyID], [OptionType], 
               [OpenClose], [ProductType], [ManagerID], [Pancard], [TerminalInfo], [AlgoID], [AlgoCategory], 
               [ParticipantID], [Multiplier]
        FROM [dbo].[UPLOAD];

        -- Clear CreateToken
        DELETE FROM [dbo].[CreateToken];

        -- Insert calculated data safely
        INSERT INTO [dbo].[CreateToken]
               ([ManagerID], [ReferenceText], [StrategyID], [Exchange], [SecurityType], [Symbol], [ExpiryDate],
                [OptionType], [StrikePrice], [BuyQuantity], [BuyAmount], [SellQuantity], [SellAmount],
                [ExchangeTradeTime], [Multiplier])
        SELECT 
            ISNULL([ManagerID], '') AS [ManagerID],
            ISNULL([ReferenceText], '0') AS [ReferenceText],
            TRY_CAST([StrategyID] AS FLOAT),
            [Exchange],
            [SecurityType],
            [Symbol],
            UPPER(FORMAT(TRY_CONVERT(DATE, [ExpiryDate], 112), 'ddMMMyyyy')),
            CASE WHEN ISNULL([OptionType], 'XX') = 'XX' THEN '' ELSE [OptionType] END,
            CASE 
                WHEN TRY_CAST([StrikePrice] AS FLOAT) IS NULL OR TRY_CAST([StrikePrice] AS FLOAT) = -0.01 THEN '' 
                ELSE CAST(TRY_CAST([StrikePrice] AS FLOAT) AS VARCHAR) 
            END,
            SUM(CASE WHEN [Side] = 'Buy' THEN 
                     ISNULL(TRY_CAST([Quantity] AS FLOAT), 0) * ISNULL(TRY_CAST([Multiplier] AS FLOAT), 1)
                     ELSE 0 END),
            SUM(CASE WHEN [Side] = 'Buy' THEN 
                     ISNULL(TRY_CAST([Quantity] AS FLOAT), 0) * ISNULL(TRY_CAST([Multiplier] AS FLOAT), 1) * ISNULL(TRY_CAST([Price] AS FLOAT), 0)
                     ELSE 0 END),
            SUM(CASE WHEN [Side] = 'Sell' THEN 
                     ISNULL(TRY_CAST([Quantity] AS FLOAT), 0) * ISNULL(TRY_CAST([Multiplier] AS FLOAT), 1)
                     ELSE 0 END),
            SUM(CASE WHEN [Side] = 'Sell' THEN 
                     ISNULL(TRY_CAST([Quantity] AS FLOAT), 0) * ISNULL(TRY_CAST([Multiplier] AS FLOAT), 1) * ISNULL(TRY_CAST([Price] AS FLOAT), 0)
                     ELSE 0 END),
            UPPER(FORMAT(CAST(GETDATE() AS DATE), 'ddMMMyyyy')),
            ISNULL([Multiplier], '1')  -- still varchar, for display or export
        FROM [dbo].[StoreData]
        WHERE TRY_CONVERT(DATE, [ExpiryDate], 112) >= CAST(GETDATE() AS DATE)
        GROUP BY
            [ManagerID], [ReferenceText], [StrategyID], [Exchange], [SecurityType], [Symbol], [ExpiryDate],
            [OptionType], [StrikePrice], [Multiplier]
        HAVING 
            ABS(
                SUM(CASE WHEN [Side] = 'Buy' THEN ISNULL(TRY_CAST([Quantity] AS FLOAT), 0) * ISNULL(TRY_CAST([Multiplier] AS FLOAT), 1) ELSE 0 END) -
                SUM(CASE WHEN [Side] = 'Sell' THEN ISNULL(TRY_CAST([Quantity] AS FLOAT), 0) * ISNULL(TRY_CAST([Multiplier] AS FLOAT), 1) ELSE 0 END)
            ) > 0.0001;

        COMMIT TRANSACTION;
        PRINT 'Data imported and processed successfully.';
    END TRY

    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error occurred: ' + ERROR_MESSAGE();
    END CATCH
END
GO
