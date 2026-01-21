CREATE VIEW [cli].[ZZZ_CONOPS_CLI_EFH_NEW_V] AS







--SELECT * FROM [CLI].[CONOPS_CLI_EFH_NEW_V] where shiftflag = 'curr'
CREATE VIEW [cli].[CONOPS_CLI_EFH_NEW_V]
AS

WITH EFH_Target AS(
SELECT TOP 1
	EFH as EFHShifttarget
FROM [cli].[plan_values] (nolock)
ORDER BY shiftid DESC
)

SELECT
	a.siteflag,
	b.shiftflag,
	b.shiftindex,
	b.shiftid,
	b.ShiftStartDateTime,
	b.ShiftEndDateTime,
	CONCAT(FORMAT(a.UTC_CREATED_DATE, 'yyyy-MM-dd HH'), FORMAT(SHIFTSTARTDATETIME, ':mm:00')) AS BreakByHour,
	CASE WHEN a.shiftindex <> b.shiftindex
		THEN 0
		ELSE EFH
	END AS EFH,
	t.EFHShifttarget
FROM dbo.Equivalent_Flat_Haul a WITH (NOLOCK)
LEFT JOIN [CLI].[CONOPS_CLI_SHIFT_INFO_V] b
	ON a.siteflag = 'CLI'
CROSS JOIN EFH_Target t
WHERE FORMAT(a.UTC_CREATED_DATE, 'yyyy-MM-dd HH:mm:00') BETWEEN SHIFTSTARTDATETIME AND SHIFTENDDATETIME
AND CAST(FORMAT(a.UTC_CREATED_DATE, 'mm') AS INT) - CAST(FORMAT(SHIFTSTARTDATETIME, 'mm') AS INT) BETWEEN 0 AND 5