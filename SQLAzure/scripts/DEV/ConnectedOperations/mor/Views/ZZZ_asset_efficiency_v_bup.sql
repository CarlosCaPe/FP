CREATE VIEW [mor].[ZZZ_asset_efficiency_v_bup] AS

CREATE VIEW [mor].[asset_efficiency]   
AS      

SELECT Right([Year], 2) + FORMAT(CAST([Month] AS numeric), '00') +
		FORMAT(CAST([Day] AS numeric), '00') + FORMAT(CAST(SHIFT_CODE AS numeric), '000') [ShiftId],
	   EQMT,
	   NULL [FieldEqmttype],
	   NULL [eqmttype],
	   [UnitType],
	   START_TIME_TS [StartDateTime],
	   END_TIME_TS [EndDateTime],
	   [Duration],
	   STATUS [StatusIdx],
	   [StatusDesc] [Status],
	   CATEGORY [CategoryIdx],
	   [CategoryDesc] [Category],
	   REASON [reasonidx],
	   [ReasonDesc] [reasons],
	   COMMENTS
FROM (
	SELECT REVERSE(PARSENAME(REPLACE(REVERSE([ShiftDate]), '-', '.'), 1)) AS [Year],
		   REVERSE(PARSENAME(REPLACE(REVERSE([ShiftDate]), '-', '.'), 2)) AS [Month],
		   REVERSE(PARSENAME(REPLACE(REVERSE([ShiftDate]), '-', '.'), 3)) AS [Day],
		   SHIFT_CODE,
		   EQMT,
		   [HOS].UNIT,
		   [eqmtType].Description [UnitType],
		   START_TIME_TS,
		   END_TIME_TS,
		   DURATION,
		   [hos].STATUS,
		   [statsType].Description [StatusDesc],
		   REASON,
		   [r].FIELDNAME [ReasonDesc],
		   CATEGORY,
		   [categoryType].Description [CategoryDesc],
		   COMMENTS
	FROM [mor].[EQUIPMENT_HOURLY_STATUS] [HOS] WITH (NOLOCK)
	LEFT JOIN [mor].[enum] [eqmtType] WITH (NOLOCK) 
	ON [HOS].UNIT = [eqmtType].Idx AND [eqmtType].EnumTypeId = 110
	LEFT JOIN [mor].[enum] [categoryType] WITH (NOLOCK) 
	ON [HOS].CATEGORY = [categoryType].Idx AND [categoryType].EnumTypeId = 20
	LEFT JOIN [mor].[enum] [statsType] WITH (NOLOCK) 
	ON [HOS].STATUS = [statsType].Idx AND [statsType].EnumTypeId = 19
	LEFT JOIN [dbo].[pit_reason] [r] WITH (NOLOCK)
	ON [r].FIELDID = [hos].REASON AND [r].SITE_CODE = [hos].SITE_CODE
	WHERE [HOS].UNIT IN (1,2)
) [main]

