CREATE VIEW [mill].[METCALF_BALL_MILL_OPERATOR_FORM_V] AS





















/******************************************************************  
* VIEW	    : mill.METCALF_BALL_MILL_OPERATOR_FORM_V
* PURPOSE	: 
* NOTES		: 
* CREATED	: sxavier, 7 Oct 2024
* SAMPLE	: 
	1. SELECT * FROM mill.METCALF_BALL_MILL_OPERATOR_FORM_V
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {14 Oct 2024}		{sxavier}		{Initial Created}
*******************************************************************/ 


CREATE VIEW [mill].[METCALF_BALL_MILL_OPERATOR_FORM_V]
AS
	SELECT
		A.TransactionId,
		A.SiteCode,
		A.TransactionDate,
		A.ShiftId,
		A.RawData,
		A.InspectionTimeId,
		A.CyclonePack1,
		A.CyclonePack2,
		A.Mill1,
		A.Mill2,
		A.B11A,
		A.B11B,
		A.B12,
		A.B13,
		A.B14,
		A.Valves,
		A.InspectionComment,
		A.CreatedBy,
		A.UtcCreatedDate,
		A.ModifiedBy,
		A.UtcModifiedDate
	FROM mill.MetcalfBallMillOperatorForm A (NOLOCK)

