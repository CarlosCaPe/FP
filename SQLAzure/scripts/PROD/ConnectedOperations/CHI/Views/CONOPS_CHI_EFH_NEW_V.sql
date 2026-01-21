CREATE VIEW [CHI].[CONOPS_CHI_EFH_NEW_V] AS



--SELECT * FROM [CHI].[CONOPS_CHI_EFH_NEW_V] where shiftflag = 'curr'
CREATE VIEW [chi].[CONOPS_CHI_EFH_NEW_V]
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
	t.EFHtarget AS EFHShifttarget
FROM dbo.Equivalent_Flat_Haul a WITH (NOLOCK)
LEFT JOIN [CHI].[CONOPS_CHI_SHIFT_INFO_V] b
	ON a.siteflag = 'CHI'
LEFT JOIN [CHI].[CONOPS_CHI_DELTA_C_TARGET_V] t
	ON b.siteflag = t.siteflag
WHERE FORMAT(a.UTC_CREATED_DATE, 'yyyy-MM-dd HH:mm:00') BETWEEN SHIFTSTARTDATETIME AND SHIFTENDDATETIME
AND CAST(FORMAT(a.UTC_CREATED_DATE, 'mm') AS INT) - CAST(FORMAT(SHIFTSTARTDATETIME, 'mm') AS INT) BETWEEN 0 AND 5



