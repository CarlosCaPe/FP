CREATE VIEW [MOR].[CONOPS_MOR_DAILY_DELTA_J_V] AS

--select * from [mor].[CONOPS_MOR_DAILY_DELTA_J_V] 
CREATE VIEW [mor].[CONOPS_MOR_DAILY_DELTA_J_V] 
AS

WITH Tons AS (
SELECT 
	siteflag,
	shiftid,
	shiftstartdatetime,
	shiftenddatetime,
	SUM(TotalMaterialMined) TotalMaterialMined,
	TimeInHour,
	Shiftseq,
	ShiftTarget
FROM MOR.CONOPS_MOR_HOURLY_TONS_SUMMARY_V
GROUP BY siteflag, shiftid, shiftstartdatetime, shiftenddatetime, TimeInHour, Shiftseq, ShiftTarget
),

HourlyTons AS (
SELECT
	siteflag,
	shiftid,
	shiftstartdatetime,
	shiftenddatetime,
	TotalMaterialMined,
	shiftTarget/12.0 AS TotalMaterialMinedTarget,
	TimeInHour,
	Shiftseq
FROM Tons
),

EFH AS (
SELECT 
	shiftflag,
	shiftid,
	BreakByHour AS TimeInHour,
	EFH,
	EFHShiftTarget AS EFHTarget
FROM [mor].[CONOPS_MOR_DAILY_EFH_V]
)

SELECT
	s.siteflag,
	s.shiftflag,
	s.shiftid,
	s.shiftstartdatetime,
	s.shiftenddatetime,
	TotalMaterialMined,
	TotalMaterialMinedTarget,
	ISNULL(ROUND(EFH,0),0) EFH,
	ISNULL(EFHTarget,0) EFHTarget,
	CASE WHEN TotalMaterialMinedTarget IS NULL OR TotalMaterialMinedTarget = 0 OR EFHTarget IS NULL OR EFHTarget = 0 THEN 0
		ELSE ISNULL(ROUND(((TotalMaterialMined*EFH) / (TotalMaterialMinedTarget*EFHTarget) * 100),0),0)
		END AS DeltaJ,
	a.TimeInHour
FROM MOR.CONOPS_MOR_EOS_SHIFT_INFO_V s
RIGHT JOIN HourlyTons a
	ON s.ShiftId = a.ShiftId
LEFT JOIN EFH b 
	ON s.shiftid = b.shiftid
	AND s.shiftflag = b.shiftflag
	AND a.TimeInHour = b.TimeInHour
WHERE s.shiftflag IS NOT NULL

