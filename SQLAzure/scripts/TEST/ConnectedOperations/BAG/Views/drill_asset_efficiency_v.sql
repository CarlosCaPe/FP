CREATE VIEW [BAG].[drill_asset_efficiency_v] AS

--SELECT * FROM [bag].[drill_asset_efficiency_v] WITH (NOLOCK)  
CREATE VIEW [bag].[drill_asset_efficiency_v]     
AS

SELECT 
	(CONVERT(INT, (DATEDIFF(DD, '7/12/2007', CAST(SHIFT_START_DATE_TIME AS DATE))*2) + 27412 + (SELECT RIGHT([SHIFT_ID] ,1) - 1))) SHIFTINDEX,
	SITEFLAG AS SITE_CODE,
	REPLACE(EQMT, '-','') AS DRILL_ID,
	EQMTTYPE AS MODEL,
	StartDateTime,
	EndDateTime,
	Duration,
	StatusIdx,
	Status,
	CategoryIdx,
	Category,
	ReasonIdx,
	Reasons AS Reason
FROM bag2.asset_efficiency ae WITH(NOLOCK)
LEFT JOIN bag2.MSMODEL_SHIFT msh
	ON ae.SHIFTID = msh.SHIFT_ID COLLATE SQL_Latin1_General_CP1_CI_AS
WHERE UnitType = 'Drill'


