











/******************************************************************  
* PROCEDURE	: mill.MetcalfThickenerOperatorForm_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: sxavier
* SAMPLE	: 
	1. EXEC [mill].[MetcalfThickenerOperatorForm_Get] 'MOR', 'CURR'

* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {20 Dec 2024}		{sxavier}		{Initial Created}
* {12 Feb 2025}		{sxavier}		{Adjust logic to get data based on selected round}
* {27 Feb 2025}		{aarivian}		{support density solids}
*******************************************************************/ 
CREATE PROCEDURE [mill].[MetcalfThickenerOperatorForm_Get]
(
	@SiteCode VARCHAR(3),
	@ShiftCode VARCHAR(4),
	@TransactionId INT = NULL
)
AS                        
BEGIN          
SET NOCOUNT ON
	
	DECLARE 
		@UtcShiftStartDateTime DATETIME, 
		@UtcShiftEndDateTime DATETIME;
	DECLARE
		@IsThickenerOperatorId BIT = 0,
		@IsDensitySolidsId BIT = 0;

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

	IF @TransactionId IS NOT NULL
	BEGIN
		SELECT @UtcShiftEndDateTime = COALESCE(
			(SELECT UtcCreatedDate FROM [mill].[METCALF_THICKENER_OPERATOR_FORM_V] WHERE TransactionId = @TransactionId),
			(SELECT UtcCreatedDate FROM [mill].[METCALF_THICKENER_DENSITY_SOLIDS_FORM_V] WHERE TransactionId = @TransactionId)
		);

		SET @IsThickenerOperatorId = CASE
			WHEN EXISTS (SELECT 1 FROM [mill].[METCALF_THICKENER_OPERATOR_FORM_V] WHERE TransactionId = @TransactionId)
			THEN 1 ELSE 0
		END;

		SET @IsDensitySolidsId = CASE
			WHEN EXISTS (SELECT 1 FROM [mill].[METCALF_THICKENER_DENSITY_SOLIDS_FORM_V] WHERE TransactionId = @TransactionId)
			THEN 1 ELSE 0
		END;
	END;

	-- Combine Thickener Operator and Density SOlids
	WITH ThickenerData AS (
		SELECT TOP 1
			A.TransactionId,
			A.SiteCode,
			A.TransactionDate,
			A.RawData,
			A.ThickenerOperatorLogId,
			A.ConcentrateThickener,
			A.Clarifier,
			A.[5010Thickener],
			A.[5011Thickener],
			A.DeadThickener,
			A.Flocculant,
			A.[4340SumpPump],
			A.CleanWeir,
			A.ReclaimPumps,
			A.InspectionComment,
			A.CreatedBy,
			A.UtcCreatedDate,
			A.ModifiedBy,
			A.UtcModifiedDate
		FROM [mill].[METCALF_THICKENER_OPERATOR_FORM_V] A
		WHERE
			((@TransactionId IS NOT NULL AND A.TransactionId = @TransactionId) 
			OR ((@TransactionId IS NULL OR @IsThickenerOperatorId = 0) AND A.UtcCreatedDate <= @UtcShiftEndDateTime))
			AND SiteCode = @SiteCode
		ORDER BY A.UtcCreatedDate DESC
	),
	DensitySolidData AS (
		SELECT TOP 1
			A.TransactionId,
			A.SiteCode,
			A.TransactionDate,
			A.ShiftId,
			A.RawData,
			A.DensitySolids,
			A.InspectionComment,
			A.CreatedBy,
			A.UtcCreatedDate,
			A.ModifiedBy,
			A.UtcModifiedDate
		FROM [mill].[METCALF_THICKENER_DENSITY_SOLIDS_FORM_V] A
		WHERE
			((@TransactionId IS NOT NULL AND A.TransactionId = @TransactionId) 
			OR ((@TransactionId IS NULL OR @IsDensitySolidsId = 0) AND A.UtcCreatedDate <= @UtcShiftEndDateTime))
			AND SiteCode = @SiteCode
		ORDER BY A.UtcCreatedDate DESC
	),
	LatestData AS (
		SELECT TOP 1
			A.TransactionId,
			A.SiteCode,
			A.TransactionDate,
			A.UtcCreatedDate
		FROM (
			SELECT 
				TransactionId,
				SiteCode,
				TransactionDate,
				UtcCreatedDate
			FROM ThickenerData

			UNION ALL

			SELECT 
				TransactionId,
				SiteCode,
				TransactionDate,
				UtcCreatedDate
			FROM DensitySolidData

		) A
		ORDER BY A.UtcCreatedDate DESC
	),
	CombinedData AS (
		SELECT
			LatestTransactionId = (SELECT TransactionId FROM LatestData),
			LatestSiteCode = (SELECT SiteCode FROM LatestData),
			LatestTransactionDate = (SELECT TransactionDa