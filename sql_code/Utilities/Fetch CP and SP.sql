use harsh_data;

Select * from Bhav_Match
--where ExpiryDate = ExchangeTradeTime
order by ManagerID, Symbol, ExchangeTradeTime;

Select * from New_Tradebook_Apr
order by ManagerID, Symbol, ExchangeTradeTime;

--TO CHECK THE VALUES
Select * from Bhav_Match
where SettlementPrice IS NULL
AND ClosePrice IS NULL;

--Query will replace null value in SettlementPrice with previous date ClosePrice
UPDATE s1
SET 
    s1.ClosePrice = CASE 
                        WHEN s1.ClosePrice IS NULL THEN s2.ClsPric
                        ELSE s1.ClosePrice 
                    END,
    s1.SettlementPrice = CASE 
                            WHEN s1.SettlementPrice IS NULL THEN s2.SettlementP
                            ELSE s1.SettlementPrice 
                          END,
    s1.PrevClosePrice = CASE 
                            WHEN s1.PrevClosePrice IS NULL THEN s2.PrvsClsgPric
                            ELSE s1.PrevClosePrice 
                          END
FROM 
    Bhav_Match s1
JOIN 
    Bhavcopy_April s2 
    ON s1.Symbol = s2.TckrSymb  
    AND s1.ExpiryDate = s2.XpryDt
    AND s1.ExchangeTradeTime = '2024-04-02' 
    AND s2.TradDt = '2024-04-01'
WHERE 
    (s1.ClosePrice IS NULL)
    OR (s1.SettlementPrice IS NULL)
    OR (s1.PrevClosePrice IS NULL);

--Query to replace 0 in SettlementPrice
UPDATE s1
SET 
    s1.SettlementPrice = CASE 
                            WHEN s1.SettlementPrice =0 THEN s2.SettlementP
                            ELSE s1.SettlementPrice 
                          END
FROM 
    Bhav_Match s1
JOIN 
    Bhavcopy_April s2 
    ON s1.Symbol = s2.TckrSymb  
    AND s1.ExpiryDate = s2.XpryDt
    AND s1.ExchangeTradeTime = '2024-04-02' 
    AND s2.TradDt = '2024-04-01'
WHERE 
    s1.SettlementPrice = 0; 

--TO UPDATE IN FINAL FILE 
Alter table New_Tradebook_Apr
drop column [ClosePrice],
[SettlementPrice],
[Prev_Close_Price];

Alter Table New_Tradebook_Apr
add ClosePrice float,
SettlementPrice float,
Prev_Close_Price float;

Select * from New_Tradebook_Apr
where Prev_Close_Price IS NULL
AND ClosePrice IS NULL;

Select distinct ExchangeTradeTime from New_Tradebook_Apr
where Prev_Close_Price IS NULL
AND ClosePrice IS NULL;

--This will Update ClosePrice and SettlementPrice value
UPDATE n
SET 
    n.ClosePrice = CASE 
                        WHEN n.side IN ('buy', 'sell', 'Holding') THEN b.ClosePrice
                        ELSE 0  
                    END,
    n.SettlementPrice = CASE 
                            WHEN n.side = 'Holding' THEN b.SettlementPrice
                            ELSE 0  
                          END,
    n.Prev_Close_Price = CASE 
                            WHEN n.side IN ('buy', 'sell', 'Holding') THEN b.PrevClosePrice
                            ELSE 0 
                          END
FROM 
    New_Tradebook_Apr n
JOIN 
    Bhav_Match b
    ON n.symbol = b.symbol 
    AND n.ManagerID = b.ManagerID
    AND n.ExchangeTradeTime = b.ExchangeTradeTime;

