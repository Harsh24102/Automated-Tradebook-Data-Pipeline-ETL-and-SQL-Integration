USE [2526 ALLOPT]
GO

CREATE TRIGGER trg_PreventManualDelete
ON [dbo].[StoreData]
INSTEAD OF DELETE
AS
BEGIN
    DELETE FROM [dbo].[StoreData]
    WHERE ExchangeTradeTime IN (
        SELECT ExchangeTradeTime FROM deleted WHERE IsManual = 0
    );
END;

ALTER TABLE [dbo].[StoreData]
ADD IsManual BIT NOT NULL DEFAULT 0;

INSERT INTO [dbo].[StoreData] (
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
from [harsh_data].[dbo].[MergedTrade20250424-ALLOPT]


select * from  [dbo].StoreData
where  MAINOrderID is null

DELETE from  [dbo].StoreData
where ExchangeTradeTime like '20250424%'
AND MAINOrderID = ''

select * from  [dbo].StoreData
where ExchangeTradeTime like '20250424%'
--AND Exchange = 'NSEFO'
AND MAINOrderID = ''

select * from [dbo].StoreData
where Exchange = 'NSEFO'
AND MAINOrderID = ''

INSERT INTO [2526 ALLOPT].[dbo].StoreData (
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
    Pancard, TerminalInfo, AlgoID, AlgoCategory, ParticipantID, Multiplier from [harsh_data].[dbo].[MergedTrade20250424-ALLOPT]

SELECT * from [harsh_data].[dbo].[MergedTrade20250424-ALLOPT]

Update [dbo].StoreData
Set ExpiryDate = '24APR2025'
where ExchangeTradeTime like '20250424%'
--and  Symbol = 'BSX'
AND MAINOrderID = ''

Update [dbo].StoreData
Set IsManual = 0
where ExchangeTradeTime like '20250424%'
--and  Symbol = 'PNB'
AND MAINOrderID = ''

Update [dbo].StoreData
SET Price = 0.8
where ExchangeTradeTime like '20250620%'
and  Symbol = 'PNB'
AND ReferenceText = '19J PNB 105 P4'
AND OptionType = 'CE'
AND MAINOrderID IS NULL


Update [dbo].StoreData
SET StrikePrice = 106.1
where ExchangeTradeTime like '20250620%'
and  Symbol = 'PNB'
and StrikePrice = '102.1'
AND ReferenceText = '2J PNB 109 P1'
AND OptionType = 'CE'
AND MAINOrderID IS NULL
