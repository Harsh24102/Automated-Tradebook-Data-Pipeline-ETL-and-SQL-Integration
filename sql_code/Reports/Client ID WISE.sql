use harsh_data;

--OPTIONS 
SELECT 
	ClientID,
    Token,
	Exchange,
    SecurityType,
    MAX(ExchangeTradeTime) AS ExchangeTradeTime
FROM 
    TB_Opt
Where SecurityType LIKE 'OPTIDX'
GROUP BY 
    ClientID, Exchange, Token, SecurityType, ExchangeTradeTime  
ORDER BY 
    Token, ExchangeTradeTime;

--STOCKS
SELECT 
	ClientID,
    Token,
	Exchange,
    SecurityType,
    MAX(ExchangeTradeTime) AS ExchangeTradeTime
FROM 
    TB_Opt
Where SecurityType LIKE 'FUTSTK'
GROUP BY 
    ClientID, Exchange, Token, SecurityType, ExchangeTradeTime  
ORDER BY 
    Token, ExchangeTradeTime;

--Options + Stocks
SELECT 
    ClientID,
    Token,
    Exchange,
    SecurityType,
    MAX(ExchangeTradeTime) AS ExchangeTradeTime,
    CASE 
        WHEN SecurityType = 'OPTIDX' THEN 'OPTIONS'
        WHEN SecurityType = 'FUTSTK' THEN 'STOCKS'
    END AS Category
--INTO Client_Code
FROM TB_Opt
WHERE SecurityType IN ('OPTIDX', 'FUTSTK')
GROUP BY 
    ClientID, Exchange, Token, SecurityType, ExchangeTradeTime  
ORDER BY 
    Token, ExchangeTradeTime;


select * from Client_Code
where ClientID = 'U002';