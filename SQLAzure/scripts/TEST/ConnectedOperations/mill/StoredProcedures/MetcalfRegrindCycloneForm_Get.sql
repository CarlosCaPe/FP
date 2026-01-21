









/******************************************************************  
* PROCEDURE	: mill.MetcalfRegrindCycloneForm_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: sxavier
* SAMPLE	: 
	1. EXEC [mill].[MetcalfRegrindCycloneForm_Get] 'MOR', 'CURR'

* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {19 Dec 2024}		{sxavier}		{Initial Created}
* {11 Feb 2025}		{sxavier}		{Adjust logic to get data based on selected round}
*******************************************************************/ 
CREATE PROCEDURE [mill].[MetcalfRegrindCycloneForm_Get]
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
			mill.METCALF_REGRIND_CYCLONE_FORM_V
		WHERE
			TransactionId = @TransactionId
	END

	SELECT TOP 1
		A.TransactionId,
		A.SiteCode,
		A.TransactionDate,
		CASE WHEN A.RegrindCyclones <> '' 
			THEN A.UtcCreatedDate 
			ELSE (SELECT TOP 1 B.UtcCreatedDate 
					FROM mill.METCALF_REGRIND_CYCLONE_FORM_V B 
					WHERE B.RegrindCyclones <> '' AND B.SiteCode = @SiteCode AND B.UtcCreatedDate <= @UtcShiftEndDateTime
					ORDER BY B.UtcCreatedDate DESC) 
			END AS RegrindCyclonesUtcCreatedDate,
		CASE WHEN A.RegrindCyclones <> '' 
			THEN A.TransactionId 
			ELSE (SELECT TOP 1 B.TransactionId 
					FROM mill.METCALF_REGRIND_CYCLONE_FORM_V B 
					WHERE B.RegrindCyclones <> '' AND B.SiteCode = @SiteCode AND B.UtcCreatedDate <= @UtcShiftEndDateTime
					ORDER BY B.UtcCreatedDate DESC) 
			END AS RegrindCyclonesTransactionId,
		CASE WHEN A.RegrindCyclones <> '' 
			THEN A.RegrindCyclones 
			ELSE (SELECT TOP 1 B.RegrindCyclones 
					FROM mill.METCALF_REGRIND_CYCLONE_FORM_V B 
					WHERE B.RegrindCyclones <> '' AND B.SiteCode = @SiteCode AND B.UtcCreatedDate <= @UtcShiftEndDateTime
					ORDER BY B.UtcCreatedDate DESC) 
			END AS RegrindCyclones,
		CASE WHEN A.MediaSkips <> '' 
			THEN A.UtcCreatedDate 
			ELSE (SELECT TOP 1 B.UtcCreatedDate 
					FROM mill.METCALF_REGRIND_CYCLONE_FORM_V B 
					WHERE B.MediaSkips <> '' AND B.SiteCode = @SiteCode AND B.UtcCreatedDate <= @UtcShiftEndDateTime
					ORDER BY B.UtcCreatedDate DESC) 
			END AS MediaSkipsUtcCreatedDate,
		CASE WHEN A.MediaSkips <> '' 
			THEN A.TransactionId 
			ELSE (SELECT TOP 1 B.TransactionId 
					FROM mill.METCALF_REGRIND_CYCLONE_FORM_V B 
					WHERE B.MediaSkips <> '' AND B.SiteCode = @SiteCode AND B.UtcCreatedDate <= @UtcShiftEndDateTime
					ORDER BY B.UtcCreatedDate DESC) 
			END AS MediaSkipsTransactionId,
		CASE WHEN A.MediaSkips <> '' 
			THEN A.MediaSkips 
			ELSE (SELECT TOP 1 B.MediaSkips 
					FROM mill.METCALF_REGRIND_CYCLONE_FORM_V B 
					WHERE B.MediaSkips <> '' AND B.SiteCode = @SiteCode AND B.UtcCreatedDate <= @UtcShiftEndDateTime
					ORDER BY B.UtcCreatedDate DESC) 
			END AS MediaSkips,
		CASE WHEN A.Vertimills <> '' 
			THEN A.UtcCreatedDate 
			ELSE (SELECT TOP 1 B.UtcCreatedDate 
					FROM mill.METCALF_REGRIND_CYCLONE_FORM_V B 
					WHERE B.Vertimills <> '' AND B.SiteCode = @SiteCode AND B.UtcCreatedDate <= @UtcShiftEndDateTime
					ORDER BY B.UtcCreatedDate DESC) 
			END AS VertimillsUtcCreatedDate,
		CASE WHEN A.Vertimills <> '' 
			THEN A.TransactionId 
			ELSE (SELECT TOP 1 B.TransactionId 
					FROM mill.METCALF_REGRIND_CYCLONE_FORM_V B 
					WHERE B.Vertimills <> '' AND B.SiteCode = @SiteCode AND B.UtcCreatedDate <= @UtcShiftEndDateTime