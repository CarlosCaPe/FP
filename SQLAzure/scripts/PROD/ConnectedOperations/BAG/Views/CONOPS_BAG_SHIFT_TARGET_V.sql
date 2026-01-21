CREATE VIEW [BAG].[CONOPS_BAG_SHIFT_TARGET_V] AS

--select * from [bag].[CONOPS_BAG_SHIFT_TARGET_V]
CREATE VIEW [BAG].[CONOPS_BAG_SHIFT_TARGET_V]
AS

SELECT
	a.siteflag,
	a.shiftflag,
	a.shiftid,
	pv.ShiftTarget,
	CASE
		WHEN SHIFTDURATION = 0 THEN pv.ShiftTarget
		ELSE CAST((SHIFTDURATION / 43200.0) * pv.ShiftTarget AS INT)
	END AS TargetValue,
	pv.TonsMovedTarget,
	pv.EFHTarget AS EFHShiftTarget,
	CASE
		WHEN SHIFTDURATION = 0 THEN pv.EFHTarget
		ELSE CAST((SHIFTDURATION / 43200.0) * pv.EFHTarget AS INT)
	END AS EFHTarget
FROM [bag].[CONOPS_BAG_SHIFT_INFO_V] a WITH (NOLOCK)
LEFT JOIN (
	SELECT
		FORMATSHIFTID,
		CAST(SUM(TOTALMINED) AS INT) AS ShiftTarget,
		CAST(SUM(TOTALMOVED) AS INT) AS TonsMovedTarget,
		MAX(EFH) AS EFHTarget
	FROM [bag].[plan_values] WITH (NOLOCK)
	GROUP BY FORMATSHIFTID
) pv ON a.shiftid = pv.FORMATSHIFTID;

