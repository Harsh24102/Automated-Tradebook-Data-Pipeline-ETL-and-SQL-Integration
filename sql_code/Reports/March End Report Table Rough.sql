use harsh_data;

select * from Temp_Club_890;

select * from TB_Opt;

select * from [dbo].[Common_Report_Table];
where ManagerID like 'EXPOPT%'
order by ManagerID;

select DISTINCT * from [dbo].[Common_Report_Table]
WHERE CompanyCode = 'EXPENSES'
AND UserID IS NULL;

select DISTINCT * from [dbo].[Common_Report_Table]
WHERE ManagerID LIKE 'EXPOPT%'
AND CompanyCode = 'DERIVATIVES'
AND UserID IS NULL;

select DISTINCT * from [dbo].[Common_Report_Table]
WHERE ManagerID LIKE 'ALLOPT%'
AND CompanyCode = 'DERIVATIVES'
AND UserID IS NULL;

select DISTINCT * from [dbo].[Common_Report_Table]
WHERE ManagerID LIKE 'NFTOPT%'
AND CompanyCode = 'DERIVATIVES'
AND UserID IS NULL;

select * from Temp_Club_890
WHERE CLIENT_ID LIKE 'EXPOPT%'
AND COMPANY_CODE = 'EXPENSES'
ORDER BY CLIENT_ID;

--CLUB FILE
---Split File 890
ALTER TABLE Temp_Club_890
ADD Symbol VARCHAR(50),
	ExpiryDate VARCHAR(15),
	Option_Type VARCHAR(6),
	Strike_Price FLOAT;  

-- Update the Symbol column
UPDATE Temp_Club_890
SET Symbol = SUBSTRING(SCRIP_SYMBOL, 1, PATINDEX('%[0-9]%', SCRIP_SYMBOL) - 1)
WHERE COMPANY_CODE = 'DERIVATIVES';

-- Update the EXPIRY_DATE column
UPDATE Temp_Club_890
SET ExpiryDate = SUBSTRING(SCRIP_SYMBOL, PATINDEX('%[0-9]%[a-zA-Z][a-zA-Z][a-zA-Z][0-9][0-9]%', SCRIP_SYMBOL), 7)
WHERE COMPANY_CODE = 'DERIVATIVES'
--WHERE PATINDEX('%[0-9][0-9][a-zA-Z][a-zA-Z][a-zA-Z][0-9][0-9]%', SCRIP_SYMBOL) > 0;

-- Update the Option_Type column
UPDATE Temp_Club_890
SET Option_Type = CASE 
                      WHEN PATINDEX('% CE %', SCRIP_SYMBOL) > 0 THEN 'CE'
                      WHEN PATINDEX('% PE %', SCRIP_SYMBOL) > 0 THEN 'PE'
                      ELSE 'XX'
                  END
WHERE COMPANY_CODE = 'DERIVATIVES';

-- Update the Strike_Price column
UPDATE Temp_Club_890
SET Strike_Price = CASE 
                       WHEN PATINDEX('%[0-9][0-9][0-9][0-9][0-9]%', SCRIP_SYMBOL) > 0 
                       THEN CAST(CAST(SUBSTRING(SCRIP_SYMBOL, PATINDEX('%[0-9][0-9][0-9][0-9][0-9]%', SCRIP_SYMBOL), 9) AS float) AS INT)
                       ELSE CAST(-0.01 AS FLOAT) 
                   END
WHERE COMPANY_CODE = 'DERIVATIVES';

--main file
--To add Calculation for NQ and NA in Main Table
update Common_Report_Table
set NetQuantity = BuyQuantity - SellQuantity,
	NetAmount = SellAmount - BuyAmount;

--Token
UPDATE Common_Report_Table
SET Token = CONCAT(
    ManagerID, ' ',
	StrategyID, ' ',
	Symbol, ' ',
	ExpiryDate, ' ',
    OptionType, ' ',
	StrikePrice);


--Update Null value with '-' in Data
UPDATE Common_Report_Table
SET Server = COALESCE(UserID, '-'),
    UserID = COALESCE(UserID, '-'),
    ClientID = COALESCE(ClientID, '-'),
    MemberID = COALESCE(CAST(MemberID AS VARCHAR), '-'),
    Token = COALESCE(Token, '-'),
    Exchange = COALESCE(Exchange, '-'),
    StrategyID = COALESCE(CAST(StrategyID AS VARCHAR), '-'),
    SecurityType = COALESCE(SecurityType, '-'),
    SecurityID = COALESCE(CAST(SecurityID AS VARCHAR), '-'),
    Symbol = COALESCE(Symbol, '-'),
    ExpiryDate = COALESCE(ExpiryDate, '1900-01-01'),
    OptionType = COALESCE(OptionType, '-'),
    StrikePrice = COALESCE(StrikePrice, 0),
    Side = COALESCE(Side, '-'),
    Quantity = COALESCE(Quantity, 0),
    Price = COALESCE(Price, 0)
WHERE CompanyCode = 'EXPENSES';

--Inserting Server Details
UPDATE rd
SET rd.Server = sd.ServerName
FROM Common_Report_Table rd
JOIN Server_Data sd ON rd.ManagerID = sd.ManagerID
WHERE rd.Server IS NULL 
AND sd.ServerName IS NOT NULL 
AND sd.ServerName <> '';

--Inserting Server Details ALLOPT & NFTOPT
UPDATE Common_Report_Table
SET Server = 
    CASE 
        WHEN ManagerID LIKE 'ALLOPT%' THEN 'Pair_All'
        ELSE Server  
    END
WHERE Server IS NULL 
AND (ManagerID LIKE 'ALLOPT%') ;

UPDATE Common_Report_Table
SET Server = 
    CASE 
        WHEN ManagerID LIKE 'NFTOPT%' THEN 'Pair_NFT'
        ELSE Server  
    END
WHERE Server IS NULL 
AND (ManagerID LIKE 'NFTOPT%');

SELECT DISTINCT ManagerID, Symbol, ExpiryDate, OptionType, StrikePrice
FROM Common_Report_Table
WHERE 
    UserID IS NULL OR 
    ClientID IS NULL OR 
    MemberID IS NULL OR 
    Token IS NULL OR 
    Exchange IS NULL OR 
    StrategyID IS NULL OR 
    SecurityType IS NULL OR 
    SecurityID IS NULL;



UPDATE ALLOPT_TB
SET Symbol = CASE 
    WHEN Symbol = 'BANKNIFTY' THEN 'BANKNIFT'
    WHEN Symbol = 'MIDCPNIFTY' THEN 'MIDCPNIF'
    WHEN Symbol = 'FINNIFTY' THEN 'FINNIFT'
    WHEN Symbol = 'BHARATFORG' THEN 'BHARATFO'
    WHEN Symbol = 'PERSISTENT' THEN 'PERSISTE'
    WHEN Symbol = 'HINDPETRO' THEN 'HINDPETR'
    WHEN Symbol = 'INDUSINDBK' THEN 'INDUSIND'
    WHEN Symbol = 'ICICIBANK' THEN 'ICICIBAN'
    WHEN Symbol = 'HINDUNILVR' THEN 'HINDUNIL'
    WHEN Symbol = 'KOTAKBANK' THEN 'KOTAKBAN'
    WHEN Symbol = 'GODREJPROP' THEN 'GODREJPR'
    WHEN Symbol = 'CUMMINSIND' THEN 'CUMMINSI'
    WHEN Symbol = 'AUROPHARMA' THEN 'AUROPHAR'
    WHEN Symbol = 'BHARTIARTL' THEN 'BHARTIAR'
    WHEN Symbol = 'FEDERALBNK' THEN 'FEDERALB'
    WHEN Symbol = 'BANKBARODA' THEN 'BANKBARO'
    WHEN Symbol = 'EICHERMOT' THEN 'EICHERMO'
    WHEN Symbol = 'ICICIGI' THEN 'ICICIGI'
    WHEN Symbol = 'SBICARD' THEN 'SBICARD'
    WHEN Symbol = 'RELIANCE' THEN 'RELIANCE'
    WHEN Symbol = 'HDFCLIFE' THEN 'HDFCLIFE'
    WHEN Symbol = 'HEROMOTOCORP' THEN 'HEROMOTO'
    WHEN Symbol = 'TATACONSUM' THEN 'TATACONS'
    WHEN Symbol = 'BAJAJ-AUTO' THEN 'BAJAJ-AU'
    WHEN Symbol = 'BAJAJFINSV' THEN 'BAJFINAN'
    WHEN Symbol = 'TRENT' THEN 'TRENT'
    WHEN Symbol = 'MOTHERSUMI' THEN 'MOTHERSO'
    WHEN Symbol = 'APOLLOHOSP' THEN 'APLAPOLL'
    WHEN Symbol = 'CONTAINER' THEN 'CONCOR'
    WHEN Symbol = 'VARUNBEV' THEN 'VBL'
    WHEN Symbol = 'IRFC' THEN 'IRFC'
    WHEN Symbol = 'ASTRAL' THEN 'ASTRAL'
    WHEN Symbol = 'UPL' THEN 'UPL'
    WHEN Symbol = 'VEDL' THEN 'VEDL'
    WHEN Symbol = 'INDHOTELS' THEN 'INDHOTEL'
    WHEN Symbol = 'JSWSTEEL' THEN 'JSWSTEEL'
    WHEN Symbol = 'SBIN' THEN 'SBIN'
    WHEN Symbol = 'TATASTEEL' THEN 'TATASTEE'
    WHEN Symbol = 'ULTRATECHCEM' THEN 'ULTRACEM'
    WHEN Symbol = 'CUMMINS' THEN 'CUMMINSI'
    WHEN Symbol = 'MCX' THEN 'MCX'
    WHEN Symbol = 'YESBANK' THEN 'YESBANK'
    WHEN Symbol = 'ZOMATO' THEN 'ZOMATO'
    WHEN Symbol = 'HINDCOPPER' THEN 'HINDCOPP'
    WHEN Symbol = 'M&M' THEN 'M&M'
    WHEN Symbol = 'LICHSGFIN' THEN 'LICHSGFI'
    WHEN Symbol = 'PFC' THEN 'PFC'
    WHEN Symbol = 'WIPRO' THEN 'WIPRO'
    WHEN Symbol = 'ADANIENT' THEN 'ADANIENT'
    WHEN Symbol = 'ASIANPAINT' THEN 'ASIANPAI'
    WHEN Symbol = 'BRITANNIA' THEN 'BRITANNI'
    WHEN Symbol = 'IDFCFIRSTB' THEN 'IDFCFIRS'
    WHEN Symbol = 'MPHASIS' THEN 'MPHASIS'
    WHEN Symbol = 'POWERGRID' THEN 'POWERGRI'
    WHEN Symbol = 'SBILIFE' THEN 'SBILIFE'
    WHEN Symbol = 'BANKEX' THEN 'BANKEX'
    WHEN Symbol = 'BHEL' THEN 'BHEL'
    WHEN Symbol = 'POLYCAB' THEN 'POLYCAB'
    WHEN Symbol = 'RECLTD' THEN 'RECLTD'
    WHEN Symbol = 'DELHIVERY' THEN 'DELHIVER'
    WHEN Symbol = 'JUBLFOOD' THEN 'JUBLFOOD'
    WHEN Symbol = 'MARUTI' THEN 'MARUTI'
    WHEN Symbol = 'ONGC' THEN 'ONGC'
    WHEN Symbol = 'TITAN' THEN 'TITAN'
    WHEN Symbol = 'IDFC' THEN 'IDFC'
    WHEN Symbol = 'MUTHOOTFIN' THEN 'MUTHOOTF'
    WHEN Symbol = 'BEL' THEN 'BEL'
    WHEN Symbol = 'ADANIGREEN' THEN 'ADANIGRE'
    WHEN Symbol = 'HCLTECH' THEN 'HCLTECH'
    WHEN Symbol = 'HDFCAMC' THEN 'HDFCAMC'
    WHEN Symbol = 'INFY' THEN 'INFY'
    WHEN Symbol = 'L&T' THEN 'LT'
    WHEN Symbol = 'LTIMINDTREE' THEN 'LTIM'
    WHEN Symbol = 'PAGEIND' THEN 'PAGEIND'
    WHEN Symbol = 'PIIND' THEN 'PIIND'
    WHEN Symbol = 'CHOLAFIN' THEN 'CHOLAFIN'
    WHEN Symbol = 'VOLTAS' THEN 'VOLTAS'
    WHEN Symbol = 'SRF' THEN 'SRF'
    WHEN Symbol = 'DIXON' THEN 'DIXON'
    WHEN Symbol = 'HINDALCO' THEN 'HINDALCO'
    WHEN Symbol = 'NESTLEIND' THEN 'NESTLEIN'
    WHEN Symbol = 'SUNPHARMA' THEN 'SUNPHARM'
    WHEN Symbol = 'NIFTY' THEN 'NIFTY'
    WHEN Symbol = 'ADANIPORTS' THEN 'ADANIPOR'
    WHEN Symbol = 'AXISBANK' THEN 'AXISBANK'
    WHEN Symbol = 'DIVISLAB' THEN 'DIVISLAB'
    WHEN Symbol = 'DRREDDY' THEN 'DRREDDY'
    WHEN Symbol = 'COFORGE' THEN 'COFORGE'
    WHEN Symbol = 'ANGELONE' THEN 'ANGELONE'
    WHEN Symbol = 'TVSMOTOR' THEN 'TVSMOTOR'
    WHEN Symbol = 'NTPC' THEN 'NTPC'
    WHEN Symbol = 'APOLLOHO' THEN 'APOLLOHO'
    WHEN Symbol = 'ASHOKLEY' THEN 'ASHOKLEY'
    WHEN Symbol = 'IDEA' THEN 'IDEA'
    WHEN Symbol = 'GRASIM' THEN 'GRASIM'
    WHEN Symbol = 'MRF' THEN 'MRF'
    WHEN Symbol = 'TATAMOTORS' THEN 'TATAMOTO'
    WHEN Symbol = 'TCS' THEN 'TCS'
    WHEN Symbol = 'AUBANK' THEN 'AUBANK'
    WHEN Symbol = 'COALINDIA' THEN 'COALINDI'
    WHEN Symbol = 'BANDHANBNK' THEN 'BANDHANB'
    WHEN Symbol = 'PRESTIGE' THEN 'PRESTIGE'
    WHEN Symbol = 'LAURUSLABS' THEN 'LAURUSLA'
END
WHERE Symbol IN (
    'BANKNIFTY', 'MIDCPNIFTY', 'FINNIFTY', 'BHARATFORG', 'PERSISTENT', 'HINDPETRO', 'INDUSINDBK', 'ICICIBANK',
    'HINDUNILVR', 'KOTAKBANK', 'GODREJPROP', 'CUMMINSIND', 'AUROPHARMA', 'BHARTIARTL', 'FEDERALBNK', 'BANKBARODA',
    'EICHERMOT', 'ICICIGI', 'SBICARD', 'RELIANCE', 'HDFCLIFE', 'HEROMOTOCORP', 'TATACONSUM', 'BAJAJ-AUTO',
    'BAJAJFINSV', 'TRENT', 'MOTHERSUMI', 'APOLLOHOSP', 'CONTAINER', 'VARUNBEV', 'IRFC', 'ASTRAL', 'UPL',
    'VEDL', 'INDHOTELS', 'JSWSTEEL', 'SBIN', 'TATASTEEL', 'ULTRATECHCEM', 'CUMMINS', 'MCX', 'YESBANK', 'ZOMATO',
    'HINDCOPPER', 'M&M', 'LICHSGFIN', 'PFC', 'WIPRO', 'ADANIENT', 'ASIANPAINT', 'BRITANNIA', 'IDFCFIRSTB'
);


UPDATE ALLOPT_TB
SET Symbol = CASE 
    WHEN Symbol = 'BANKNIFTY' THEN 'BANKNIFT'
    WHEN Symbol = 'MIDCPNIFTY' THEN 'MIDCPNIF'
    WHEN Symbol = 'FINNIFTY' THEN 'FINNIFT'
    WHEN Symbol = 'BHARATFORG' THEN 'BHARATFO'
    WHEN Symbol = 'PERSISTENT' THEN 'PERSISTE'
    WHEN Symbol = 'HINDPETRO' THEN 'HINDPETR'
    WHEN Symbol = 'INDUSINDBK' THEN 'INDUSIND'
    WHEN Symbol = 'ICICIBANK' THEN 'ICICIBAN'
    WHEN Symbol = 'HINDUNILVR' THEN 'HINDUNIL'
    WHEN Symbol = 'KOTAKBANK' THEN 'KOTAKBAN'
    WHEN Symbol = 'GODREJPROP' THEN 'GODREJPR'
    WHEN Symbol = 'CUMMINSIND' THEN 'CUMMINSI'
    WHEN Symbol = 'AUROPHARMA' THEN 'AUROPHAR'
    WHEN Symbol = 'BHARTIARTL' THEN 'BHARTIAR'
    WHEN Symbol = 'FEDERALBNK' THEN 'FEDERALB'
    WHEN Symbol = 'BANKBARODA' THEN 'BANKBARO'
    WHEN Symbol = 'BAJAJ-AUTO' THEN 'BAJAJ-AU'
    WHEN Symbol = 'BAJAJFINSV' THEN 'BAJFINAN'
    WHEN Symbol = 'HEROMOTOCORP' THEN 'HEROMOTO'
    WHEN Symbol = 'TATACONSUM' THEN 'TATACONS'
    WHEN Symbol = 'HDFCBANK' THEN 'HDFCBANK'
    WHEN Symbol = 'APOLLOHOSP' THEN 'APLAPOLL'
    WHEN Symbol = 'MOTHERSUMI' THEN 'MOTHERSO'
    WHEN Symbol = 'CONTAINER' THEN 'CONCOR'
    WHEN Symbol = 'IRFC' THEN 'IRFC'
    WHEN Symbol = 'VARUNBEV' THEN 'VBL'
    WHEN Symbol = 'AUBANK' THEN 'AUBANK'
    WHEN Symbol = 'COALINDIA' THEN 'COALINDI'
    WHEN Symbol = 'TATAMOTORS' THEN 'TATAMOTO'
    WHEN Symbol = 'TCS' THEN 'TCS'
    WHEN Symbol = 'GRASIM' THEN 'GRASIM'
    WHEN Symbol = 'MRF' THEN 'MRF'
    WHEN Symbol = 'BANDHANBNK' THEN 'BANDHANB'
    WHEN Symbol = 'LAURUSLABS' THEN 'LAURUSLA'
    WHEN Symbol = 'PRESTIGE' THEN 'PRESTIGE'
    WHEN Symbol = 'JSWSTEEL' THEN 'JSWSTEEL'
    WHEN Symbol = 'ULTRATECHCEM' THEN 'ULTRACEM'
    WHEN Symbol = 'ZOMATO' THEN 'ZOMATO'
    WHEN Symbol = 'CUMMINS' THEN 'CUMMINSI'
    WHEN Symbol = 'INDHOTELS' THEN 'INDHOTEL'
    WHEN Symbol = 'TATASTEEL' THEN 'TATASTEE'
    WHEN Symbol = 'SBIN' THEN 'SBIN'
    WHEN Symbol = 'YESBANK' THEN 'YESBANK'
    WHEN Symbol = 'MCX' THEN 'MCX'
    WHEN Symbol = 'HINDCOPPER' THEN 'HINDCOPP'
    WHEN Symbol = 'INDUSTOWER' THEN 'INDUSTOW'
    WHEN Symbol = 'AUROPHARMA' THEN 'AUROPHAR'
    WHEN Symbol = 'BPCL' THEN 'BPCL'
    WHEN Symbol = 'POLYCAB' THEN 'POLYCAB'
    WHEN Symbol = 'RECLTD' THEN 'RECLTD'
    WHEN Symbol = 'DELHIVERY' THEN 'DELHIVER'
    WHEN Symbol = 'RELIANCE' THEN 'RELIANCE'
    WHEN Symbol = 'CIPLA' THEN 'CIPLA'
    WHEN Symbol = 'HDFCLIFE' THEN 'HDFCLIFE'
    WHEN Symbol = 'ICICIGI' THEN 'ICICIGI'
    WHEN Symbol = 'SBICARD' THEN 'SBICARD'
    WHEN Symbol = 'ASTRAL' THEN 'ASTRAL'
    WHEN Symbol = 'UPL' THEN 'UPL'
    WHEN Symbol = 'VEDL' THEN 'VEDL'
    WHEN Symbol = 'M&M' THEN 'M&M'
    WHEN Symbol = 'ASIANPAINT' THEN 'ASIANPAI'
    WHEN Symbol = 'BRITANNIA' THEN 'BRITANNI'
    WHEN Symbol = 'WIPRO' THEN 'WIPRO'
    WHEN Symbol = 'ADANIENT' THEN 'ADANIENT'
    WHEN Symbol = 'LICHSGFIN' THEN 'LICHSGFI'
    WHEN Symbol = 'PFC' THEN 'PFC'
    WHEN Symbol = 'BHARTIARTL' THEN 'BHARTIAR'
    WHEN Symbol = 'IDFCFIRSTB' THEN 'IDFCFIRS'
    WHEN Symbol = 'POWERGRID' THEN 'POWERGRI'
    WHEN Symbol = 'SBILIFE' THEN 'SBILIFE'
    WHEN Symbol = 'PERSISTENT' THEN 'PERSISTE'
    WHEN Symbol = 'BHARATFORG' THEN 'BHARATFO'
    WHEN Symbol = 'BANKEX' THEN 'BANKEX'
    WHEN Symbol = 'MPHASIS' THEN 'MPHASIS'
    WHEN Symbol = 'BHEL' THEN 'BHEL'
    WHEN Symbol = 'HINDUNILVR' THEN 'HINDUNIL'
    WHEN Symbol = 'ICICIBANK' THEN 'ICICIBAN'
    WHEN Symbol = 'ITC' THEN 'ITC'
    WHEN Symbol = 'SENSEX' THEN 'SENSEX'
    WHEN Symbol = 'COLPAL' THEN 'COLPAL'
    WHEN Symbol = 'EICHERMOT' THEN 'EICHERMO'
    WHEN Symbol = 'SHRIRAMFIN' THEN 'SHRIRAMF'
    WHEN Symbol = 'LUPIN' THEN 'LUPIN'
    WHEN Symbol = 'CANBK' THEN 'CANBK'
    WHEN Symbol = 'PNB' THEN 'PNB'
    WHEN Symbol = 'TECHM' THEN 'TECHM'
    WHEN Symbol = 'MARUTI' THEN 'MARUTI'
    WHEN Symbol = 'ONGC' THEN 'ONGC'
    WHEN Symbol = 'TITAN' THEN 'TITAN'
    WHEN Symbol = 'BEL' THEN 'BEL'
    WHEN Symbol = 'MUTHOOTFIN' THEN 'MUTHOOTF'
    WHEN Symbol = 'IDFC' THEN 'IDFC'
    WHEN Symbol = 'JUBLFOOD' THEN 'JUBLFOOD'
    WHEN Symbol = 'ADANIGREEN' THEN 'ADANIGRE'
    WHEN Symbol = 'INFY' THEN 'INFY'
    WHEN Symbol = 'KOTAKBANK' THEN 'KOTAKBAN'
    WHEN Symbol = 'L&T' THEN 'LT'
    WHEN Symbol = 'BANKNIFTY' THEN 'BANKNIFT'
    WHEN Symbol = 'VOLTAS' THEN 'VOLTAS'
    WHEN Symbol = 'BAJAJFIN' THEN 'BAJAJFIN'
    WHEN Symbol = 'DIXON' THEN 'DIXON'
    WHEN Symbol = 'GODREJPROP' THEN 'GODREJPR'
    WHEN Symbol = 'HDFCAMC' THEN 'HDFCAMC'
    WHEN Symbol = 'HCLTECH' THEN 'HCLTECH'
    WHEN Symbol = 'PIIND' THEN 'PIIND'
    WHEN Symbol = 'SRF' THEN 'SRF'
    WHEN Symbol = 'ICICIPRULI' THEN 'ICICIPRU'
    WHEN Symbol = 'CHOLAFIN' THEN 'CHOLAFIN'
    WHEN Symbol = 'LTIMINDTREE' THEN 'LTIM'
    WHEN Symbol = 'PAGEIND' THEN 'PAGEIND'
    WHEN Symbol = 'NESTLEIND' THEN 'NESTLEIN'
    WHEN Symbol = 'SUNPHARMA' THEN 'SUNPHARM'
    WHEN Symbol = 'HINDALCO' THEN 'HINDALCO'
    WHEN Symbol = 'NIFTY' THEN 'NIFTY'
    WHEN Symbol = 'ADANIPORTS' THEN 'ADANIPOR'
    WHEN Symbol = 'COFORGE' THEN 'COFORGE'
    WHEN Symbol = 'AXISBANK' THEN 'AXISBANK'
END
WHERE Symbol IN (
    'BANKNIFTY', 'MIDCPNIFTY', 'FINNIFTY', 'BHARATFORG', 'PERSISTENT', 'HINDPETRO',
    'INDUSINDBK', 'ICICIBANK', 'HINDUNILVR', 'KOTAKBANK', 'GODREJPROP', 'CUMMINSIND',
    'AUROPHARMA', 'BHARTIARTL', 'FEDERALBNK', 'BANKBARODA', 'BAJAJ-AUTO', 'BAJAJFINSV',
    'HEROMOTOCORP', 'TATACONSUM', 'HDFCBANK', 'APOLLOHOSP', 'MOTHERSUMI', 'CONTAINER',
    'IRFC', 'VARUNBEV', 'AUBANK', 'COALINDIA', 'TATAMOTORS', 'TCS', 'GRASIM', 'MRF',
    'BANDHANBNK', 'LAURUSLABS', 'PRESTIGE', 'JSWSTEEL', 'ULTRATECHCEM', 'ZOMATO',
    'CUMMINS', 'INDHOTELS', 'TATASTEEL', 'SBIN', 'YESBANK', 'MCX', 'HINDCOPPER',
    'INDUSTOWER', 'BPCL', 'POLYCAB', 'RECLTD', 'DELHIVERY', 'RELIANCE', 'CIPLA',
    'HDFCLIFE', 'ICICIGI', 'SBICARD', 'ASTRAL', 'UPL', 'VEDL', 'M&M', 'ASIANPAINT',
    'BRITANNIA', 'WIPRO', 'ADANIENT', 'LICHSGFIN', 'PFC', 'IDFCFIRSTB', 'POWERGRID',
    'SBILIFE', 'BANKEX', 'MPHASIS', 'BHEL', 'ITC', 'SENSEX', 'COLPAL', 'EICHERMOT',
    'SHRIRAMFIN', 'LUPIN', 'CANBK', 'PNB', 'TECHM', 'MARUTI', 'ONGC', 'TITAN', 'BEL',
    'MUTHOOTFIN', 'IDFC', 'JUBLFOOD', 'ADANIGREEN', 'INFY', 'L&T', 'VOLTAS', 'BAJAJFIN',
    'DIXON', 'HDFCAMC', 'HCLTECH', 'PIIND', 'SRF', 'ICICIPRULI', 'CHOLAFIN',
    'LTIMINDTREE', 'PAGEIND', 'NESTLEIND', 'SUNPHARMA', 'HINDALCO', 'NIFTY',
    'ADANIPORTS', 'COFORGE', 'AXISBANK'
);

--To check how much data is null
SELECT COUNT(*) 
FROM Common_Report_Table 
WHERE UserID IS NULL OR ClientID IS NULL OR MemberID IS NULL;

--Updating Null values after symbol updated
UPDATE crt
SET 
    crt.UserID = COALESCE(crt.UserID, opt.UserID),
    crt.ClientID = COALESCE(crt.ClientID, opt.ClientID),
    crt.MemberID = COALESCE(crt.MemberID, opt.MemberID),
    crt.Token = COALESCE(crt.Token, opt.Token),
    crt.Exchange = COALESCE(crt.Exchange, opt.Exchange),
    crt.StrategyID = COALESCE(crt.StrategyID, opt.StrategyID),
    crt.SecurityType = COALESCE(crt.SecurityType, opt.SecurityType),
    crt.SecurityID = COALESCE(crt.SecurityID, opt.SecurityID)
FROM Common_Report_Table crt
LEFT JOIN EXPOPT_TB opt 
ON crt.Symbol = opt.Symbol 
AND crt.ExpiryDate = opt.ExpiryDate
AND crt.OptionType = opt.OptionType
AND crt.StrikePrice = opt.StrikePrice

LEFT JOIN ALLOPT_TB opt2 
ON crt.Symbol = opt2.Symbol 
AND crt.ExpiryDate = opt2.ExpiryDate
AND crt.OptionType = opt2.OptionType
AND crt.StrikePrice = opt2.StrikePrice

LEFT JOIN NFTOPT_TB opt3 
ON crt.Symbol = opt3.Symbol 
AND crt.ExpiryDate = opt3.ExpiryDate
AND crt.OptionType = opt3.OptionType
AND crt.StrikePrice = opt3.StrikePrice;


