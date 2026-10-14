use harsh_data;

--Table formation
create table NFTOPT_TB(
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
TRUNCATE TABLE NFTOPT_TB;

--Data Fetch
INSERT INTO NFTOPT_TB (Server, ManagerID, UserID, ClientID, MemberID, Exchange, StrategyID, 
                       SecurityType, SecurityID, Symbol, ExpiryDate, ReferenceText, OptionType, 
                       StrikePrice, Side, Quantity, Price, TradeDate)
SELECT Server, ManagerID, UserID, ClientID, MemberID, Exchange, StrategyID, SecurityType, 
       SecurityID, Symbol, ExpiryDate, ReferenceText, OptionType, StrikePrice, Side, 
       Quantity, Price, ExchangeTradeTime
FROM NFTOPT;


Select * from NFTOPT_TB;

--Tradedate
UPDATE NFTOPT_TB
SET TradeDate = LEFT(TradeDate, 4) + '-' + SUBSTRING(TradeDate, 5, 2) + '-' + SUBSTRING(TradeDate, 7, 2);