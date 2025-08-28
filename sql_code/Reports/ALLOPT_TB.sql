use harsh_data;

--Table formation
create table ALLOPT_TB(
Server varchar(20),
ManagerID varchar(20),
UserID varchar(20),
ClientID Varchar(20),
MemberID int,
Exchange varchar(20),
StrategyID int,
SecurityType Varchar(20),
SecurityID int,
Symbol varchar(80),
ExpiryDate Date,
ReferenceText varchar(80),
OptionType Varchar(6),
StrikePrice Float,
Side char(10),
Quantity int,
Price Float,
TradeDate varchar(30));

--Data Replace
TRUNCATE TABLE ALLOPT_TB;
--Data Fetch
INSERT INTO ALLOPT_TB (Server, ManagerID, UserID, ClientID, MemberID, Exchange, StrategyID, 
                       SecurityType, SecurityID, Symbol, ExpiryDate, ReferenceText, OptionType, 
                       StrikePrice, Side, Quantity, Price, TradeDate)
SELECT Server, ManagerID, UserID, ClientID, MemberID, Exchange, StrategyID, SecurityType, 
       SecurityID, Symbol, ExpiryDate, ReferenceText, OptionType, StrikePrice, Side, 
       Quantity, Price, ExchangeTradeTime
FROM ALLOPT
WHERE ManagerID like 'ALLOPT%';  


Select * from ALLOPT_TB;

--TradeDate
UPDATE ALLOPT_TB
SET TradeDate = LEFT(TradeDate, 4) + '-' + SUBSTRING(TradeDate, 5, 2) + '-' + SUBSTRING(TradeDate, 7, 2);

--Update Symbol with Common Report
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
END
WHERE Symbol IN (
    'BANKNIFTY', 'MIDCPNIFTY', 'FINNIFTY', 'BHARATFORG', 'PERSISTENT', 'HINDPETRO', 'INDUSINDBK', 'ICICIBANK',
    'HINDUNILVR', 'KOTAKBANK', 'GODREJPROP', 'CUMMINSIND', 'AUROPHARMA', 'BHARTIARTL', 'FEDERALBNK', 'BANKBARODA'
);

