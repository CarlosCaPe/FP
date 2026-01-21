








/******************************************************************  
* PROCEDURE	: mill.MetcalfSecondaryCrusherInspectionForm_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: sxavier
* SAMPLE	: 
	1. EXEC [mill].[MetcalfSecondaryCrusherInspectionForm_Get] 'MOR', 'PREV'

* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {15 Nov 2024}		{sxavier}		{Initial Created}
* {11 Dec 2024}		{sxavier}		{Fix logic to get from UtcCreatedDate}
* {11 Feb 2025}		{sxavier}		{Adjust logic to get data based on selected round}
*******************************************************************/ 
CREATE PROCEDURE [mill].[MetcalfSecondaryCrusherInspectionForm_Get]
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
			mill.METCALF_SECONDARY_CRUSHER_INSPECTION_FORM_V
		WHERE
			TransactionId = @TransactionId
	END

	SELECT TOP 1
		A.TransactionId,
		A.SiteCode,
		A.TransactionDate,
		A.AreaId,
		--ApronFeeder501
		CASE WHEN A.ApronFeeder501 <> '' 
			THEN A.UtcCreatedDate 
			ELSE (SELECT TOP 1 B.UtcCreatedDate 
					FROM mill.METCALF_SECONDARY_CRUSHER_INSPECTION_FORM_V B 
					WHERE B.ApronFeeder501 <> '' AND B.SiteCode = @SiteCode AND B.UtcCreatedDate <= @UtcShiftEndDateTime
					ORDER BY B.UtcCreatedDate DESC) 
			END AS ApronFeeder501UtcCreatedDate,
		CASE WHEN A.ApronFeeder501 <> '' 
			THEN A.TransactionId 
			ELSE (SELECT TOP 1 B.TransactionId 
					FROM mill.METCALF_SECONDARY_CRUSHER_INSPECTION_FORM_V B 
					WHERE B.ApronFeeder501 <> '' AND B.SiteCode = @SiteCode AND B.UtcCreatedDate <= @UtcShiftEndDateTime
					ORDER BY B.UtcCreatedDate DESC) 
			END AS ApronFeeder501TransactionId,
		CASE WHEN A.ApronFeeder501 <> '' 
			THEN A.ApronFeeder501 
			ELSE (SELECT TOP 1 B.ApronFeeder501 
					FROM mill.METCALF_SECONDARY_CRUSHER_INSPECTION_FORM_V B 
					WHERE B.ApronFeeder501 <> '' AND B.SiteCode = @SiteCode AND B.UtcCreatedDate <= @UtcShiftEndDateTime
					ORDER BY B.UtcCreatedDate DESC) 
			END AS ApronFeeder501,
		--ApronFeeder601
		CASE WHEN A.ApronFeeder601 <> '' 
			THEN A.UtcCreatedDate 
			ELSE (SELECT TOP 1 B.UtcCreatedDate 
					FROM mill.METCALF_SECONDARY_CRUSHER_INSPECTION_FORM_V B 
					WHERE B.ApronFeeder601 <> '' AND B.SiteCode = @SiteCode AND B.UtcCreatedDate <= @UtcShiftEndDateTime
					ORDER BY B.UtcCreatedDate DESC)  
			END AS ApronFeeder601UtcCreatedDate,
		CASE WHEN A.ApronFeeder601 <> '' 
			THEN A.TransactionId 
			ELSE (SELECT TOP 1 B.TransactionId 
					FROM mill.METCALF_SECONDARY_CRUSHER_INSPECTION_FORM_V B 
					WHERE B.ApronFeeder601 <> '' AND B.SiteCode = @SiteCode AND B.UtcCreatedDate <= @UtcShiftEndDateTime
					ORDER BY B.UtcCreatedDate DESC) 
			END AS ApronFeeder601TransactionId,
		CASE WHEN A.ApronFeeder601 <> '' 
			THEN A.ApronFeeder601 
			ELSE (SELECT TOP 1 B.ApronFeeder601 
					FROM mill.METCALF_SECONDARY_CRUSHER_INSPECTION_FORM_V B 
					WHERE B.ApronFeeder601 <> '' AND B.SiteCode = @SiteCode AND B.UtcCreatedDate <= @UtcShiftEndDateTime
					ORDER BY B.UtcCreatedDate DESC) 
			END AS ApronFeeder601,
		--ApronFeeder701
		CASE WHEN A.ApronFeeder701 <> '' 
			THEN A.UtcCreatedDate 
			ELSE (SELECT TOP 1 B.UtcCreatedDate 
					FROM mill.METCALF_SECONDARY_CRUSHER_INSPECTION_FORM_V B 
					WHERE B.ApronFeeder701 <> '' AND B.SiteCode = @SiteCode AND B.UtcCreatedDate <= @UtcShiftEndDateTime
					