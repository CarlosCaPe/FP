









/******************************************************************  
* PROCEDURE	: [mill].[MetcalfOverview_OpenPlantCondition_Get]
* PURPOSE	: 
* NOTES		: 
* CREATED	: aarivian
* SAMPLE	: 
	1. EXEC [mill].[MetcalfOverview_OpenPlantCondition_Get] 'MOR', 'CURR'

* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {25 Feb 2025}		{aarivian}		{Initial Created}
* {28 Feb 2025}		{aarivian}		{Adjustment for get per card}
*******************************************************************/ 
CREATE PROCEDURE [mill].[MetcalfOverview_OpenPlantCondition_Get]
(
	@SiteCode VARCHAR(3),
	@ShiftCode VARCHAR(4)
)
AS                        
BEGIN          
SET NOCOUNT ON
	
	DECLARE 
		@UtcShiftStartDateTime DATETIME, 
		@UtcShiftEndDateTime DATETIME,
		@5010ThickenerUtcCreatedDate DATETIME, 
		@5011ThickenerUtcCreatedDate DATETIME,
		@UtcShiftStart5010Thickener DATETIME,
		@UtcShiftStart5011Thickener DATETIME,
		@DryFeederUtcCreatedDate DATETIME, 
		@WetFeederUtcCreatedDate DATETIME,
		@UtcShiftStartDryFeeder DATETIME,
		@UtcShiftStartWetFeeder DATETIME;

	IF @SiteCode = 'MOR'
	BEGIN
		SELECT
			@UtcShiftStartDateTime = DATEADD(HOUR, -A.current_utc_offset, A.ShiftStartDateTime),
			@UtcShiftEndDateTime = DATEADD(HOUR,  -A.current_utc_offset, A.ShiftEndDateTime)
		FROM
			[mor].[CONOPS_MOR_SHIFT_INFO_NEW_V] A
		WHERE
			A.ShiftFlag = @ShiftCode
	END

	-- DataCode
	--> BLML (Ball Mill)
	--> FTOI (Flotation Operation Inspection)
	--> HLPI (Hrc Lime Plant Inspection Form)
	--> RGCY (Regrind Cyclone Form)
	--> SCRI (Secondary Crusher Inspection Form)
	-->	TOPR (Thickener Operator Form)
	--> TUNI (Thickener Underflow Inspection Form)
	-->	TDNS (Thickener Density Solids Form)

	CREATE TABLE #PlanConditionData
	(
		DataCode VARCHAR(10),
		TransactionId INT,
		UtcCreatedDate DATETIME
	)

	;WITH SCRI AS (
		
		--ApronFeeder501
		SELECT TOP 1
			B.TransactionId,
			B.UtcCreatedDate
		FROM [mill].[METCALF_SECONDARY_CRUSHER_INSPECTION_FORM_V] B
		WHERE 
			B.ApronFeeder501 <> '' 
			AND B.SiteCode = @SiteCode 
			AND B.UtcCreatedDate <= @UtcShiftEndDateTime
		ORDER BY B.UtcCreatedDate DESC

		UNION

		--ApronFeeder601
		SELECT TOP 1
			B.TransactionId,
			B.UtcCreatedDate
		FROM [mill].[METCALF_SECONDARY_CRUSHER_INSPECTION_FORM_V] B
		WHERE 
			B.ApronFeeder601 <> '' 
			AND B.SiteCode = @SiteCode 
			AND B.UtcCreatedDate <= @UtcShiftEndDateTime
		ORDER BY B.UtcCreatedDate DESC
		
		UNION

		--ApronFeeder701
		SELECT TOP 1
			B.TransactionId,
			B.UtcCreatedDate
		FROM [mill].[METCALF_SECONDARY_CRUSHER_INSPECTION_FORM_V] B
		WHERE 
			B.ApronFeeder701 <> '' 
			AND B.SiteCode = @SiteCode 
			AND B.UtcCreatedDate <= @UtcShiftEndDateTime
		ORDER BY B.UtcCreatedDate DESC
		
		UNION

		--ScreenFeeder2120
		SELECT TOP 1
			B.TransactionId,
			B.UtcCreatedDate
		FROM [mill].[METCALF_SECONDARY_CRUSHER_INSPECTION_FORM_V] B
		WHERE 
			B.ScreenFeeder2120 <> '' 
			AND B.SiteCode = @SiteCode 
			AND B.UtcCreatedDate <= @UtcShiftEndDateTime
		ORDER BY B.UtcCreatedDate DESC

		UNION

		--ScreenFeeder2125
		SELECT TOP 1
			B.TransactionId,
			B.UtcCreatedDate
		FROM [mill].[METCALF_SECONDARY_CRUSHER_INSPECTION_FORM_V] B
		WHERE 
			B.ScreenFeeder2125 <> '' 
			AND B.SiteCode = @SiteCode 
			AND B.UtcCreatedDate <= @UtcShiftEndDateTime
		ORDER BY B.UtcCreatedDate DESC

		UNION

		--Screen2140
		SELECT TOP 1
			B.TransactionId,
			B.UtcCreatedDate
		FROM [mill].[METCALF_SECONDARY_CRUSHER_INSPECTION_FORM_V] B
		WHERE 
			B.Screen2140 <> '' 
			AND B.SiteCode = @SiteCode 
			AND B.UtcCreatedDate <= @UtcShiftEndDateTime
		ORDER BY B.UtcCreatedDate DESC
		
		UNION

		--Screen2145
		SELECT TOP 1
			B.TransactionId,
			B.UtcCreatedDate
		FROM [mill].[METCALF_SECONDARY_CRUSHER_INSPECTION_FORM_V] B
		WHERE 
			B.Screen2145 <> '' 
			AND B.SiteCode = @Si