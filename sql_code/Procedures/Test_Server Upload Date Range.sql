USE [2526 TEST_SERVER];
GO

CREATE OR ALTER PROCEDURE [dbo].[TEST_SERVER_UPLOAD_DATERANGE]
    @StartDate DATE,
    @EndDate DATE
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @CurrentDate DATE = @StartDate;
    DECLARE @FileName NVARCHAR(500);
    DECLARE @Sql NVARCHAR(MAX);
    DECLARE @FileExists INT;
    DECLARE @LogMsg NVARCHAR(1000);

    WHILE @CurrentDate <= @EndDate
    BEGIN
        -- Construct file name for current date
        SET @FileName = 'E:\DATA\2025-2026\TEST SERVER TRADEBOOK\Trade' + 
                        CONVERT(VARCHAR(8), @CurrentDate, 112) + '.csv';

        -- Truncate TEST_UPLOAD before loading new data
        TRUNCATE TABLE [dbo].[TEST_UPLOAD];

        -- Check if file exists
        EXEC xp_fileexist @FileName, @FileExists OUTPUT;

        IF @FileExists = 1
        BEGIN
            SET @Sql = 'BULK INSERT [dbo].[TEST_UPLOAD] FROM ''' + @FileName + ''' ' +
                       'WITH (FIELDTERMINATOR = '','', ROWTERMINATOR = ''\n'', FIRSTROW = 2);';

            BEGIN TRY
                EXEC sp_executesql @Sql;

                -- Insert into TEST_STORED_DATA from TEST_UPLOAD
                INSERT INTO [dbo].[TEST_STORED_DATA] (
                    [Server], [UserID], [MAINTradeID], [MAINOrderID], [OrderID], [ExchangeOrderNo],
                    [ExchangeTradeID], [OrderTime], [ExchangeOrderTime], [ExchangeTradeTime], [Exchange],
                    [SecurityID], [Symbol], [ExpiryDate], [SecurityType], [Side], [OrderType], [Quantity],
                    [PendingQuantity], [Price], [StrikePrice], [ClientID], [ReferenceText], [CTCLId], 
                    [MemberID], [StrategyID], [OptionType], [OpenClose], [ProductType], [ManagerID], 
                    [Pancard], [TerminalInfo], [AlgoID], [AlgoCategory], [ParticipantID], [Multiplier]
                )
                SELECT * FROM [dbo].[TEST_UPLOAD];

                SET @LogMsg = 'Success';
                PRINT 'Data inserted from: ' + @FileName;
            END TRY
            BEGIN CATCH
                SET @LogMsg = ERROR_MESSAGE();
                PRINT 'Error inserting from file: ' + @FileName + ' - ' + @LogMsg;
            END CATCH

            -- Log results
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
END;
GO


EXEC [dbo].[TEST_SERVER_UPLOAD_DATERANGE] @StartDate = '2025-07-03', @EndDate = '2025-07-03';