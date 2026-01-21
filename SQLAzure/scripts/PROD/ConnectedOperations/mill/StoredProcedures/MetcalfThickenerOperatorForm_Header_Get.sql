









/******************************************************************  
* PROCEDURE	: mill.[MetcalfThickenerOperatorForm_Header_Get]
* PURPOSE	: 
* NOTES		: 
* CREATED	: sxavier
* SAMPLE	: 
	1. EXEC [mill].[MetcalfThickenerOperatorForm_Header_Get] 'MOR', 'CURR'

* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {20 Dec 2024}		{sxavier}		{Initial Created}
* {26 Feb 2025}		{aairvian}		{support Density Solids}
*******************************************************************/ 
CREATE PROCEDURE [mill].[MetcalfThickenerOperatorForm_Header_Get]
(
	@SiteCode VARCHAR(3),
	@ShiftCode VARCHAR(4)
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

	;WITH
	Round0LatestMark AS (
		SELECT
			R.TransactionId,
			R.UtcCreatedDate,
			CASE 
				WHEN ROW_NUMBER() OVER (ORDER BY R.UtcCreatedDate DESC) = 1 THEN 1
				ELSE 0
			END AS IsRound0
		FROM (
			SELECT TOP 1
				A.TransactionId,
				A.UtcCreatedDate
			FROM
				mill.METCALF_THICKENER_OPERATOR_FORM_V A
			WHERE
				A.UtcCreatedDate < @UtcShiftStartDateTime AND
				SiteCode = @SiteCode
			ORDER BY
				A.UtcCreatedDate DESC

			UNION ALL

			SELECT TOP 1
				B.TransactionId,
				B.UtcCreatedDate
			FROM
				[mill].[METCALF_THICKENER_DENSITY_SOLIDS_FORM_V] B
			WHERE
				B.UtcCreatedDate < @UtcShiftStartDateTime AND
				SiteCode = @SiteCode
			ORDER BY
				B.UtcCreatedDate DESC
		) R
	
	),
	Rounds AS (
		SELECT * 
		FROM Round0LatestMark
		WHERE IsRound0 = 1

		UNION ALL

		SELECT
			A.TransactionId,
			A.UtcCreatedDate,
			0 AS IsRound0
		FROM
			mill.METCALF_THICKENER_OPERATOR_FORM_V A
		WHERE
			A.UtcCreatedDate >= @UtcShiftStartDateTime AND 
			A.UtcCreatedDate < @UtcShiftEndDateTime AND
			A.SiteCode = @SiteCode

		UNION ALL

		SELECT
			B.TransactionId,
			B.UtcCreatedDate,
			0 AS IsRound0
		FROM
			[mill].[METCALF_THICKENER_DENSITY_SOLIDS_FORM_V] B
		WHERE
			B.UtcCreatedDate >= @UtcShiftStartDateTime AND 
			B.UtcCreatedDate < @UtcShiftEndDateTime AND
			B.SiteCode = @SiteCode
	)
	SELECT
		*
	FROM 
		Rounds
	ORDER BY
		IsRound0 DESC, UtcCreatedDate ASC
	

SET NOCOUNT OFF
END


