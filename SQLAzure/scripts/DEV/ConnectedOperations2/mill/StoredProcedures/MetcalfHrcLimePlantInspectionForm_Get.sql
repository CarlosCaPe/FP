








/******************************************************************  
* PROCEDURE	: mill.MetcalfHrcLimePlantInspectionForm_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: sxavier
* SAMPLE	: 
	1. EXEC [mill].[MetcalfHrcLimePlantInspectionForm_Get] 'MOR', 'CURR', '910496'

* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {02 Dec 2024}		{sxavier}		{Initial Created}
* {11 Feb 2025}		{sxavier}		{Adjust logic to get data based on selected round}
*******************************************************************/ 
CREATE PROCEDURE [mill].[MetcalfHrcLimePlantInspectionForm_Get]
(
	@SiteCode VARCHAR(3),
	@ShiftCode VARCHAR(4),
	@TransactionId INT = NULL
)
AS                        
BEGIN          
SET NOCOUNT ON
	
	DECLARE @UtcShiftStartDateTime DATETIME, @UtcShiftEndDateTime DATETIME, @DryFeederUtcCreatedDate DATETIME, @WetFeederUtcCreatedDate DATETIME;

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
		SELECT
			@UtcShiftEndDateTime = UtcCreatedDate
		FROM
			mill.METCALF_HRC_LIME_PLANT_INSPECTION_FORM_V
		WHERE
			TransactionId = @TransactionId
	END

	SELECT TOP 1
		@DryFeederUtcCreatedDate = CASE WHEN A.DryFeeder <> '' 
			THEN A.UtcCreatedDate 
			ELSE (SELECT TOP 1 B.UtcCreatedDate 
					FROM mill.METCALF_HRC_LIME_PLANT_INSPECTION_FORM_V B 
					WHERE B.DryFeeder <> '' AND B.SiteCode = @SiteCode AND B.UtcCreatedDate <= @UtcShiftEndDateTime
					ORDER BY B.UtcCreatedDate DESC) 
			END,
		@WetFeederUtcCreatedDate = CASE WHEN A.WetFeeders <> '' 
			THEN A.UtcCreatedDate 
			ELSE (SELECT TOP 1 B.UtcCreatedDate 
					FROM mill.METCALF_HRC_LIME_PLANT_INSPECTION_FORM_V B 
					WHERE B.WetFeeders <> '' AND B.SiteCode = @SiteCode AND B.UtcCreatedDate <= @UtcShiftEndDateTime
					ORDER BY B.UtcCreatedDate DESC) 
			END
	FROM
		mill.METCALF_HRC_LIME_PLANT_INSPECTION_FORM_V A
	WHERE
		((@TransactionId IS NOT NULL AND A.TransactionId = @TransactionId) 
		OR (@TransactionId IS NULL AND A.UtcCreatedDate <= @UtcShiftEndDateTime))
		AND SiteCode = @SiteCode
	ORDER BY
		A.UtcCreatedDate DESC

	SELECT TOP 1
		A.TransactionId,
		A.SiteCode,
		A.TransactionDate,
		CASE WHEN A.Hrc <> '' 
			THEN A.UtcCreatedDate 
			ELSE (SELECT TOP 1 B.UtcCreatedDate 
					FROM mill.METCALF_HRC_LIME_PLANT_INSPECTION_FORM_V B 
					WHERE B.Hrc <> '' AND B.SiteCode = @SiteCode AND B.UtcCreatedDate <= @UtcShiftEndDateTime
					ORDER BY B.UtcCreatedDate DESC) 
			END AS HrcUtcCreatedDate,
		CASE WHEN A.Hrc <> '' 
			THEN A.TransactionId 
			ELSE (SELECT TOP 1 B.TransactionId 
					FROM mill.METCALF_HRC_LIME_PLANT_INSPECTION_FORM_V B 
					WHERE B.Hrc <> '' AND B.SiteCode = @SiteCode AND B.UtcCreatedDate <= @UtcShiftEndDateTime
					ORDER BY B.UtcCreatedDate DESC) 
			END AS HrcTransactionId,
		CASE WHEN A.Hrc <> '' 
			THEN A.Hrc 
			ELSE (SELECT TOP 1 B.Hrc 
					FROM mill.METCALF_HRC_LIME_PLANT_INSPECTION_FORM_V B 
					WHERE B.Hrc <> '' AND B.SiteCode = @SiteCode AND B.UtcCreatedDate <= @UtcShiftEndDateTime
					ORDER BY B.UtcCreatedDate DESC) 
			END AS Hrc,
		CASE WHEN A.LimePlant <> '' 
			THEN A.UtcCreatedDate 
			ELSE (SELECT TOP 1 B.UtcCreatedDate 
					FROM mill.METCALF_HRC_LIME_PLANT_INSPECTION_FORM_V B 
					WHERE B.LimePlant <> '' AND B.SiteCode = @SiteCode AND B.UtcCreatedDate <= @UtcShiftEndDateTime
					ORDER BY B.UtcCreatedDate DESC) 
			END AS LimePlantUtcCreatedDate,
		CASE WHEN A.LimePlant <> '' 
			THEN A.TransactionId 
			ELSE (SELECT TOP 1 B.TransactionId 
					FROM mill.METCALF_HRC_LIME_PLANT_INSPECTION_FORM_V B 
					WHERE B.LimePlant <> '' AND B.SiteCode = @SiteCode AND B.UtcCreat