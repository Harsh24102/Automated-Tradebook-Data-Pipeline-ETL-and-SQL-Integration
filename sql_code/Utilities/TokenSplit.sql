use harsh_data;

select * from TM227;
select * from Apr_Match;


ALTER TABLE Apr_Match
ADD 
    ManagerID VARCHAR(20),
    OptionType VARCHAR(6),
    Symbol VARCHAR(50),
    FormattedExpiryDate VARCHAR(20),
    StrikePrice float;

-- Update the new column with Expiry_Date
SELECT 
    Token,
    SUBSTRING(Token, PATINDEX('%[0-9][0-9][a-zA-Z][a-zA-Z][a-zA-Z][0-9][0-9][0-9][0-9]%', Token), 9) AS FormattedExpiryDate
FROM 
    Apr_Match
WHERE 
    PATINDEX('%[0-9][0-9][a-zA-Z][a-zA-Z][a-zA-Z][0-9][0-9][0-9][0-9]%', Token) > 0;


UPDATE Apr_Match
SET FormattedExpiryDate = SUBSTRING(Token, PATINDEX('%[0-9][0-9][a-zA-Z][a-zA-Z][a-zA-Z][0-9][0-9][0-9][0-9]%', Token), 9)
WHERE PATINDEX('%[0-9][0-9][a-zA-Z][a-zA-Z][a-zA-Z][0-9][0-9][0-9][0-9]%', Token) > 0;

-- Update the new column with Strike_Price
SELECT 
    *,
    CASE 
        WHEN PATINDEX('%[0-9][0-9][0-9][0-9][0-9]%', Token) > 0 
        THEN CAST(SUBSTRING(Token, PATINDEX('%[0-9][0-9][0-9][0-9][0-9]%', Token), 9) AS float)
        ELSE CAST(-0.01 AS float) 
    END AS Strike_Price
FROM 
    Apr_Match;


UPDATE Apr_Match
SET StrikePrice = 
    CASE 
        WHEN PATINDEX('%[0-9][0-9][0-9][0-9][0-9]%', Token) > 0 
        THEN CAST(SUBSTRING(Token, PATINDEX('%[0-9][0-9][0-9][0-9][0-9]%', Token), 9) AS float)
        ELSE CAST(-0.01 AS float) 
    END;

-- Update the new column with OptionType
SELECT 
    *,
    CASE 
        WHEN PATINDEX('% CE %', Token) > 0 THEN 'CE'
        WHEN PATINDEX('% PE %', Token) > 0 THEN 'PE'
        ELSE 'XX'
    END AS OptionType
FROM 
    Apr_Match;


UPDATE Apr_Match
SET OptionType = 
    CASE 
        WHEN PATINDEX('% CE %', Token) > 0 THEN 'CE'
        WHEN PATINDEX('% PE %', Token) > 0 THEN 'PE'
        ELSE 'XX'
    END;

-- Update the new column with ManagerID
SELECT 
    *,
    CASE 
        WHEN Token LIKE '% %' THEN LEFT(Token, CHARINDEX(' ', Token) - 1)
        ELSE Token
    END AS ManagerID
FROM 
    Apr_Match;

UPDATE Apr_Match
SET ManagerID = 
    CASE 
        WHEN Token LIKE '% %' THEN LEFT(Token, CHARINDEX(' ', Token) - 1)
        ELSE Token
    END;

-- Update the new column with Symbol
SELECT 
    *,
    CASE 
        WHEN Token LIKE '% % %' THEN 
            LTRIM(RTRIM(SUBSTRING(Token, 
                      CHARINDEX(' ', Token, CHARINDEX(' ', Token) + 1) + 1, 
                      CHARINDEX(' ', Token, CHARINDEX(' ', Token, CHARINDEX(' ', Token) + 1) + 1) - 
                      CHARINDEX(' ', Token, CHARINDEX(' ', Token) + 1) - 1)))
        ELSE ''
    END AS Symbol
FROM 
    Apr_Match;

UPDATE Apr_Match
SET Symbol = 
    CASE 
        WHEN Token LIKE '% % %' THEN 
            LTRIM(RTRIM(SUBSTRING(Token, 
                      CHARINDEX(' ', Token, CHARINDEX(' ', Token) + 1) + 1, 
                      CHARINDEX(' ', Token, CHARINDEX(' ', Token, CHARINDEX(' ', Token) + 1) + 1) - 
                      CHARINDEX(' ', Token, CHARINDEX(' ', Token) + 1) - 1)))
        ELSE ''
    END;

