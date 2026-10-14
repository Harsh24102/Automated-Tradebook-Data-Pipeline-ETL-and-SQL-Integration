use harsh_data;

create table BackupTM227 (
ManagerID Varchar(20),
UserID varchar(20),
StrategyID int,
Symbol Varchar(50),
Exchange varchar(20),
SecurityType Varchar(20),
ExpiryDate Date,
ExchangeTradeTime varchar(20),
OptionType varchar(6),
Side char(10),
Quantity int,
Price Float,
StrikePrice Float,
BuyAmount Float,
SellAmount Float,
BuyQuantity int,
SellQuantity int,
NetQuantity int,
NetAmount Float,
BuyRate Float,
SellRate Float);

select * from BackupTM227;

INSERT INTO BackupTM227(ManagerID, UserID, StrategyID, Symbol, Exchange, SecurityType, OptionType, ExpiryDate, ExchangeTradeTime, Side, Quantity, Price, StrikePrice, BuyAmount, SellAmount, BuyQuantity, BuyRate, SellRate, SellQuantity, NetQuantity, NetAmount) 
SELECT ManagerID,[UserID],[StrategyID],Symbol,[Exchange],[SecurityType],OptionType,ExpiryDate,ExchangeTradeTime,Side,Quantity,Price,StrikePrice,BuyAmount,SellAmount,BuyQuantity,BuyRate,SellRate,SellQuantity,NetQuantity,NetAmount
FROM TM227;

select * from BackupTM227;

ALTER TABLE BackupTM227
ADD FormattedExpiryDate VARCHAR(20);

UPDATE BackupTM227
SET FormattedExpiryDate = FORMAT(ExpiryDate, 'd/M/yyyy');

UPDATE BackupTM227
SET FormattedExpiryDate = REPLACE(CONVERT(VARCHAR, CONVERT(DATE, FormattedExpiryDate, 103), 106), ' ', '')
WHERE FormattedExpiryDate IS NOT NULL;

UPDATE BackupTM227
SET FormattedExpiryDate = LEFT(FormattedExpiryDate, 2) + 
                          SUBSTRING(FormattedExpiryDate, 3, 3) + 
                          RIGHT(FormattedExpiryDate, 2)
WHERE FormattedExpiryDate IS NOT NULL;

UPDATE BackupTM227
SET FormattedExpiryDate = 
    CASE 
        WHEN FormattedExpiryDate LIKE '%Apr24' THEN 
            REPLACE(FormattedExpiryDate, 'Apr24', 'Apr2024')
        WHEN FormattedExpiryDate LIKE '%May24' THEN 
            REPLACE(FormattedExpiryDate, 'May24', 'May2024')
        ELSE FormattedExpiryDate
    END
WHERE FormattedExpiryDate LIKE '%Apr24' OR FormattedExpiryDate LIKE '%May24';


Alter table BackupTM227 
ADD Token varchar(200);


UPDATE BackupTM227
SET Token = CONCAT(
    ManagerID, ' ',
	OptionType, ' ',
	Symbol, ' ',
    FormattedExpiryDate, ' ',
	StrikePrice
);

UPDATE BackupTM227
SET Token = REPLACE(Token, 'May 2024', '30May2024')
WHERE Token LIKE '%May 2024%';

Delete FROM BackupTM227
WHERE ManagerID = 'MOCK';

select * from BackupTM227;

selecT DISTINCT ManagerID from Backup_April
ORDER BY ManagerID asc;


select * from BackupTM227;


