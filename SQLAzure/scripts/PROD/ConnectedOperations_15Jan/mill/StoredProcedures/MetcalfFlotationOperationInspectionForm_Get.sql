








/******************************************************************  
* PROCEDURE	: mill.MetcalfFlotationOperationInspectionForm_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: sxavier
* SAMPLE	: 
	1. EXEC [mill].[MetcalfFlotationOperationInspectionForm_Get] 'MOR', 'PREV'

* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {02 Dec 2024}		{sxavier}		{Initial Created}
* {11 Feb 2025}		{sxavier}		{Adjust logic to get data based on selected round}
*******************************************************************/ 
CREATE PROCEDURE [mill].[MetcalfFlotationOperationInspectionForm_Get]
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
			mill.METCALF_FLOTATION_OPERATION_INSPECTION_FORM_V
		WHERE
			TransactionId = @TransactionId
	END

	SELECT TOP 1
		A.TransactionId,
		A.SiteCode,
		A.TransactionDate,
		A.InspectionTimeId,
		CASE WHEN A.InitialInspections <> '' 
			THEN A.UtcCreatedDate 
			ELSE (SELECT TOP 1 B.UtcCreatedDate 
					FROM mill.METCALF_FLOTATION_OPERATION_INSPECTION_FORM_V B 
					WHERE B.InitialInspections <> '' AND B.SiteCode = @SiteCode AND B.UtcCreatedDate <= @UtcShiftEndDateTime
					ORDER BY B.UtcCreatedDate DESC) 
			END AS InitialInspectionsUtcCreatedDate,
		CASE WHEN A.InitialInspections <> '' 
			THEN A.TransactionId 
			ELSE (SELECT TOP 1 B.TransactionId 
					FROM mill.METCALF_FLOTATION_OPERATION_INSPECTION_FORM_V B 
					WHERE B.InitialInspections <> '' AND B.SiteCode = @SiteCode AND B.UtcCreatedDate <= @UtcShiftEndDateTime
					ORDER BY B.UtcCreatedDate DESC) 
			END AS InitialInspectionsTransactionId,
		CASE WHEN A.InitialInspections <> '' 
			THEN A.InitialInspections 
			ELSE (SELECT TOP 1 B.InitialInspections 
					FROM mill.METCALF_FLOTATION_OPERATION_INSPECTION_FORM_V B 
					WHERE B.InitialInspections <> '' AND B.SiteCode = @SiteCode AND B.UtcCreatedDate <= @UtcShiftEndDateTime
					ORDER BY B.UtcCreatedDate DESC) 
			END AS InitialInspections,
		CASE WHEN A.MediaSkips <> '' 
			THEN A.UtcCreatedDate 
			ELSE (SELECT TOP 1 B.UtcCreatedDate 
					FROM mill.METCALF_FLOTATION_OPERATION_INSPECTION_FORM_V B 
					WHERE B.MediaSkips <> '' AND B.SiteCode = @SiteCode AND B.UtcCreatedDate <= @UtcShiftEndDateTime
					ORDER BY B.UtcCreatedDate DESC) 
			END AS MediaSkipsUtcCreatedDate,
		CASE WHEN A.MediaSkips <> '' 
			THEN A.TransactionId 
			ELSE (SELECT TOP 1 B.TransactionId 
					FROM mill.METCALF_FLOTATION_OPERATION_INSPECTION_FORM_V B 
					WHERE B.MediaSkips <> '' AND B.SiteCode = @SiteCode AND B.UtcCreatedDate <= @UtcShiftEndDateTime
					ORDER BY B.UtcCreatedDate DESC) 
			END AS MediaSkipsTransactionId,
		CASE WHEN A.MediaSkips <> '' 
			THEN A.MediaSkips 
			ELSE (SELECT TOP 1 B.MediaSkips 
					FROM mill.METCALF_FLOTATION_OPERATION_INSPECTION_FORM_V B 
					WHERE B.MediaSkips <> '' AND B.SiteCode = @SiteCode AND B.UtcCreatedDate <= @UtcShiftEndDateTime
					ORDER BY B.UtcCreatedDate DESC) 
			END AS MediaSkips,
		CASE WHEN A.DripPansCleaned <> '' 
			THEN A.UtcCreatedDate 
			ELSE (SELECT TOP 1 B.UtcCreatedDate 
					FROM mill.METCALF_FLOTATION_OPERATION_INSPECTION_FORM_V B 
					WHERE B.DripPansCleaned <> '' AND B.SiteCode = @SiteCode AND B.UtcCreatedDate <= @UtcShiftEndDateTime
					ORDER BY B.UtcCreatedDate DESC) 
			END AS DripPansCleanedUtcCreatedDate,
		CASE WHEN A.DripP