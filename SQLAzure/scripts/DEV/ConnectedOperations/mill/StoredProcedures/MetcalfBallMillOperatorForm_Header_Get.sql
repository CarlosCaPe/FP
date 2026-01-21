







/******************************************************************  
* PROCEDURE	: mill.[MetcalfBallMillOperatorForm_Header_Get]
* PURPOSE	: 
* NOTES		: 
* CREATED	: sxavier
* SAMPLE	: 
	1. EXEC [mill].[MetcalfBallMillOperatorForm_Header_Get] 'MOR', 'NEXT'

* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {14 Oct 2024}		{sxavier}		{Initial Created}
* {11 Dec 2024}		{sxavier}		{Fix logic to get from UtcCreatedDate}
*******************************************************************/ 
CREATE PROCEDURE [mill].[MetcalfBallMillOperatorForm_Header_Get]
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
	Rounds AS (
		SELECT *
		FROM (
			SELECT TOP 1
				A.TransactionId,
				A.UtcCreatedDate,
				1 AS IsRound0
			FROM
				mill.METCALF_BALL_MILL_OPERATOR_FORM_V A
			WHERE
				A.UtcCreatedDate < @UtcShiftStartDateTime AND
				SiteCode = @SiteCode
			ORDER BY
				A.UtcCreatedDate DESC
		) Rounds

		UNION ALL

		SELECT
			A.TransactionId,
			A.UtcCreatedDate,
			0 AS IsRound0
		FROM
			mill.METCALF_BALL_MILL_OPERATOR_FORM_V A
		WHERE
			A.UtcCreatedDate >= @UtcShiftStartDateTime AND 
			A.UtcCreatedDate < @UtcShiftEndDateTime AND
			A.SiteCode = @SiteCode
	)
	SELECT
		*
	FROM 
		Rounds
	ORDER BY
		IsRound0 DESC, UtcCreatedDate ASC
	

SET NOCOUNT OFF
END


