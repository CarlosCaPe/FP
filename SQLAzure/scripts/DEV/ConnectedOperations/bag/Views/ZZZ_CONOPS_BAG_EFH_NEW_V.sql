CREATE VIEW [bag].[ZZZ_CONOPS_BAG_EFH_NEW_V] AS


--SELECT * FROM [BAG].[CONOPS_BAG_EFH_NEW_V] where shiftflag = 'curr'
CREATE VIEW [bag].[CONOPS_BAG_EFH_NEW_V]
AS

WITH EFH_Target AS(
SELECT TOP 1
	substring(replace(EffectiveDate,'-',''),3,4) as shiftdate,
	EFH as EFHShifttarget
FROM [bag].[plan_values_prod_sum] with (nolock)
ORDER BY EffectiveDate DESC
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
LEFT JOIN [bag].[CONOPS_BAG_SHIFT_INFO_V] b
	ON a.siteflag = 'BAG'
CROSS JOIN EFH_Target t
WHERE FORMAT(a.UTC_CREATED_DATE, 'yyyy-MM-dd HH:mm:00') BETWEEN SHIFTSTARTDATETIME AND SHIFTENDDATETIME
AND CAST(FORMAT(a.UTC_CREATED_DATE, 'mm') AS INT) - CAST(FORMAT(SHIFTSTARTDATETIME, 'mm') AS INT) BETWEEN 0 AND 5