use harsh_data;

SELECT 
    Symbol,OptionType,
	MAX(Token) AS Token,
    SUM(NetQuantity) AS NetQuantity,
    SUM(BuyAmount) AS TotalBuyAmount,
    SUM(SellAmount) AS TotalSellAmount,
    SUM(BuyQuantity) AS TotalBuyQuantity,
    SUM(SellQuantity) AS TotalSellQuantity,
    SUM(NetAmount) AS TotalNetAmount
FROM TradeBookApr
WHERE Symbol = 'BKX' 
  AND ManagerID = 'EXPOPT22'
GROUP BY Symbol, OptionType;

Alter table CheckRMS
ADD Token varchar(50);

UPDATE CheckRMS
SET Token = CONCAT(
    Symbol, ' ', 
    FORMAT(ExpiryDate, 'yyyyMMdd'), ' ', 
    OptionType, ' ', 
    FORMAT(StrikePrice, 'F2')  
);

ALTER TABLE checkRMS
--ADD Close_Price Float; 
drop column Close_price;
-- Verify current Close_Price values before the update
SELECT Symbol, ExpiryDate, OptionType, Close_Price
FROM checkRMS
WHERE OptionType IN ('CE', 'PE', 'XX');

-- Ensure accurate update for Close_Price
UPDATE c
SET c.Close_Price = TRY_CONVERT(FLOAT, b.ClsPric)
FROM checkRMS c
INNER JOIN Bhavcopy01042024 b
    ON c.Symbol = b.TckrSymb
    AND TRY_CONVERT(DATE, c.ExpiryDate) = TRY_CONVERT(DATE, b.XpryDt)
    AND c.OptionType = b.OptnTp
WHERE c.OptionType IN ('CE', 'PE', 'XX') -- Ensure 'XX' is included
  AND TRY_CONVERT(FLOAT, b.ClsPric) IS NOT NULL
  AND (c.Close_Price IS NULL OR c.Close_Price <> TRY_CONVERT(FLOAT, b.ClsPric))
  AND b.OptnTp IN ('CE', 'PE', 'XX'); -- Ensure to check only valid option types
	

Select * from CheckRMS;

-- Update blank or null OptnTp values to 'XX'
UPDATE Bhavcopy01042024
SET OptnTp = 'XX'
WHERE OptnTp IS NULL OR LTRIM(RTRIM(OptnTp)) = '';


