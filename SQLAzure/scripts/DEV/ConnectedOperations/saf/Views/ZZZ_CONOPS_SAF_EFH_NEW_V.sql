CREATE VIEW [saf].[ZZZ_CONOPS_SAF_EFH_NEW_V] AS



--SELECT * FROM [SAF].[CONOPS_SAF_EFH_NEW_V] where shiftflag = 'curr'
CREATE VIEW [SAF].[CONOPS_SAF_EFH_NEW_V]
AS

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
	t.EFHtarget AS EFHShifttarget,
	CAST(FORMAT(a.UTC_CREATED_DATE, 'mm') AS INT) - CAST(FORMAT(SHIFTSTARTDATETIME, 'mm') AS INT) as b
FROM dbo.Equivalent_Flat_Haul a WITH (NOLOCK)
LEFT JOIN [SAF].[CONOPS_SAF_SHIFT_INFO_V] b
	ON a.siteflag = 'SAF'
LEFT JOIN [SAF].[CONOPS_SAF_DELTA_C_TARGET_V] t
	ON b.shiftid = t.shiftid
WHERE FORMAT(a.UTC_CREATED_DATE, 'yyyy-MM-dd HH:mm:00') BETWEEN SHIFTSTARTDATETIME AND SHIFTENDDATETIME
AND CAST(FORMAT(a.UTC_CREATED_DATE, 'mm') AS INT) - CAST(FORMAT(SHIFTSTARTDATETIME, 'mm') AS INT) BETWEEN 0 AND 5


