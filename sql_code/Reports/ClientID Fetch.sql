use harsh_data;

Select * from Tradebook_2025_NFT
where TradeDate = '2025-05-20';
Select * from [BI Report].dbo.[CLUB__NFTOPT]
where TradeDate = '2025-05-20'

ALTER TABLE [BI Report].dbo.[CLUB__NFTOPT]
ADD ClientID VARCHAR(50) NULL;


Select * from [BI Report].dbo.[CLUB__NFTOPT]
where ClientID is not null

--To fetch ClientID Values 
UPDATE B
SET B.ClientID = A.ClientID
FROM [BI Report].dbo.[CLUB__NFTOPT] AS B
JOIN Tradebook_2025_NFT AS A
  ON A.ManagerID COLLATE SQL_Latin1_General_CP1_CI_AS = B.ManagerID
  AND A.Reference_Text COLLATE SQL_Latin1_General_CP1_CI_AS = B.Reference_Text
  AND A.Exchange COLLATE SQL_Latin1_General_CP1_CI_AS = B.Exchange
  AND A.StrategyID = B.StrategyID
  AND A.SecurityType COLLATE SQL_Latin1_General_CP1_CI_AS = B.SecurityType
  AND A.Symbol COLLATE SQL_Latin1_General_CP1_CI_AS = B.Symbol
  AND A.ExpiryDate = B.ExpiryDate
  AND A.OptionType COLLATE SQL_Latin1_General_CP1_CI_AS = B.OptionType
  AND A.StrikePrice = B.StrikePrice
  AND A.TradeDate = B.TradeDate;

--To fetch ClientID Null Values 
UPDATE B
SET B.ClientID = A.ClientID
FROM [CLUB__ALL__Intra] AS B
JOIN janvi.dbo.Tradebook_2025_ALL AS A
  ON A.ManagerID COLLATE SQL_Latin1_General_CP1_CI_AS = B.ManagerID
  AND A.Exchange COLLATE SQL_Latin1_General_CP1_CI_AS = B.Exchange
  AND A.SecurityType COLLATE SQL_Latin1_General_CP1_CI_AS = B.SecurityType
  AND A.Symbol COLLATE SQL_Latin1_General_CP1_CI_AS = B.Symbol
  AND A.ExpiryDate = B.ExpiryDate
  AND A.OptionType COLLATE SQL_Latin1_General_CP1_CI_AS = B.OptionType
  AND A.StrikePrice = B.StrikePrice
  AND A.TradeDate = B.TradeDate
  where B.ClientID is null;

ALTER TABLE [CLUB__ALL__Intra]
ADD CTCLID VARCHAR(50) NULL;

--To Fetch CTCLID values
UPDATE B
SET B.CTCLID = A.CTCLID
FROM [CLUB__ALL__Intra] AS B
JOIN janvi.dbo.Tradebook_2025_ALL AS A
  ON A.ManagerID COLLATE SQL_Latin1_General_CP1_CI_AS = B.ManagerID
  AND A.Reference_Text COLLATE SQL_Latin1_General_CP1_CI_AS = B.Reference_Text
  AND A.Exchange COLLATE SQL_Latin1_General_CP1_CI_AS = B.Exchange
  AND A.StrategyID = B.StrategyID
  AND A.SecurityType COLLATE SQL_Latin1_General_CP1_CI_AS = B.SecurityType
  AND A.Symbol COLLATE SQL_Latin1_General_CP1_CI_AS = B.Symbol
  AND A.ExpiryDate = B.ExpiryDate
  AND A.OptionType COLLATE SQL_Latin1_General_CP1_CI_AS = B.OptionType
  AND A.StrikePrice = B.StrikePrice
  AND A.TradeDate = B.TradeDate;

--To fetch CTCLID Null Values 
UPDATE B
SET B.CTCLID = A.CTCLID
FROM [CLUB__ALL__Intra] AS B
JOIN janvi.dbo.Tradebook_2025_ALL AS A
  ON A.ManagerID COLLATE SQL_Latin1_General_CP1_CI_AS = B.ManagerID
  AND A.Exchange COLLATE SQL_Latin1_General_CP1_CI_AS = B.Exchange
  AND A.SecurityType COLLATE SQL_Latin1_General_CP1_CI_AS = B.SecurityType
  AND A.Symbol COLLATE SQL_Latin1_General_CP1_CI_AS = B.Symbol
  AND A.ExpiryDate = B.ExpiryDate
  AND A.OptionType COLLATE SQL_Latin1_General_CP1_CI_AS = B.OptionType
  AND A.StrikePrice = B.StrikePrice
  AND A.TradeDate = B.TradeDate
  where B.CTCLID is null;



