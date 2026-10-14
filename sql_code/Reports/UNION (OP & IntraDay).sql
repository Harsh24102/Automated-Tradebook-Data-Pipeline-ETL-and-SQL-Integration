use harsh_data;

--Drop TABLE EXP_ALLOVER_June_2_NET_;
--Select * from EXP_ALLOVER_June_2_NET_;
	
DECLARE @Table1 NVARCHAR(128) = '[Intraday_EXP_2]';  -- Name of the first table
DECLARE @Table2 NVARCHAR(128) = '[OP_EXP_2]';  -- Name of the second table
DECLARE @OutputTable NVARCHAR(128) = '[EXP_ALLOVER_June_2_NET_]';  -- Output table name

DECLARE @SQL NVARCHAR(MAX);

SET @SQL = N'
SELECT 
    ManagerID,
    Reference_Text,
    Exchange,
    StrategyID,
    SecurityType,
    Symbol,
    ExpiryDate,
    OptionType,
    StrikePrice,
    SUM(BuyQuantity) AS BuyQuantity,
    SUM(SellQuantity) AS SellQuantity,
    SUM(BuyAmount) AS BuyAmount,
    SUM(SellAmount) AS SellAmount,
    SUM(NetQuantity) AS NetQuantity,
    AVG(Settle_PRICE_) AS SettlePrice,
    AVG(Prev_Settle_PRICE_) AS PrevSettlePrice,
    AVG(CLOSE_PRICE_) AS ClosePrice,
    AVG(Prev_Close_PRICE_) AS PrevClosePrice,
    SUM(Final_BA) AS Final_BA,
    SUM(Final_SA) AS Final_SA,
    SUM(M2M) AS M2M,
	SUM(Total_Expense) AS Total_Expense,
    TradeDate
INTO ' + @OutputTable + '  -- This will create or replace the output table
FROM (
    SELECT 
        ManagerID, Reference_Text, Exchange, StrategyID, SecurityType, Symbol, ExpiryDate, OptionType, StrikePrice,
        BuyQuantity, SellQuantity, BuyAmount, SellAmount, NetQuantity, Settle_PRICE_, Prev_Settle_PRICE_,CLOSE_PRICE_, Prev_Close_PRICE_, Final_BA, Final_SA, M2M, Total_Expense, TradeDate
    FROM ' + @Table1 + '

    UNION ALL

    SELECT 
        ManagerID, Reference_Text, Exchange, StrategyID, SecurityType, Symbol, ExpiryDate, OptionType, StrikePrice,
        BuyQuantity, SellQuantity, BuyAmount, SellAmount, NetQuantity, Settle_PRICE_, Prev_Settle_PRICE_,CLOSE_PRICE_, Prev_Close_PRICE_, Final_BA, Final_SA, M2M, Total_Expense, TradeDate
    FROM ' + @Table2 + '
) AS CombinedData
GROUP BY 
    ManagerID,
    Reference_Text,
    Exchange,
    StrategyID,
    SecurityType,
    Symbol,
    ExpiryDate,
    OptionType,
    StrikePrice,
    TradeDate
ORDER BY 
    ManagerID,
    Symbol,
    ExpiryDate,
    OptionType,
    StrikePrice;
';

-- Execute the dynamic SQL
EXEC sp_executesql @SQL;
