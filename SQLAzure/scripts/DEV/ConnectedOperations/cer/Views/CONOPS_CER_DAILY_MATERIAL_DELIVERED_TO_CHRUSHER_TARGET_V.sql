CREATE VIEW [cer].[CONOPS_CER_DAILY_MATERIAL_DELIVERED_TO_CHRUSHER_TARGET_V] AS
  
  
--select * from [cer].[CONOPS_CER_DAILY_MATERIAL_DELIVERED_TO_CHRUSHER_TARGET_V] WITH (NOLOCK)  
CREATE VIEW [cer].[CONOPS_CER_DAILY_MATERIAL_DELIVERED_TO_CHRUSHER_TARGET_V]  
AS  

 WITH crusherTarget AS (  
  SELECT Right([Year], 2) + FORMAT(CAST([Month] AS numeric), '00') [ShiftId],  
      --[siteflag],  
      CrusherLoc,  
      Tons/(DAY(EOMONTH(plandate)) * 2) as [Target]   
  FROM (  
   SELECT REVERSE(PARSENAME(REPLACE(REVERSE(CAST(TITLE AS DATE)), '-', '.'), 1)) AS [Year],  
       REVERSE(PARSENAME(REPLACE(REVERSE(CAST(TITLE AS DATE)), '-', '.'), 2)) AS [Month],  
       CAST(TITLE AS DATE) AS plandate,  
       --'CER' AS siteflag,  
       CrusherLoc,  
       Tons  
   FROM [cer].[PLAN_VALUES] (nolock) unpivot (Tons  
                FOR CrusherLoc in ([TOTALMILLCRUSH1], [TOTALMILLCRUSH2], [TOTALMILLCHAN], [TOTALHIDROCHAN])) unpiv  
  ) a  
 )  
  
 SELECT [shift].shiftflag,  
        [shift].[siteflag],  
     [shift].shiftid,  
     CASE [CrusherLoc] WHEN 'TOTALHIDROCHAN' THEN 'HIDROCHAN'  
        WHEN 'TOTALMILLCHAN' THEN 'MILLCHAN'  
        WHEN 'TOTALMILLCRUSH1' THEN 'MILLCRUSH1'  
        WHEN 'TOTALMILLCRUSH2' THEN 'MILLCRUSH2'  
     END AS [Location],  
     [Target]  
 FROM [cer].[CONOPS_CER_EOS_SHIFT_INFO_V] [shift] WITH (NOLOCK)  
 LEFT JOIN crusherTarget [C2]  
 ON [C2].[ShiftId] = LEFT([shift].[ShiftID], 4)   
   
  
  
