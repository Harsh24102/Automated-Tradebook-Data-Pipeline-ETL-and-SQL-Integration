use harsh_data;

Select * from Tradebook_Apr;

--for symbol names correction
Update Tradebook_Apr
Set Symbol = 'BANKEX'
Where Symbol = 'BKX';

Update	Tradebook_Apr
Set Symbol = 'SENSEX'
Where Symbol = 'BSX';


--changing Date Format
UPDATE Tradebook_Apr
SET ExchangeTradeTime = CAST(
	SUBSTRING(ExchangeTradeTime, 1, 4) + '-' +
	SUBSTRING(ExchangeTradeTime, 5, 2) + '-' +
	SUBSTRING(ExchangeTradeTime, 7, 2)
AS DATE);

ALTER TABLE Tradebook_Apr
ADD FormattedExpiryDate VARCHAR(20);

UPDATE Tradebook_Apr
SET FormattedExpiryDate = FORMAT(ExpiryDate, 'd/M/yyyy');

UPDATE Tradebook_Apr
SET FormattedExpiryDate = REPLACE(CONVERT(VARCHAR, CONVERT(DATE, FormattedExpiryDate, 103), 106), ' ', '')
WHERE FormattedExpiryDate IS NOT NULL;

UPDATE Tradebook_Apr
SET FormattedExpiryDate = LEFT(FormattedExpiryDate, 2) + 
                          SUBSTRING(FormattedExpiryDate, 3, 3) + 
                          RIGHT(FormattedExpiryDate, 2)
WHERE FormattedExpiryDate IS NOT NULL;

UPDATE Tradebook_Apr
SET FormattedExpiryDate = 
    CASE 
        WHEN FormattedExpiryDate LIKE '%Apr24' THEN 
            REPLACE(FormattedExpiryDate, 'Apr24', 'Apr2024')
        WHEN FormattedExpiryDate LIKE '%May24' THEN 
            REPLACE(FormattedExpiryDate, 'May24', 'May2024')
        ELSE FormattedExpiryDate
    END
WHERE FormattedExpiryDate LIKE '%Apr24' OR FormattedExpiryDate LIKE '%May24';


--For Token formattion
Alter table Tradebook_Apr
ADD Token varchar(50);


UPDATE Tradebook_Apr
SET Token = CONCAT(
    ManagerID, ' ',
	OptionType, ' ',
	Symbol, ' ',
    FormattedExpiryDate, ' ',
	StrikePrice
);

UPDATE Tradebook_Apr
SET Token = REPLACE(Token, 'May 2024', '30May2024')
WHERE Token LIKE '%May 2024%';


--Delete mock data
Delete FROM Tradebook_Apr
WHERE ManagerID = 'MOCK';
