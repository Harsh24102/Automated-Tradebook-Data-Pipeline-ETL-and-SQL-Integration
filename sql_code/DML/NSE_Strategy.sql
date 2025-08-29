use harsh_data;

--TRADEBOOK OPTIONS

select * from Options_Strategy_wise;

select * from Options_Strategy_wise
where ManagerID = '';

update Options_Strategy_wise
set ManagerID = 'EXP'
where ManagerID = '';


Alter table Options_Strategy_wise
ADD 
    ExpiryDate VARCHAR(20),
    OptionType VARCHAR(6),
	StrikePrice float;

--ExpiryDate
UPDATE Options_Strategy_wise
SET [ExpiryDate] = 
    CASE 
        WHEN PATINDEX('%[0-9][0-9][0-9][0-9]%', Token) > 0
        THEN SUBSTRING(Token, PATINDEX('%[0-9][0-9][0-9][0-9]%', Token), 10)
        ELSE NULL
    END;

--OptionType
UPDATE Options_Strategy_wise
SET OptionType = 
    CASE 
        WHEN PATINDEX('% CE %', Token) > 0 THEN 'CE'
        WHEN PATINDEX('% PE %', Token) > 0 THEN 'PE'
        ELSE 'XX'
    END;

--StrikePrice
UPDATE Options_Strategy_wise
SET StrikePrice = 
    CASE 
        WHEN PATINDEX('%[0-9][0-9][0-9][0-9][0-9]%', Token) > 0 
        THEN CAST(SUBSTRING(Token, PATINDEX('%[0-9][0-9][0-9][0-9][0-9]%', Token), 5) AS float)
        ELSE NULL 
    END;

/*ALTER TABLE Options_Strategy_wise
DROP COLUMN Token;

Alter table Options_Strategy_wise
ADD Ref_Tn varchar(100);

UPDATE Options_Strategy_wise
SET Ref_Tn = CONCAT(
    [ExchangeTradeTime], ' ',
	[Symbol], ' ',
	[ExpiryDate], ' ',
    [StrikePrice], ' ',
	[OptionType]
);*/	

--BHAVCOPY

select * from [NSE_BSE_2024-25];

select * from [NSE_BSE_2024-25]
where FinInstrmTp = 'OPTIDX';

UPDATE [NSE_BSE_2024-25]
SET
    [TradDt] = CONVERT(VARCHAR, CAST([TradDt] AS DATE), 23),
    [XpryDt] = CONVERT(VARCHAR, CAST([XpryDt] AS DATE), 23);

ALTER TABLE [NSE_BSE_2024-25]
DROP COLUMN [Rmks],[Rsvd1],[Rsvd2],[Rsvd3],[Rsvd4],[Rsvd01],[Rsvd02],[Rsvd03],[Rsvd04]

/*--Token Formation
alter table [NSE_BSE_2024-25]
drop column Ref_Tn

Alter table [NSE_BSE_2024-25]
ADD Ref_Tn varchar(100);

UPDATE [NSE_BSE_2024-25]
SET Ref_Tn = CONCAT(
    [TradDt], ' ',
	[TckrSymb], ' ',
	[XpryDt], ' ',
    [StrkPric], ' ',
	[OptnTp]
);*/

--Exchange Update
Alter table [NSE_BSE_2024-25]
ADD Exchange varchar(10);

UPDATE [NSE_BSE_2024-25]
SET Exchange = CONCAT(Src, '', Sgmt);

--Security Type Update
Update [NSE_BSE_2024-25]
set FinInstrmTp = 'OPTIDX'
where FinInstrmTp = 'IDO';

--Symbol Update
Update [NSE_BSE_2024-25]
set TckrSymb = 'BKX'
where TckrSymb = 'BANKEX';

Update [NSE_BSE_2024-25]
set TckrSymb = 'BSX'
where TckrSymb = 'SENSEX';


--Expiry date update
Update [NSE_BSE_2024-25]
set XpryDt = '2025-01-30'
where XpryDt = '2025-01-31'
AND TckrSymb = 'NIFTYNEXT50';

Update [NSE_BSE_2024-25]
set XpryDt = '2025-01-30'
where XpryDt = '2025-01-27'
AND TckrSymb = 'MIDCPNIFTY';

Update [NSE_BSE_2024-25]
set XpryDt = '2025-01-30'
where XpryDt = '2025-01-28'
AND TckrSymb = 'FINNIFTY';

Update [NSE_BSE_2024-25]
set XpryDt = '2025-01-30'
where XpryDt = '2025-01-29'
AND TckrSymb = 'BANKNIFTY';

Update [NSE_BSE_2024-25]
set XpryDt = '2025-01-28'
where XpryDt = '2025-01-27'
AND TckrSymb = 'BKX';

Update [NSE_BSE_2024-25]
set XpryDt = '2025-02-27'
where XpryDt = '2025-02-26'
AND TckrSymb = 'BANKNIFTY';

--Strike Price .0 issue 
UPDATE [NSE_BSE_2024-25]
SET StrkPric = CAST(CAST(StrkPric AS FLOAT) AS INT)
WHERE StrkPric LIKE '%.0'; -- This ensures you only update values with .0



-- Fetching LastPrice, PrvsClsgPrice, UndrlygPrice, SttlmPrice from Bhavcopy (NSE_BSE_2024-25) to Options_Strategy_wise
SELECT 
    a.ManagerID,
    a.Symbol,
    a.Exchange,  -- Added Exchange
    a.SecurityType,  -- Added SecurityType
    a.ExchangeTradeTime,
    a.OptionType,
    a.StrikePrice,
    a.ExpiryDate,
    a.TotalBuyQuantity,  -- Added TotalBuyQuantity
    a.TotalSellQuantity,  -- Added TotalSellQuantity
    a.TotalBuyAmount,  -- Added TotalBuyAmount
    a.TotalSellAmount,  -- Added TotalSellAmount
    COALESCE(TRY_CAST(b.LastPric AS float), 0) AS LastPrice,
    COALESCE(TRY_CAST(b.UndrlygPric AS float), 0) AS UnderlyingPrice,
    COALESCE(TRY_CAST(b.SttlmPric AS float), 0) AS SettlementPrice
FROM Options_Strategy_wise a
LEFT JOIN [NSE_BSE_2024-25] b
    ON a.ExchangeTradeTime = b.TradDt
    AND a.Symbol = b.TckrSymb
    AND a.StrikePrice = b.StrkPric
    AND a.OptionType = b.OptnTp
    AND a.ExpiryDate = b.XpryDt;







select * from [NSE_BSE_2024-25]
where TckrSymb = 'BANKNIFTY'
AND TradDt = '2024-12-30'
AND XpryDt = '2025-02-26'
AND Exchange = 'NSEFO';

select * from [NSE_BSE_2024-25]
where TckrSymb = 'BANKEX'
AND TradDt = '2024-12-30'
AND XpryDt = '2025-01-28'
AND Exchange = 'BSEFO';


select * from Options_Strategy_wise
WHERE Symbol = 'BKX'
AND ExchangeTradeTime = '2024-12-30'
AND ExpiryDate = '2025-01-28';