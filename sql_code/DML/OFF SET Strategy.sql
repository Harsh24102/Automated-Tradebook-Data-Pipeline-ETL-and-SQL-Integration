USE harsh_data;

SELECT * FROM Tradebook_Apr
WHERE StrategyID = 0;

select * from Tradebook_Apr
where Token like '%EXPOPT07%'
AND FormattedExpiryDate LIKE '%Apr2024%';


--For each stocks optionwise
--NIFTY
UPDATE Tradebook_Apr 
SET 
    [UserID] = 'ADNSE',
    [StrategyID] = '71',  
    [Exchange] = 'NSEFO',       
    [SecurityType] = 'FUTSTK'  
WHERE 
    Token LIKE '%ADANIENT%' OR
    Token LIKE '%APOLLOHOSP%' OR
    Token LIKE '%BAJAJ-AUTO%' OR
    Token LIKE '%BPCL%' OR
    Token LIKE '%BRITANNIA%' OR
    Token LIKE '%CIPLA%' OR
    Token LIKE '%COALINDIA%' OR
    Token LIKE '%DIVISLAB%' OR
    Token LIKE '%DRREDDY%' OR
    Token LIKE '%EICHERMOT%' OR
    Token LIKE '%GRASIM%' OR
    Token LIKE '%HEROMOTOCO%' OR
    Token LIKE '%HINDALCO%' OR
    Token LIKE '%LTIM%' OR
    Token LIKE '%ONGC%' OR
    Token LIKE '%TATACONSUM%';

--BankNifty
UPDATE Tradebook_Apr 
SET 
    [UserID] = 'ADFIN',
    [StrategyID] = '44',  
    [Exchange] = 'NSEFO',       
    [SecurityType] = 'FUTSTK'  
WHERE 
	TOKEN LIKE '%BANDHANBNK%' OR
    Token LIKE '%PNB%';

--FINNIFTY
UPDATE Tradebook_Apr 
SET 
    [UserID] = 'ADFIN',
    [StrategyID] = '76',  
    [Exchange] = 'NSEFO',       
    [SecurityType] = 'FUTSTK'  
WHERE 
    Token LIKE '%CHOLAFIN%' OR
    Token LIKE '%ICICIGI%' OR
    Token LIKE '%ICICIPRULI%' OR
    Token LIKE '% IDFC %' OR
    Token LIKE '%LICHSGFIN%' OR
    Token LIKE '%MUTHOOTFIN%' OR
    Token LIKE '%PFC%' OR
    Token LIKE '%RECLTD%' OR
    Token LIKE '%SBICARD%';

--MIDCPNIFTY
UPDATE Tradebook_Apr
SET 
    [UserID] = 'ADMID',
    [StrategyID] = '282',  
    [Exchange] = 'NSEFO',       
    [SecurityType] = 'FUTSTK'  
WHERE 
    Token LIKE '%ASHOKLEY%' OR
    Token LIKE '%ASTRAL%' OR
    Token LIKE '%AUROPHARMA%' OR
    Token LIKE '%BHARATFORG%' OR
    Token LIKE '%COFORGE%' OR
    Token LIKE '%CONCOR%' OR
    Token LIKE '%CUMMINSIND%' OR
    Token LIKE '%GODREJPROP%' OR
    Token LIKE '%HINDPETRO%' OR
    Token LIKE '%IDEA%' OR
    Token LIKE '%INDHOTEL%' OR
    Token LIKE '%JUBLFOOD%' OR
    Token LIKE '%LUPIN%' OR
    Token LIKE '%MPHASIS%' OR
    Token LIKE '%MRF%' OR
    Token LIKE '%PAGEIND%' OR
    Token LIKE '%PERSISTENT%' OR
    Token LIKE '%PIIND%' OR
    Token LIKE '%POLYCAB%' OR
    Token LIKE '%UPL%' OR
    Token LIKE '%VOLTAS%';


--For Indexes(Options) only
UPDATE Tradebook_Apr
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
    ([UserID] = '0' OR [StrategyID] = 0 OR [Exchange] = '0' OR [SecurityType] = '0');



SELECT DISTINCT Symbol FROM Tradebook_Apr
WHERE StrategyID=0;

SELECT * FROM Tradebook_Apr
WHERE StrategyID = 0;
