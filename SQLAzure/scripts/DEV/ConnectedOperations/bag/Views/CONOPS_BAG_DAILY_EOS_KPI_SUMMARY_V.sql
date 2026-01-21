CREATE VIEW [bag].[CONOPS_BAG_DAILY_EOS_KPI_SUMMARY_V] AS


 
-- SELECT * FROM [bag].[CONOPS_BAG_DAILY_EOS_KPI_SUMMARY_V] WITH (NOLOCK) WHERE SHIFTFLAG = 'CURR'      
CREATE VIEW [bag].[CONOPS_BAG_DAILY_EOS_KPI_SUMMARY_V]      
AS      
      
WITH HourlyTons AS (  
SELECT
	SITE_CODE AS SITEFLAG,
	SHIFT_ID AS SHIFTID,
	DUMP_HOS -1 AS HOS,
	SUM(REPORT_PAYLOAD_SHORT_TONS) AS HourTons
FROM BAG.FLEET_TRUCK_CYCLE_V
GROUP BY SITE_CODE, SHIFT_ID, DUMP_HOS   
),  
 
FLHourTons AS (  
SELECT ShiftId  
	,SiteFlag  
	,SUM(CASE HOS WHEN 0 THEN HourTons ELSE 0 END) AS FirstHourTons  
	,SUM(CASE HOS WHEN 11 THEN HourTons ELSE 0 END) AS LastHourTons  
FROM HourlyTons WITH (NOLOCK) 
GROUP BY ShiftId, SiteFlag  
),  
 
MHourTons AS (  
SELECT ShiftId  
	,SiteFlag  
	,SUM(HourTons) / 10 AS MiddleHourTons  
FROM HourlyTons [dld] WITH (NOLOCK)  
WHERE HOS > 0 AND HOS < 11  
GROUP BY ShiftId, SiteFlag  
),  
 
ShiftChangeEfficiencyNumerator AS (  
SELECT ShiftId  
	,SiteFlag  
	,CAST(SUM(HourTons) / 2 AS FLOAT) AS NumeratorHourTons  
FROM HourlyTons [dld] WITH (NOLOCK)  
WHERE HOS IN (0,11)  
GROUP BY ShiftId, SiteFlag  
),  
 
ShiftChangeEfficiencyDenominator AS (  
SELECT ShiftId  
	,SiteFlag  
	,CAST(SUM(HourTons) / 10 AS FLOAT) AS DenominatorHourTons  
FROM HourlyTons [dld] WITH (NOLOCK)  
WHERE HOS > 0 AND HOS < 11  
GROUP BY ShiftId, SiteFlag  
),  
 
ShiftChangeEfficiency AS (  
SELECT nm.SiteFlag,  
	nm.ShiftId,  
	IIF(dm.DenominatorHourTons > 0, (nm.NumeratorHourTons / dm.DenominatorHourTons) * 100, 0) ShiftChangeEff  
FROM ShiftChangeEfficiencyNumerator nm  
LEFT JOIN ShiftChangeEfficiencyDenominator dm  
ON nm.ShiftId = dm.ShiftId  
),  
 
GetShiftChangeAvgDuration AS (  
SELECT
	e.ShiftId,
	CAST( COALESCE( AVG( Duration)/ 60, 0) AS DECIMAL(7,2)) AS [AvgDuration]
FROM [bag].FLEET_EQUIPMENT_HOURLY_STATUS e WITH (NOLOCK)  
WHERE e.UNIT = 1
	--AND e.Status = 4
	AND e.Reason = 439
GROUP BY e.ShiftId
),

HaulageEff AS (
SELECT
	shiftflag,
	AVG(DeltaJ) AS DeltaJ
FROM [bag].[CONOPS_BAG_DAILY_DELTA_J_V]
WHERE DeltaJ <> 0
GROUP BY shiftflag
)

  
SELECT 
	a.ShifTFlag,  
	a.SiteFlag,  
	ROUND(COALESCE(he.DeltaJ, 0), 1) AS HaulageEfficiency,  
    ROUND(COALESCE(she.ShiftChangeEff, 0), 1) AS ShiftChangeEfficiency,  
    CAST(COALESCE(fl.FirstHourTons, 0) AS INT) AS FirstHourTonsTotal,  
    CAST(COALESCE(m.MiddleHourTons, 0) AS INT) AS MiddleHourTonsTotal,  
    CAST(COALESCE(fl.LastHourTons, 0) AS INT) AS LastHourTonsTotal,  
    ROUND(COALESCE(ascd.AvgDuration, 0), 1)  AS AvgShiftChgDuration   
FROM [bag].[CONOPS_BAG_EOS_SHIFT_INFO_V] a
LEFT JOIN HaulageEff he
	ON a.shiftflag = he.shiftflag
LEFT JOIN ShiftChangeEfficiency she  
	ON a.ShiftId = she.ShiftId  
LEFT JOIN FLHourTons fl  
	ON a.ShiftId = fl.ShiftId  
LEFT JOIN MHourTons m  
	ON a.ShiftId = m.ShiftId  
LEFT JOIN GetShiftChangeAvgDuration ascd  
	ON a.ShiftId = ascd.ShiftId  





