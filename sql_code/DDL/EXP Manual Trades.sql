USE [2526 EXPOPT];
GO

/*ALTER TABLE [dbo].[StroedData]
ADD IsManual BIT NOT NULL DEFAULT 0;

CREATE TRIGGER trg_PreventManualDelete
ON [dbo].[StroedData]
INSTEAD OF DELETE
AS
BEGIN
    DELETE FROM [dbo].[StroedData]
    WHERE ExchangeTradeTime IN (
        SELECT ExchangeTradeTime FROM deleted WHERE IsManual = 0
    );
END;*/

--To insert Manual Data
INSERT INTO [dbo].[StroedData] (
    Server, UserID, MAINTradeID, MAINOrderID, OrderID, ExchangeOrderNo, ExchangeTradeID,
    OrderTime, ExchangeOrderTime, ExchangeTradeTime, Exchange, SecurityID, Symbol, ExpiryDate,
    SecurityType, Side, OrderType, Quantity, PendingQuantity, Price, StrikePrice, ClientID,
    ReferenceText, CTCLID, MemberID, StrategyID, OptionType, OpenClose, ProductType, ManagerID,
    Pancard, TerminalInfo, AlgoID, AlgoCategory, ParticipantID, Multiplier, IsManual
)
SELECT
    Server, UserID, MAINTradeID, MAINOrderID, OrderID, ExchangeOrderNo, ExchangeTradeID,
    OrderTime, ExchangeOrderTime, ExchangeTradeTime, Exchange, SecurityID, Symbol, ExpiryDate,
    SecurityType, Side, OrderType, Quantity, PendingQuantity, Price, StrikePrice, ClientID,
    ReferenceText, CTCLID, MemberID, StrategyID, OptionType, OpenClose, ProductType, ManagerID,
    Pancard, TerminalInfo, AlgoID, AlgoCategory, ParticipantID, Multiplier,
    1 -- <- Marking it as manual
FROM [harsh_data].[dbo].[MergedTrade20250704];


SELECT * FROM [harsh_data].[dbo].[MergedTrade20250704];

--To Check for data from Every Angle
select * from [dbo].[StroedData]
where ExchangeTradeTime like '20250704%'
AND MAINOrderID = ''

select * from [dbo].[StroedData]
where ExchangeTradeTime like '20250716%'
--and UserID = 'NOVA'
AND MAINOrderID is null

SELECT * from [dbo].[StroedData]
where MAINTradeID IS NULL
OR MAINOrderID = ''
ORDER BY DataDate

select * from [dbo].[StroedData]
where MAINTradeID = ''
OR MAINOrderID IS NULL

--To Delete Extra Data
/*Delete from [dbo].[StroedData]
where ExchangeTradeTime like '20250716%'
AND MAINOrderID = ''*/

--To Change Manual Trades 
Update [dbo].[StroedData]
Set IsManual = 0
where ExchangeTradeTime like '20250716%'
AND MAINOrderID = ''

--To update ExpiryDate
Update [dbo].[StroedData]
Set ExpiryDate = '31JUL2025'
where ExchangeTradeTime like '20250704%'
AND MAINOrderID = ''

--To update DataDate
Update [dbo].[StroedData]
Set DataDate = '2025-07-04'
where ExchangeTradeTime like '20250704%'
AND MAINTradeID IS NULL

update [dbo].[StroedData]
Set DataDate = '2025-07-04'
where ExchangeTradeTime like '20250704%'
AND MAINOrderID = ''

--For Multiple Entry
INSERT INTO [2526 EXPOPT].[dbo].[StroedData] (
    Server, UserID, MAINTradeID, MAINOrderID, OrderID, ExchangeOrderNo, ExchangeTradeID,
    OrderTime, ExchangeOrderTime, ExchangeTradeTime, Exchange, SecurityID, Symbol, ExpiryDate,
    SecurityType, Side, OrderType, Quantity, PendingQuantity, Price, StrikePrice, ClientID,
    ReferenceText, CTCLID, MemberID, StrategyID, OptionType, OpenClose, ProductType, ManagerID,
    Pancard, TerminalInfo, AlgoID, AlgoCategory, ParticipantID, Multiplier
)
SELECT Server, UserID, MAINTradeID, MAINOrderID, OrderID, ExchangeOrderNo, ExchangeTradeID,
    OrderTime, ExchangeOrderTime, ExchangeTradeTime, Exchange, SecurityID, Symbol, ExpiryDate,
    SecurityType, Side, OrderType, Quantity, PendingQuantity, Price, StrikePrice, ClientID,
    ReferenceText, CTCLID, MemberID, StrategyID, OptionType, OpenClose, ProductType, ManagerID,
    Pancard, TerminalInfo, AlgoID, AlgoCategory, ParticipantID, Multiplier from [harsh_data].[dbo].[MergedTrade20250620__EXP]


