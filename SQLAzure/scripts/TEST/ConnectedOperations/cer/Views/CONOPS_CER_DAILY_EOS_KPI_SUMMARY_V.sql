CREATE VIEW [cer].[CONOPS_CER_DAILY_EOS_KPI_SUMMARY_V] AS

  
  
  
    
    
-- SELECT * FROM [cer].[CONOPS_CER_DAILY_EOS_KPI_SUMMARY_V] WITH (NOLOCK) WHERE SHIFTFLAG = 'CURR'      
CREATE VIEW [cer].[CONOPS_CER_DAILY_EOS_KPI_SUMMARY_V]      
AS      
      
WITH HourlyTons AS (    
 SELECT CALCULATED_SHIFTINDEX AS ShiftIndex   
    ,Site_Code AS SiteFlag    
    ,HOS    
    ,SUM(DumpTons) AS HourTons    
 FROM [dbo].[LH_DUMP] [dld] WITH (NOLOCK)    
 WHERE Site_Code = 'CER'    
 GROUP BY CALCULATED_SHIFTINDEX, SITE_CODE, HOS    
),    
   
FLHourTons AS (    
 SELECT ShiftIndex    
    ,SiteFlag    
    ,SUM(CASE HOS WHEN 0 THEN HourTons ELSE 0 END) AS FirstHourTons    
    ,SUM(CASE HOS WHEN 11 THEN HourTons ELSE 0 END) AS LastHourTons    
 FROM HourlyTons WITH (NOLOCK)    
 GROUP BY ShiftIndex, SiteFlag    
),    
   
MHourTons AS (    
 SELECT ShiftIndex    
    ,SiteFlag    
    ,SUM(HourTons) / 10 AS MiddleHourTons    
 FROM HourlyTons [dld] WITH (NOLOCK)    
 WHERE HOS > 0 AND HOS < 11    
 GROUP BY ShiftIndex, SiteFlag    
),    
   
ShiftChangeEfficiencyNumerator AS (    
 SELECT ShiftIndex    
    ,SiteFlag    
    ,SUM(HourTons) / 2 AS NumeratorHourTons    
 FROM HourlyTons [dld] WITH (NOLOCK)    
 WHERE HOS IN (0,11)    
 GROUP BY ShiftIndex, SiteFlag    
),    
   
ShiftChangeEfficiencyDenominator AS (    
 SELECT ShiftIndex    
    ,SiteFlag    
    ,SUM(HourTons) / 10 AS DenominatorHourTons    
 FROM HourlyTons [dld] WITH (NOLOCK)    
 WHERE HOS > 0 AND HOS < 11    
 GROUP BY ShiftIndex, SiteFlag    
),    
   
ShiftChangeEfficiency AS (    
 SELECT nm.SiteFlag,    
     nm.SHIFTINDEX,    
     IIF(dm.DenominatorHourTons > 0, (nm.NumeratorHourTons / dm.DenominatorHourTons) * 100, 0) ShiftChangeEff    
 FROM ShiftChangeEfficiencyNumerator nm    
 LEFT JOIN ShiftChangeEfficiencyDenominator dm    
 ON nm.SHIFTINDEX = dm.SHIFTINDEX    
),    
   
GetShiftChangeAvgDuration AS (    
 SELECT ShiftIndex    
  ,CAST( COALESCE( AVG( Duration)/ 60, 0) AS DECIMAL(7,2)) AS [AvgDuration]    
 FROM [dbo].status_event WITH (NOLOCK)    
 WHERE Site_Code = 'CER'    
 AND Reason = 439    
 AND Unit = 1    
 GROUP BY ShiftIndex    
) ,  
  
HaulageEff AS (  
SELECT  
shiftflag,  
shiftid,
AVG(DeltaJ) AS DeltaJ  
FROM [cer].[CONOPS_CER_DAILY_DELTA_J_V]  
WHERE DeltaJ <> 0  
GROUP BY shiftflag,shiftid)  
   
SELECT a.ShifTFlag,    
    a.SiteFlag,  
	a.shiftid,
    ROUND(COALESCE(he.DeltaJ, 0), 1) AS HaulageEfficiency,  
    ROUND(COALESCE(she.ShiftChangeEff, 0), 1) AS ShiftChangeEfficiency,  
    CAST(COALESCE(fl.FirstHourTons, 0) AS INT) AS FirstHourTonsTotal,  
    CAST(COALESCE(m.MiddleHourTons, 0) AS INT) AS MiddleHourTonsTotal,  
    CAST(COALESCE(fl.LastHourTons, 0) AS INT) AS LastHourTonsTotal,  
    ROUND(COALESCE(ascd.AvgDuration, 0), 1)  AS AvgShiftChgDuration   
FROM [cer].[CONOPS_CER_EOS_SHIFT_INFO_V] a  
LEFT JOIN HaulageEff he   
 ON a.shiftflag = he.shiftflag  AND a.shiftid = he.shiftid  
LEFT JOIN ShiftChangeEfficiency she    
 ON a.ShiftIndex = she.SHIFTINDEX    
LEFT JOIN FLHourTons fl    
 ON a.ShiftIndex = fl.SHIFTINDEX    
LEFT JOIN MHourTons m    
 ON a.ShiftIndex = m.SHIFTINDEX    
LEFT JOIN GetShiftChangeAvgDuration ascd    
 ON a.ShiftIndex = ascd.shiftindex    
    
    
  
  
  

