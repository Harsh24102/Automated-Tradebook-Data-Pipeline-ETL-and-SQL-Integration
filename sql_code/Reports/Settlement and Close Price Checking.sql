use harsh_data;

SELECT                 --Settlement Price
    a.ManagerID,
    a.Symbol,
    a.OptionType, 
    a.StrikePrice,
    a.ExpiryDate,  
    a.BuyQuantity, 
    a.BuyRate,
    a.BuyAmount,     
    a.SellQuantity, 
    a.SellRate,
    a.SellAmount,     
    a.NetQuantity,
    a.NetAmount,
    ISNULL(TRY_CAST(b.SttlmPric AS float),0) AS SettlementP
FROM CheckRMS a
LEFT JOIN Bhavcopy b
    ON a.Symbol = b.TckrSymb
    AND TRY_CAST(a.StrikePrice AS float) = COALESCE(TRY_CAST(b.StrkPric AS Float), -0.01)
    AND a.ExpiryDate = TRY_CAST(b.XpryDt AS DATE)
    AND a.OptionType = COALESCE(NULLIF(b.OptnTp, ''), 'XX');


SELECT                 --Close Price
    a.ManagerID,
    a.Symbol,
    a.OptionType, 
    a.StrikePrice,
    a.ExpiryDate,  
    a.BuyQuantity,
    a.BuyRate,
    a.BuyAmount,
    a.SellQuantity,
    a.SellRate,
    a.SellAmount,
    a.NetQuantity,
    a.NetAmount,
    TRY_CAST(b.ClsPric AS float) AS ClosePrice
FROM CheckRMS a
LEFT JOIN Bhavcopy b
    ON a.Symbol = b.TckrSymb
    AND TRY_CAST(a.StrikePrice AS float) = COALESCE(TRY_CAST(b.StrkPric AS Float), -0.01)
    AND a.ExpiryDate = TRY_CAST(b.XpryDt AS DATE)
    AND a.OptionType = COALESCE(NULLIF(b.OptnTp, ''), 'XX');