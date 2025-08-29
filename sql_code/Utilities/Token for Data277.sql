use harsh_data;

--Removing NSE_Cash column 
DELETE FROM Data_227
WHERE CompCon Like 'NSE_CASH%';

DELETE FROM Data_227
WHERE TRIM([SCRIP_NAME ]) = '';


--Creating Token
ALTER TABLE Data_227
ADD Token Varchar(50);

UPDATE Data_227
SET Token = CONCAT(
	CLIENT_ID,' ',
    SCRIP_SYMBOL
);

SELECT Token
FROM Data_227;

UPDATE Data_227
SET Token = REPLACE(Token, 'EF ', '')
WHERE Token LIKE '%EF%';
UPDATE Data_227
SET Token = REPLACE(Token, 'IO ', '')
WHERE Token LIKE '%IO%';

UPDATE Data_227
SET Token = 
    STUFF(Token, CHARINDEX(' ', Token) + 1, 0, 'XX ') + ' -0.01'
WHERE Token NOT LIKE '% PE %' 
  AND Token NOT LIKE '% CE %'
  AND Token LIKE 'EXPOPT%';

Select * from Data_227;

UPDATE Data_227
SET [TRADE_DATE1 ] = CONVERT(VARCHAR(10), CONVERT(DATE, [TRADE_DATE1 ], 103), 120)
WHERE TRY_CONVERT(DATE, [TRADE_DATE1 ], 103) IS NOT NULL;

SELECT * FROM Data_227
WHERE Token = 'EXPOPT53 CE SENSEX 05Apr2024 74500';