use harsh_data;

--Options Expirywise
SELECT 
    ManagerID,
    Symbol,
    Exchange,
    SecurityType,
    Token,
    MAX(ExchangeTradeTime) AS ExchangeTradeTime,  
    SUM(BuyQuantity) AS TotalBuyQuantity,
    SUM(SellQuantity) AS TotalSellQuantity,
    SUM(BuyAmount) AS TotalBuyAmount,
    SUM(SellAmount) AS TotalSellAmount
--INTO Cumulative_Options
FROM 
    TB_Opt
Where SecurityType LIKE 'OPTIDX'
GROUP BY 
    ManagerID, Symbol, Exchange, Token, SecurityType
ORDER BY 
    ManagerID, Symbol, ExchangeTradeTime, Token;

--Options TradeDatewise
SELECT 
    ManagerID,
    Symbol,
    Exchange,
    SecurityType,
    Token,
    MAX(ExchangeTradeTime) AS ExchangeTradeTime,  
    SUM(BuyQuantity) AS TotalBuyQuantity,
    SUM(SellQuantity) AS TotalSellQuantity,
    SUM(BuyAmount) AS TotalBuyAmount,
    SUM(SellAmount) AS TotalSellAmount
--INTO Cumulative_Options_TradeDatewise
FROM 
    TB_Opt
WHERE 
    SecurityType LIKE 'OPTIDX'
GROUP BY 
    ManagerID, Symbol, Exchange, Token, SecurityType,ExchangeTradeTime  -- Group by TradeDate
ORDER BY 
    ManagerID, Symbol, ExchangeTradeTime, Token;  -- Sort by TradeDate

--Stocks Expirywise
SELECT 
    ManagerID,
    Symbol,
    Exchange,
    SecurityType,
    Token,
    MAX(ExchangeTradeTime) AS ExchangeTradeTime,  
    SUM(BuyQuantity) AS TotalBuyQuantity,
    SUM(SellQuantity) AS TotalSellQuantity,
    SUM(BuyAmount) AS TotalBuyAmount,
    SUM(SellAmount) AS TotalSellAmount
--INTO Cumulative_stocks
FROM 
    TB_Opt
Where SecurityType LIKE 'FUTSTK'
GROUP BY 
    ManagerID, Symbol, Exchange, Token, SecurityType
ORDER BY 
    ManagerID, Symbol, ExchangeTradeTime, Token;

--Stocks TradeDatewise
SELECT 
    ManagerID,
    Symbol,
    Exchange,
    SecurityType,
    Token,
    MAX(ExchangeTradeTime) AS ExchangeTradeTime,  
    SUM(BuyQuantity) AS TotalBuyQuantity,
    SUM(SellQuantity) AS TotalSellQuantity,
    SUM(BuyAmount) AS TotalBuyAmount,
    SUM(SellAmount) AS TotalSellAmount
--INTO Cumulative_TB_Opt
FROM 
    TB_Opt
WHERE 
    SecurityType LIKE 'FUTSTK'
GROUP BY 
    ManagerID, Symbol, Exchange, Token, SecurityType,ExchangeTradeTime  -- Group by TradeDate
ORDER BY 
    ManagerID, Symbol, ExchangeTradeTime, Token;  -- Sort by TradeDate

--Hit & Try codes
--Stocks TradeDatewise
SELECT 
    ManagerID,
    Symbol,
    Exchange,
    SecurityType,
    Token,
    MAX(ExchangeTradeTime) AS ExchangeTradeTime,  
    SUM(BuyQuantity) AS TotalBuyQuantity,
    SUM(SellQuantity) AS TotalSellQuantity,
    SUM(BuyAmount) AS TotalBuyAmount,
    SUM(SellAmount) AS TotalSellAmount
--INTO Cumulative_TB_Opt
FROM 
    TB_Opt
WHERE 
    SecurityType LIKE 'FUTSTK'
	AND ExchangeTradeTime BETWEEN '2024-04-01' AND '2024-04-31' 
GROUP BY 
    ManagerID, Symbol, Exchange, Token, SecurityType,ExchangeTradeTime  -- Group by TradeDate
ORDER BY 
    ManagerID, Symbol, ExchangeTradeTime, Token;  -- Sort by TradeDate

