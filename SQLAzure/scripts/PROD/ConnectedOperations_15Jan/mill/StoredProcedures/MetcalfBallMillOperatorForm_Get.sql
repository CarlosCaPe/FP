








/******************************************************************  
* PROCEDURE	: mill.MetcalfBallMillOperatorForm_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: sxavier
* SAMPLE	: 
	1. EXEC [mill].[MetcalfBallMillOperatorForm_Get] 'MOR', 'CURR'

* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {14 Oct 2024}		{sxavier}		{Initial Created}
* {22 Oct 2024}		{sxavier}		{Return Inspection Comment}
* {14 Nov 2024}		{sxavier}		{Return Transaction Id for each card}
* {26 Nov 2024}		{sxavier}		{Fix logic where condition to get last form}
* {11 Dec 2024}		{sxavier}		{Fix logic to get from UtcCreatedDate}
* {11 Feb 2025}		{sxavier}		{Adjust logic to get data based on selected round}
*******************************************************************/ 
CREATE PROCEDURE [mill].[MetcalfBallMillOperatorForm_Get]
(
	@SiteCode VARCHAR(3),
	@ShiftCode VARCHAR(4),
	@TransactionId INT = NULL
)
AS                        
BEGIN          
SET NOCOUNT ON
	
	DECLARE @UtcShiftStartDateTime DATETIME, @UtcShiftEndDateTime DATETIME;

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
			mill.METCALF_BALL_MILL_OPERATOR_FORM_V
		WHERE
			TransactionId = @TransactionId
	END

	SELECT TOP 1
		A.TransactionId,
		A.SiteCode,
		A.TransactionDate,
		A.InspectionTimeId,
		CASE WHEN A.CyclonePack1 <> '' 
			THEN A.UtcCreatedDate 
			ELSE (SELECT TOP 1 B.UtcCreatedDate 
					FROM mill.METCALF_BALL_MILL_OPERATOR_FORM_V B 
					WHERE B.CyclonePack1 <> '' AND B.SiteCode = @SiteCode AND B.UtcCreatedDate <= @UtcShiftEndDateTime
					ORDER BY B.UtcCreatedDate DESC) 
			END AS CyclonePack1UtcCreatedDate,
		CASE WHEN A.CyclonePack1 <> '' 
			THEN A.TransactionId 
			ELSE (SELECT TOP 1 B.TransactionId 
					FROM mill.METCALF_BALL_MILL_OPERATOR_FORM_V B 
					WHERE B.CyclonePack1 <> '' AND B.SiteCode = @SiteCode AND B.UtcCreatedDate <= @UtcShiftEndDateTime
					ORDER BY B.UtcCreatedDate DESC) 
			END AS CyclonePack1TransactionId,
		CASE WHEN A.CyclonePack1 <> '' 
			THEN A.CyclonePack1 
			ELSE (SELECT TOP 1 B.CyclonePack1 
					FROM mill.METCALF_BALL_MILL_OPERATOR_FORM_V B 
					WHERE B.CyclonePack1 <> '' AND B.SiteCode = @SiteCode AND B.UtcCreatedDate <= @UtcShiftEndDateTime
					ORDER BY B.UtcCreatedDate DESC) 
			END AS CyclonePack1,
		CASE WHEN A.CyclonePack2 <> '' 
			THEN A.UtcCreatedDate 
			ELSE (SELECT TOP 1 B.UtcCreatedDate 
					FROM mill.METCALF_BALL_MILL_OPERATOR_FORM_V B 
					WHERE B.CyclonePack2 <> '' AND B.SiteCode = @SiteCode AND B.UtcCreatedDate <= @UtcShiftEndDateTime
					ORDER BY B.UtcCreatedDate DESC) 
			END AS CyclonePack2UtcCreatedDate,
		CASE WHEN A.CyclonePack2 <> '' 
			THEN A.TransactionId 
			ELSE (SELECT TOP 1 B.TransactionId 
					FROM mill.METCALF_BALL_MILL_OPERATOR_FORM_V B 
					WHERE B.CyclonePack2 <> '' AND B.SiteCode = @SiteCode AND B.UtcCreatedDate <= @UtcShiftEndDateTime
					ORDER BY B.UtcCreatedDate DESC) 
			END AS CyclonePack2TransactionId,
		CASE WHEN A.CyclonePack2 <> '' 
			THEN A.CyclonePack2 
			ELSE (SELECT TOP 1 B.CyclonePack2 
					FROM mill.METCALF_BALL_MILL_OPERATOR_FORM_V B 
					WHERE B.CyclonePack2 <> '' AND B.SiteCode = @SiteCode AND B.UtcCreatedDate <= @UtcShiftEndDateTime
					ORDER BY B.UtcCreatedDate DESC) 
			END AS CyclonePack2,
		CASE WHEN A.Mill1 <> '' 
			THEN A.UtcCreatedDate 
			ELSE (SELECT TOP 1 B.UtcCreatedDate 
					FROM mill.METCALF_BALL_MILL_OPERATOR_FORM_V B 
					WHERE B.Mill1 <> '' AND B.SiteCode = @SiteCode AND B.UtcCreatedDate <= @UtcShiftEndDateTime
					ORDER BY B.UtcCreatedDate