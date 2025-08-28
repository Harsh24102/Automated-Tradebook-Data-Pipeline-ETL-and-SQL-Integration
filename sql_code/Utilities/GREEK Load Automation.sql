GO
CREATE PROCEDURE sp_Process_UploadData
AS
BEGIN
    SET NOCOUNT ON;

    -- Step 1: Clean load from staging to Upload
    INSERT INTO Upload (
        SourceFile, ExchangeTradeID, Symbol, Side, Quantity, Price, ManagerID, ExchangeOrderNo, 
        SecurityType, ExpiryDate, StrikePrice, OptionType, SecurityName, ClientID, MemberID,
        ExchangeOrderStatus, Code, Exchange, TradeDate
    )
    SELECT
        SourceFile,
        TRY_CAST(LTRIM(RTRIM(ExchangeTradeID)) AS BIGINT),
        LTRIM(RTRIM(Symbol)),
        LTRIM(RTRIM(Side)),
        TRY_CAST(REPLACE(LTRIM(RTRIM(Quantity)), ',', '') AS INT),
        TRY_CAST(REPLACE(LTRIM(RTRIM(Price)), ',', '') AS FLOAT),
        LTRIM(RTRIM(ManagerID)),
        LTRIM(RTRIM(ExchangeOrderNo)),
        NULL,
        LTRIM(RTRIM(ExpiryDate)),
        TRY_CAST(REPLACE(LTRIM(RTRIM(StrikePrice)), ',', '') AS FLOAT),
        LTRIM(RTRIM(OptionType)),
        ISNULL(NULLIF(LTRIM(RTRIM(SecurityName)), ''), '-') AS SecurityName,
        TRY_CAST(LTRIM(RTRIM(ClientID)) AS INT),
        TRY_CAST(LTRIM(RTRIM(MemberID)) AS INT),
        ISNULL(NULLIF(LTRIM(RTRIM(ExchangeOrderStatus)), ''), 'Nil'),
        ISNULL(NULLIF(LTRIM(RTRIM(Code)), ''), '-') AS Code,
        LTRIM(RTRIM(Exchange)),
        TRY_CAST(LTRIM(RTRIM(TradeDateTime)) AS DATETIME)
    FROM Upload_Staging;

    -- Step 2: Insert into final StoreData
    INSERT INTO StoreData (
        SourceFile, ExchangeTradeID, Symbol, Side, Quantity, Price, ManagerID, ExchangeOrderNo, 
        SecurityType, ExpiryDate, StrikePrice, OptionType, SecurityName, ClientID, MemberID,
        ExchangeOrderStatus, Code, Exchange, TradeDate, TradeTime
    )
    SELECT 
        SourceFile,
        ExchangeTradeID,
        Symbol,
        Side,
        Quantity,
        Price,
        ManagerID,
        ExchangeOrderNo,
        NULL,
        TRY_CAST(ExpiryDate AS DATE),
        StrikePrice,
        CASE 
            WHEN OptionType IN ('CE', 'PE') THEN OptionType
            ELSE 'XX'
        END,
        ISNULL(NULLIF(SecurityName, ''), '-') AS SecurityName,
        ISNULL(NULLIF(CAST(ClientID AS VARCHAR(20)), ''), '-') AS ClientID,
        ISNULL(NULLIF(CAST(MemberID AS VARCHAR(20)), ''), '-') AS MemberID,
        ISNULL(NULLIF(ExchangeOrderStatus, ''), 'Nil'),
        ISNULL(NULLIF(Code, ''), '-') AS Code,
        Exchange,
        CAST(TradeDate AS DATE),
        CAST(TradeDate AS TIME(0))
    FROM Upload;

    -- Step 3: Post-processing updates
    -- Update ExpiryDate from Code in yymdd format
    UPDATE StoreData
    SET ExpiryDate = TRY_CAST(
        '20' + LEFT(Code, 2) + '-' +       -- Year: '25' → '2025'
        SUBSTRING(Code, 3, 1) + '-' +      -- Month: '6'
        RIGHT(Code, 2)                     -- Day: '10'
        AS DATE
    )
    WHERE ExpiryDate IS NULL
      AND LEN(Code) = 5
      AND Code <> '-';

    -- Reset placeholder dates
    UPDATE StoreData
    SET ExpiryDate = NULL
    WHERE ExpiryDate = '1900-01-01';

    -- Determine SecurityType
    UPDATE StoreData
    SET SecurityType = 'OPTSTK'
    WHERE StrikePrice > 0 AND OptionType IN ('CE', 'PE');

    UPDATE StoreData
    SET SecurityType = 'FUTSTK'
    WHERE (StrikePrice = 0 OR StrikePrice IS NULL)
          AND (OptionType IN ('0', 'XX') OR OptionType IS NULL);

    -- Mark invalid strike price/option type for FUTSTK
    UPDATE StoreData
    SET StrikePrice = -0.01, OptionType = 'XX'
    WHERE SecurityType = 'FUTSTK';

    PRINT 'Data processing complete.';
END;
GO
