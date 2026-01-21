CREATE VIEW [MOR].[DRILL_ASSET_EFFICIENCY_V] AS



--SELECT * FROM [MOR].[DRILL_ASSET_EFFICIENCY_V] WITH (NOLOCK)
CREATE VIEW [mor].[DRILL_ASSET_EFFICIENCY_V]
AS

SELECT 
(CONVERT(INT, (DATEDIFF(DD, '7/12/2007', CONVERT(DATE, LEFT(ae.shiftid, 6), 12))*2) + 27412 + (SELECT RIGHT(ae.SHIFTID,1) - 1))) SHIFTINDEX,
ae.SITEFLAG AS SITE_CODE,
ae.EQMT AS DRILL_ID,
ae.EQMTTYPE AS MODEL,
ae.StartDateTime,
ae.EndDateTime,
ae.Duration,
ae.StatusIdx,
ae.Status,
ae.CategoryIdx,
ae.Category,
ae.ReasonIdx,
ae.Reasons AS Reason
FROM mor.asset_efficiency ae WITH(NOLOCK)
LEFT JOIN mor.conops_mor_shift_info_v s
	ON ae.shiftid = s.shiftid
WHERE ae.unittype = 'Drill'



