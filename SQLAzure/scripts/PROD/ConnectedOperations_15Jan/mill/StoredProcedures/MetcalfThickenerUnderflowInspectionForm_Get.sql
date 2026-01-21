









/******************************************************************  
* PROCEDURE	: mill.MetcalfThickenerUnderflowInspectionForm_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: sxavier
* SAMPLE	: 
	1. EXEC [mill].[MetcalfThickenerUnderflowInspectionForm_Get] 'MOR', 'CURR'

* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {19 Dec 2024}		{sxavier}		{Initial Created}
* {12 Feb 2025}		{sxavier}		{Adjust logic to get data based on selected round}
*******************************************************************/ 
CREATE PROCEDURE [mill].[MetcalfThickenerUnderflowInspectionForm_Get]
(
	@SiteCode VARCHAR(3),
	@ShiftCode VARCHAR(4),
	@TransactionId INT = NULL
)
AS                        
BEGIN          
SET NOCOUNT ON
	
	DECLARE @UtcShiftStartDateTime DATETIME, @UtcShiftEndDateTime DATETIME, @5010ThickenerUtcCreatedDate DATETIME, @5011ThickenerUtcCreatedDate DATETIME;

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
			mill.METCALF_THICKENER_UNDERFLOW_INSPECTION_FORM_V
		WHERE
			TransactionId = @TransactionId
	END

	SELECT TOP 1
		@5010ThickenerUtcCreatedDate = CASE WHEN A.[5010Thickener] <> '' 
			THEN A.UtcCreatedDate 
			ELSE (SELECT TOP 1 B.UtcCreatedDate 
					FROM mill.METCALF_THICKENER_UNDERFLOW_INSPECTION_FORM_V B 
					WHERE B.[5010Thickener] <> '' AND B.SiteCode = @SiteCode AND B.UtcCreatedDate <= @UtcShiftEndDateTime
					ORDER BY B.UtcCreatedDate DESC) 
			END,
		@5011ThickenerUtcCreatedDate = CASE WHEN A.[5011Thickener] <> '' 
			THEN A.UtcCreatedDate 
			ELSE (SELECT TOP 1 B.UtcCreatedDate 
					FROM mill.METCALF_THICKENER_UNDERFLOW_INSPECTION_FORM_V B 
					WHERE B.[5011Thickener] <> '' AND B.SiteCode = @SiteCode AND B.UtcCreatedDate <= @UtcShiftEndDateTime
					ORDER BY B.UtcCreatedDate DESC) 
			END
	FROM
		mill.METCALF_THICKENER_UNDERFLOW_INSPECTION_FORM_V A
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
		CASE WHEN A.[5010Thickener] <> '' 
			THEN A.UtcCreatedDate 
			ELSE (SELECT TOP 1 B.UtcCreatedDate 
					FROM mill.METCALF_THICKENER_UNDERFLOW_INSPECTION_FORM_V B 
					WHERE B.[5010Thickener] <> '' AND B.SiteCode = @SiteCode AND B.UtcCreatedDate <= @UtcShiftEndDateTime
					ORDER BY B.UtcCreatedDate DESC) 
			END AS [Thickener5010UtcCreatedDate],
		CASE WHEN A.[5010Thickener] <> '' 
			THEN A.TransactionId 
			ELSE (SELECT TOP 1 B.TransactionId 
					FROM mill.METCALF_THICKENER_UNDERFLOW_INSPECTION_FORM_V B 
					WHERE B.[5010Thickener] <> '' AND B.SiteCode = @SiteCode AND B.UtcCreatedDate <= @UtcShiftEndDateTime
					ORDER BY B.UtcCreatedDate DESC) 
			END AS [Thickener5010TransactionId],
		CASE WHEN A.[5011Thickener] <> '' 
			THEN A.UtcCreatedDate 
			ELSE (SELECT TOP 1 B.UtcCreatedDate 
					FROM mill.METCALF_THICKENER_UNDERFLOW_INSPECTION_FORM_V B 
					WHERE B.[5011Thickener] <> '' AND B.SiteCode = @SiteCode AND B.UtcCreatedDate <= @UtcShiftEndDateTime
					ORDER BY B.UtcCreatedDate DESC) 
			END AS [Thickener5011UtcCreatedDate],
		CASE WHEN A.[5011Thickener] <> '' 
			THEN A.TransactionId 
			ELSE (SELECT TOP 1 B.TransactionId 
					FROM mill.METCALF_THICKENER_UNDERFLOW_INSPECTION_FORM_V B 
					WHERE B.[5011Thickener] <> '' AND B.SiteCode = @SiteCode AND B.UtcCreatedDate <= @UtcShiftEndDateTime
					ORDER BY B.UtcCreatedDate DESC) 
			END AS [Thickener50