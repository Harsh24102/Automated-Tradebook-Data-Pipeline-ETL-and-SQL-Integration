USE [2526 MCXVIVA]
GO

--EXEC [dbo].[2526MCXVIVAUPLOAD];
--SELECT * FROM [dbo].[UploadLog] ORDER BY LoggedAt DESC;

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- Create a log table to track results (if it doesn't already exist)
IF OBJECT_ID('[dbo].[UploadLog]', 'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[UploadLog] (
        FileDate DATE,
        FileName NVARCHAR(500),
        Status NVARCHAR(100),
        Message NVARCHAR(1000),
        LoggedAt DATETIME DEFAULT GETDATE()
    );
END
GO

CREATE OR ALTER PROCEDURE [dbo].[2526MCXVIVAUPLOAD]
AS
BEGIN
    DECLARE @StartDate DATE = '2025-04-03';
    DECLARE @EndDate DATE = '2025-06-04';
    DECLARE @CurrentDate DATE = @StartDate;
    DECLARE @FileName NVARCHAR(500);
    DECLARE @Sql NVARCHAR(MAX);
    DECLARE @FileExists INT;
    DECLARE @LogMsg NVARCHAR(1000);

    WHILE @CurrentDate <= @EndDate
    BEGIN
        -- Construct the file name for the day (TradeYYYYMMDD.csv)
        SET @FileName = 'E:\DATA\2025-2026\TRADEBOOK\MCX\Trade' + 
                        CONVERT(VARCHAR(8), @CurrentDate, 112) + '.csv';

        -- Clean UPLOAD table
        DELETE FROM [dbo].[UPLOAD];

        -- Check if file exists
        EXEC xp_fileexist @FileName, @FileExists OUTPUT;

        IF @FileExists = 1
        BEGIN
            SET @Sql = 'BULK INSERT [dbo].[UPLOAD] FROM ''' + @FileName + ''' ' +
                       'WITH (FIELDTERMINATOR = '','', ROWTERMINATOR = ''\n'', FIRSTROW = 2);';

            BEGIN TRY
                EXEC sp_executesql @Sql;

                -- Insert from UPLOAD to StoreData
                INSERT INTO [dbo].[StoreData] (
                    [Server], [UserID], [MAINTradeID], [MAINOrderID], [OrderID], [ExchangeOrderNo],
                    [ExchangeTradeID], [OrderTime], [ExchangeOrderTime], [ExchangeTradeTime], [Exchange],
                    [SecurityID], [Symbol], [ExpiryDate], [SecurityType], [Side], [OrderType], [Quantity],
                    [PendingQuantity], [Price], [StrikePrice], [ClientID], [ReferenceText], [CTCLId], 
                    [MemberID], [StrategyID], [OptionType], [OpenClose], [ProductType], [ManagerID], 
                    [Pancard], [TerminalInfo], [AlgoID], [AlgoCategory], [ParticipantID], [Multiplier]
                )
                SELECT * FROM [dbo].[UPLOAD];

                SET @LogMsg = 'Success';
                PRINT 'Data inserted from: ' + @FileName;
            END TRY
            BEGIN CATCH
                SET @LogMsg = ERROR_MESSAGE();
                PRINT 'Error inserting from file: ' + @FileName + ' - ' + @LogMsg;
            END CATCH

            -- Log the result
            INSERT INTO [dbo].[UploadLog] (FileDate, FileName, Status, Message)
            VALUES (@CurrentDate, @FileName, 
                    CASE WHEN @LogMsg = 'Success' THEN 'Success' ELSE 'Error' END,
                    @LogMsg);
        END
        ELSE
        BEGIN
            PRINT 'File does not exist: ' + @FileName;
            INSERT INTO [dbo].[UploadLog] (FileDate, FileName, Status, Message)
            VALUES (@CurrentDate, @FileName, 'Missing', 'File not found');
        END

        SET @CurrentDate = DATEADD(DAY, 1, @CurrentDate);
    END
END
GO
