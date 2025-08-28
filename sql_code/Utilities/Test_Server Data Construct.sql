USE [2526 TEST_SERVER]

--Table Formation Upload
CREATE TABLE TEST_UPLOAD(
	[Server] VARCHAR(20),
	[UserID] VARCHAR(20),
	[MAINTradeID] VARCHAR(20),
	[MAINOrderID] VARCHAR(20),
	[OrderID] VARCHAR(20),
	[ExchangeOrderNo] VARCHAR(50),
	[ExchangeTradeID] VARCHAR(50),
	[OrderTime] VARCHAR(50),
	[ExchangeOrderTime] VARCHAR(50),
	[ExchangeTradeTime] VARCHAR(50),
	[Exchange] VARCHAR(20),
	[SecurityID] VARCHAR(20),
	[Symbol] VARCHAR(50),
	[ExpiryDate] VARCHAR(50),
	[SecurityType] VARCHAR(20),
	[Side] VARCHAR(20),
	[OrderType] VARCHAR(20),
	[Quantity] VARCHAR(20),
	[PendingQuantity] VARCHAR(20),
	[Price] VARCHAR(20),
	[StrikePrice] VARCHAR(20),
	[ClientID] VARCHAR(20),
	[ReferenceText] VARCHAR(50),
	[CTCLId] VARCHAR(20),
	[MemberID] VARCHAR(20),
	[StrategyID] VARCHAR(20),
	[OptionType] VARCHAR(20),
	[OpenClose] VARCHAR(20),
	[ProductType] VARCHAR(20),
	[ManagerID] VARCHAR(20),
	[Pancard] VARCHAR(50),
	[TerminalInfo] VARCHAR(50),
	[AlgoID] VARCHAR(20),
	[AlgoCategory] VARCHAR(20),
	[ParticipantID] VARCHAR(20),
	[Multiplier] VARCHAR(20)); 

--Table Formation StoredData
CREATE TABLE TEST_STORED_DATA(
	[Server] VARCHAR(20),
	[UserID] VARCHAR(20),
	[MAINTradeID] VARCHAR(20),
	[MAINOrderID] VARCHAR(20),
	[OrderID] VARCHAR(20),
	[ExchangeOrderNo] VARCHAR(50),
	[ExchangeTradeID] VARCHAR(50),
	[OrderTime] VARCHAR(50),
	[ExchangeOrderTime] VARCHAR(50),
	[ExchangeTradeTime] VARCHAR(50),
	[Exchange] VARCHAR(20),
	[SecurityID] VARCHAR(20),
	[Symbol] VARCHAR(50),
	[ExpiryDate] VARCHAR(50),
	[SecurityType] VARCHAR(20),
	[Side] VARCHAR(20),
	[OrderType] VARCHAR(20),
	[Quantity] VARCHAR(20),
	[PendingQuantity] VARCHAR(20),
	[Price] VARCHAR(20),
	[StrikePrice] VARCHAR(20),
	[ClientID] VARCHAR(20),
	[ReferenceText] VARCHAR(50),
	[CTCLId] VARCHAR(20),
	[MemberID] VARCHAR(20),
	[StrategyID] VARCHAR(20),
	[OptionType] VARCHAR(20),
	[OpenClose] VARCHAR(20),
	[ProductType] VARCHAR(20),
	[ManagerID] VARCHAR(20),
	[Pancard] VARCHAR(50),
	[TerminalInfo] VARCHAR(50),
	[AlgoID] VARCHAR(20),
	[AlgoCategory] VARCHAR(20),
	[ParticipantID] VARCHAR(20),
	[Multiplier] VARCHAR(20)); 

INSERT INTO [dbo].[TEST_STORED_DATA]
           ([Server]
           ,[UserID]
           ,[MAINTradeID]
           ,[MAINOrderID]
           ,[OrderID]
           ,[ExchangeOrderNo]
           ,[ExchangeTradeID]
           ,[OrderTime]
           ,[ExchangeOrderTime]
           ,[ExchangeTradeTime]
           ,[Exchange]
           ,[SecurityID]
           ,[Symbol]
           ,[ExpiryDate]
           ,[SecurityType]
           ,[Side]
           ,[OrderType]
           ,[Quantity]
           ,[PendingQuantity]
           ,[Price]
           ,[StrikePrice]
           ,[ClientID]
           ,[ReferenceText]
           ,[CTCLId]
           ,[MemberID]
           ,[StrategyID]
           ,[OptionType]
           ,[OpenClose]
           ,[ProductType]
           ,[ManagerID]
           ,[Pancard]
           ,[TerminalInfo]
           ,[AlgoID]
           ,[AlgoCategory]
           ,[ParticipantID]
           ,[Multiplier])
     select
		[Server]
           ,[UserID]
           ,[MAINTradeID]
           ,[MAINOrderID]
           ,[OrderID]
           ,[ExchangeOrderNo]
           ,[ExchangeTradeID]
           ,[OrderTime]
           ,[ExchangeOrderTime]
           ,[ExchangeTradeTime]
           ,[Exchange]
           ,[SecurityID]
           ,[Symbol]
           ,[ExpiryDate]
           ,[SecurityType]
           ,[Side]
           ,[OrderType]
           ,[Quantity]
           ,[PendingQuantity]
           ,[Price]
           ,[StrikePrice]
           ,[ClientID]
           ,[ReferenceText]
           ,[CTCLId]
           ,[MemberID]
           ,[StrategyID]
           ,[OptionType]
           ,[OpenClose]
           ,[ProductType]
           ,[ManagerID]
           ,[Pancard]
           ,[TerminalInfo]
           ,[AlgoID]
           ,[AlgoCategory]
           ,[ParticipantID]
           ,[Multiplier]
		from 
[dbo].[TEST_UPLOAD]

--UPLOAD LOG
IF OBJECT_ID('[dbo].[UploadLog]', 'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[UploadLog] (
        FileDate DATE,
        FileName NVARCHAR(500),
        Status NVARCHAR(100),
        Message NVARCHAR(1000),
        LoggedAt DATETIME DEFAULT GETDATE()
    );
END;
GO

--TO CHECK DATA
select * from TEST_STORED_DATA
ORDER BY ExchangeTradeTime DESC;    --OVERALL DATA

select * from TEST_STORED_DATA
where ExchangeTradeTime like '20250723%';    --TO CHECK PARTICULAR DATE 