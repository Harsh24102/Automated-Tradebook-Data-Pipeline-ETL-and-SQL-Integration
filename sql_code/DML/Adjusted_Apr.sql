use harsh_data;

select * from Apr_Match;

select * from Apr_Match
where BuyQDifference != 0
and SellQDifference != 0;

Alter Table Apr_Match 
ADD --UserID Varchar(20),
--Exchange Varchar(20),
--StrategyID int,
--SecurityType Varchar(20);
--Side char(10);

UPDATE Apr_Match
SET Side = CASE
              WHEN [BuyQDifference] != 0 THEN 'Buy'
              WHEN [SellQDifference] != 0 THEN 'Sell'
              ELSE NULL  -- This can also be an empty string or another label
           END;

-- Insert Sell rows by selecting from existing Buy rows
INSERT INTO Apr_Match (Token, [TRADE_DATE1 ], BuyQuantity_227, BuyQuantity, SellQuantity_227, SellQuantity, BuyQDifference, SellQDifference, BuyAmount_227, BuyAmount, SellAmount_227, SellAmount, BuyADifference, SellADifference, BuyRate, SellRate, Side)
SELECT 
    Token,
    [TRADE_DATE1 ],
    BuyQuantity_227,
    0 AS BuyQuantity,
    SellQuantity_227,
    SellQuantity,
    0 AS BuyQDifference,
    SellQDifference,
    BuyAmount_227,
    BuyAmount,
    SellAmount_227,
    SellAmount,
    BuyADifference,
    SellADifference,
    BuyRate,
    SellRate,
    'Sell' AS Side
FROM 
    Apr_Match
WHERE 
    Side = 'Buy'
and [BuyQDifference] != 0
and [SellQDifference] != 0;


Select * From Apr_Match
Order By 
Token,
[TRADE_DATE1 ];


UPDATE Apr_Match
SET 
    [UserID] = 'ADMID',
    [StrategyID] = '282',  
    [Exchange] = 'NSEFO',       
    [SecurityType] = 'FUTSTK'  
WHERE 
    Token LIKE '%ASHOKLEY%';

UPDATE Apr_Match
SET 
    [UserID] = CASE 
        WHEN Token LIKE '%NIFTY%' THEN 'ADNSE'
        WHEN Token LIKE '%MIDCPNIFTY%' THEN 'ADMID'
        WHEN Token LIKE '%FINNIFTY%' THEN 'ADFIN'
        WHEN Token LIKE '%BANKNIFTY%' THEN 'ADFIN'
        WHEN Token LIKE '%BANKEX%' THEN 'ADBSE'
        WHEN Token LIKE '%SENSEX%' THEN 'ADBSE'
        ELSE [UserID] -- Keep original if no match
    END,
    [StrategyID] = CASE 
        WHEN Token LIKE '%NIFTY%' THEN '71'
        WHEN Token LIKE '%MIDCPNIFTY%' THEN '282'
        WHEN Token LIKE '%FINNIFTY%' THEN '76'
        WHEN Token LIKE '%BANKNIFTY%' THEN '44'
        WHEN Token LIKE '%BANKEX%' THEN '310'
        WHEN Token LIKE '%SENSEX%' THEN '286' -- Fixed typo
        ELSE [StrategyID] -- Keep original if no match
    END,
    [Exchange] = CASE 
        WHEN Token LIKE '%BANKEX%' OR Token LIKE '%SENSEX%' THEN 'BSEFO'
        ELSE 'NSEFO' -- Use NSEFO for other tokens
    END,
    [SecurityType] = 'OPTIDX'  
WHERE 
    ([UserID] IS NULL OR [StrategyID] IS NULL OR [Exchange] IS NULL OR [SecurityType] IS NULL);


Select * From Apr_Match
Order By 
Token,
[TRADE_DATE1 ];

SELECT * FROM Apr_Match
WHERE StrategyID IS NULL;

Select * from Apr_Match
where Token like '%EXPOPT07%'
ORDER BY Token;

