use harsh_data;

drop table Tradebook_2025_EXP;

--Table formation
create table Tradebook_2025_EXP(
Server varchar(20),
ManagerID varchar(20),
UserID varchar(20),
ClientID Varchar(20),
MemberID INT,
SecurityID INT,
CTCLID INT,
Reference_Text Varchar(100),
Exchange varchar(20),
StrategyID INT,
SecurityType Varchar(20),
Symbol varchar(80),
ExpiryDate Date,
OptionType Varchar(6),
StrikePrice Float,
Side VARCHAR(10),
Quantity INT,
Price Float,
TradeDate varchar(30));

--Data Replace
TRUNCATE TABLE Tradebook_2025_EXP;

--Data Fetch
INSERT INTO Tradebook_2025_EXP(Server, ManagerID, UserID, ClientID, MemberID, Exchange, StrategyID, SecurityType, SecurityID, CTCLID, Symbol, ExpiryDate, Reference_Text, OptionType, StrikePrice, Side, Quantity, Price, TradeDate)
SELECT Server, ManagerID, UserID, ClientID, MemberID, Exchange, StrategyID, SecurityType, SecurityID, CTCLID,Symbol, TRY_CONVERT(DATE, ExpiryDate, 103), ReferenceText, OptionType, StrikePrice, Side, Quantity, Price, 
	TRY_CONVERT(VARCHAR(30), ExchangeTradeTime, 120) 
FROM EXP_DATA_2025;

Select * from Tradebook_2025_EXP;

--Update Tradedate & ExpiryDate Format
ALTER TABLE Tradebook_2025_EXP
ADD TradeTime VARCHAR(10);

--Shift time to new column
UPDATE Tradebook_2025_EXP
SET TradeTime = SUBSTRING(TradeDate, 10, 8);

--Convert date & time to only Date
UPDATE Tradebook_2025_EXP
SET TradeDate = LEFT(TradeDate, 8);

--Conversion of Tradedate to format (yyyy-mm-dd)
UPDATE Tradebook_2025_EXP
SET TradeDate = CONVERT(VARCHAR(10), LEFT(TradeDate, 8), 120);

UPDATE Tradebook_2025_EXP
SET TradeDate = FORMAT(CONVERT(DATE, TradeDate, 112), 'yyyy-MM-dd');

UPDATE Tradebook_2025_EXP
SET Symbol='SENSEX' 
WHERE Symbol= 'BSX';

UPDATE Tradebook_2025_EXP
SET Symbol='BANKEX' 
WHERE Symbol= 'BKX';