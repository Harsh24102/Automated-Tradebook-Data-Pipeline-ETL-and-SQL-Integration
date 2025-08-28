use harsh_data;

Select * from [BHAVCOPY2025_03_28]
WHERE TckrSymb = 'HDFCBANK';

ALTER TABLE [dbo].[BHAVCOPY2025_04_01]
ADD Exchange VARCHAR(20);

UPDATE [dbo].[BHAVCOPY2025_04_01]
SET Exchange = Src + Sgmt;

select * from [BHAVCOPY2025_03_28]
where TradDt = '2025-03-28'
and XpryDt like '2025-04%';



