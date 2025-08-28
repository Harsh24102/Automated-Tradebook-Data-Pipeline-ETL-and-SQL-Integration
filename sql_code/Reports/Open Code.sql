use harsh_data;

--Select * into [Intraday_ALL_April_15] from [Janvi].[dbo].[EXP_IntraDay_April_15_RS]
--Select * into [OP_ALL_May_15] from [Janvi].dbo.[ALL_Open_Position_May_15_RS]

select * from [dbo].[Intraday_EXP_30];
select * from [dbo].[OP_EXP_30];

Alter Table [Intraday_EXP_30]
Drop column /*[Position],[Net_Setttlement_BA],[Net_Setttlement_SA],*/[TO_Charges_Buy],[GST_On_TO_Buy],[SD_Buy],[STT_CTT_Buy],[SEBI_Buy],[GST_On_SEBI_Buy],[CL_Charges_Buy],[GST_On_CL_Buy],[TO_Charges_Sell],[GST_On_TO_Sell],[SD_Sell],[STT_CTT_Sell],[SEBI_Sell],
[GST_On_SEBI_Sell],[CL_Charges_Sell],[GST_On_CL_Sell],[Total_Expense];

Alter Table [OP_EXP_30]
Drop column /*[Position],[Net_Setttlement_BA],[Net_Setttlement_SA],[TO_Charges_Buy],[GST_On_TO_Buy],[SD_Buy],[STT_CTT_Buy],[SEBI_Buy],[GST_On_SEBI_Buy],[CL_Charges_Buy],[GST_On_CL_Buy],[TO_Charges_Sell],[GST_On_TO_Sell],[SD_Sell],[STT_CTT_Sell],[SEBI_Sell],
[GST_On_SEBI_Sell],[CL_Charges_Sell],[GST_On_CL_Sell],*/[Total_Expense];

--To Update Date Format
ALTER TABLE [Intraday_EXP_30]
ALTER COLUMN ExpiryDate DATE;

ALTER TABLE [Intraday_EXP_30]
ALTER COLUMN TradeDate DATE;

UPDATE [Intraday_EXP_30]
SET TradeDate = CAST(TradeDate AS DATE);

UPDATE [Intraday_EXP_30]
SET ExpiryDate = CAST(ExpiryDate AS DATE);

--To add Trade Status
--Intraday
ALTER TABLE [Intraday_EXP_30]
ADD Position VARCHAR(20);

UPDATE [Intraday_EXP_30]
SET Position = 
    CASE 
        WHEN TradeDate = ExpiryDate AND NetQuantity != 0 THEN 'Settle'
        ELSE 'Intra'
    END;

--OP
ALTER TABLE [OP_EXP_30]
ADD Position VARCHAR(20);

UPDATE [OP_EXP_30]
SET Position = 
    CASE 
        WHEN TradeDate = ExpiryDate AND NetQuantity != 0 THEN 'Settle'
        ELSE 'Open'
    END;

alter table [OP_EXP_08]
ADD Prev_CLOSE_PRICE_ float

/*--Intraday & OP changes 
--Alter table [Intraday_EXP_8]
Alter table [Intraday_EXP_8]
add Net_Setttlement_BA Float,
Net_Setttlement_SA Float;

UPDATE [OP_EXP_8]
SET 
    Net_Setttlement_BA = CASE 
                      WHEN Position = 'Settle' AND NetQuantity < 0 THEN ABS(NetQuantity * Settle_PRICE_)
                      ELSE 0 
                  END,
    Net_Setttlement_SA = CASE 
                      WHEN Position = 'Settle' AND NetQuantity > 0 THEN ABS(NetQuantity * Settle_PRICE_)
                      ELSE 0 
                  END;

UPDATE [Intraday_EXP_8]
SET 
    Net_Setttlement_BA = CASE 
                      WHEN Position = 'Settle' AND NetQuantity < 0 THEN ABS(NetQuantity * Settle_PRICE_)
                      ELSE 0 
                  END,
    Net_Setttlement_SA = CASE 
                      WHEN Position = 'Settle' AND NetQuantity > 0 THEN ABS(NetQuantity * Settle_PRICE_)
                      ELSE 0 
                  END;*/

ALter table [OP_EXP_30]
add TO_Charges_Buy float, 
	GST_On_TO_Buy float, 
	TO_Charges_Sell float, 
	GST_On_TO_Sell float,
	SD_Buy float, 
	SD_Sell float,
	STT_CTT_Buy float, 
    STT_CTT_Sell float,
	SEBI_Buy float, 
	GST_On_SEBI_Buy float, 
	SEBI_Sell float, 
	GST_On_SEBI_Sell float,
	CL_Charges_Buy float, 
	GST_On_CL_Buy float,
	CL_Charges_Sell float, 
	GST_On_CL_Sell float;

UPDATE [OP_EXP_30]
SET  TO_Charges_Buy = 0,
    GST_On_TO_Buy = 0,
    SD_Buy = 0,
    STT_CTT_Buy = 0,
    TO_Charges_Sell = 0,
    GST_On_TO_Sell = 0,
    SD_Sell = 0,
    STT_CTT_Sell = 0,
	SEBI_Buy = 0, 
	GST_On_SEBI_Buy = 0, 
	SEBI_Sell = 0, 
	GST_On_SEBI_Sell = 0,
	CL_Charges_Buy = 0, 
	GST_On_CL_Buy = 0,
	CL_Charges_Sell = 0, 
	GST_On_CL_Sell = 0;
--where Position = 'Settle'

--To add Total Expense
ALter table [OP_EXP_30]
add Total_Expense Float;

UPDATE [OP_EXP_30]
    SET Total_Expense = 
        ISNULL(TO_Charges_Buy, 0) +
        ISNULL(GST_On_TO_Buy, 0) +
        ISNULL(SD_Buy, 0) +
        ISNULL(STT_CTT_Buy, 0) +
        ISNULL(SEBI_Buy, 0) +
        ISNULL(GST_On_SEBI_Buy, 0) +
        ISNULL(CL_Charges_Buy, 0) +
        ISNULL(GST_On_CL_Buy, 0) +
        ISNULL(TO_Charges_Sell, 0) +
        ISNULL(GST_On_TO_Sell, 0) +
        ISNULL(SD_Sell, 0) +
        ISNULL(STT_CTT_Sell, 0) +
        ISNULL(SEBI_Sell, 0) +
        ISNULL(GST_On_SEBI_Sell, 0) +
        ISNULL(CL_Charges_Sell, 0) +
        ISNULL(GST_On_CL_Sell, 0);

--To calculate Expense with New Approach
/*UPDATE [OP_EXP_8]
SET
    -- SEBI_Buy
    SEBI_Buy = CASE
        WHEN Position = 'Settle' AND Exchange IN ('BSEFO', 'NSEFO') AND SecurityType = 'OPTIDX' THEN Net_Setttlement_BA * 0.000001500
        ELSE 0 END,

    -- GST_On_SEBI_Buy
    GST_On_SEBI_Buy = CASE
        WHEN Position = 'Settle' AND Exchange IN ('BSEFO', 'NSEFO') AND SecurityType = 'OPTIDX' THEN Net_Setttlement_BA * 0.00000027000
        ELSE 0 END,

    -- CL_Charges_Buy
    CL_Charges_Buy = CASE
        WHEN Position = 'Settle' AND Exchange IN ('BSEFO', 'NSEFO') AND SecurityType = 'OPTIDX' THEN Net_Setttlement_BA * 0.000100000
        ELSE 0 END,

    -- GST_On_CL_Buy
    GST_On_CL_Buy = CASE
        WHEN Position = 'Settle' AND Exchange IN ('BSEFO', 'NSEFO') AND SecurityType = 'OPTIDX' THEN Net_Setttlement_BA * 0.000018
        ELSE 0 END,

    -- SEBI_Sell
    SEBI_Sell = CASE
        WHEN Position = 'Settle' AND Exchange IN ('BSEFO', 'NSEFO') AND SecurityType = 'OPTIDX' THEN Net_Setttlement_SA * 0.000001500
        ELSE 0 END,

    -- GST_On_SEBI_Sell
    GST_On_SEBI_Sell = CASE
        WHEN Position = 'Settle' AND Exchange IN ('BSEFO', 'NSEFO') AND SecurityType = 'OPTIDX' THEN Net_Setttlement_SA * 0.00000027000
        ELSE 0 END,

    -- CL_Charges_Sell
    CL_Charges_Sell = CASE
        WHEN Position = 'Settle' AND Exchange IN ('BSEFO', 'NSEFO') AND SecurityType = 'OPTIDX' THEN Net_Setttlement_SA * 0.000100000
        ELSE 0 END,

    -- GST_On_CL_Sell
    GST_On_CL_Sell = CASE
        WHEN Position = 'Settle' AND Exchange IN ('BSEFO', 'NSEFO') AND SecurityType = 'OPTIDX' THEN Net_Setttlement_SA * 0.000018
        ELSE 0 END,

    -- Set ALL other charges to 0 if Position = 'Settle' or 'Open'
    TO_Charges_Buy = CASE WHEN Position IN ('Settle', 'Open') THEN 0 ELSE TO_Charges_Buy END,
    GST_On_TO_Buy = CASE WHEN Position IN ('Settle', 'Open') THEN 0 ELSE GST_On_TO_Buy END,
    SD_Buy = CASE WHEN Position IN ('Settle', 'Open') THEN 0 ELSE SD_Buy END,
    STT_CTT_Buy = CASE WHEN Position IN ('Settle', 'Open') THEN 0 ELSE STT_CTT_Buy END,
    TO_Charges_Sell = CASE WHEN Position IN ('Settle', 'Open') THEN 0 ELSE TO_Charges_Sell END,
    GST_On_TO_Sell = CASE WHEN Position IN ('Settle', 'Open') THEN 0 ELSE GST_On_TO_Sell END,
    SD_Sell = CASE WHEN Position IN ('Settle', 'Open') THEN 0 ELSE SD_Sell END,
    STT_CTT_Sell = CASE WHEN Position IN ('Settle', 'Open') THEN 0 ELSE STT_CTT_Sell END;*/



