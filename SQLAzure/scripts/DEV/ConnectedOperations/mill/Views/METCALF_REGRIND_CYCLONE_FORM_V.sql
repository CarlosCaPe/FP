CREATE VIEW [mill].[METCALF_REGRIND_CYCLONE_FORM_V] AS






















/******************************************************************  
* VIEW	    : mill.METCALF_REGRIND_CYCLONE_FORM_V
* PURPOSE	: 
* NOTES		: 
* CREATED	: sxavier, 19 Dec 2024
* SAMPLE	: 
	1. SELECT * FROM mill.METCALF_REGRIND_CYCLONE_FORM_V
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {19 Dec 2024}		{sxavier}		{Initial Created}
*******************************************************************/ 


CREATE VIEW [mill].[METCALF_REGRIND_CYCLONE_FORM_V]
AS
	SELECT
		A.TransactionId,
		A.SiteCode,
		A.TransactionDate,
		A.RawData,
		A.RegrindCyclones,
		A.MediaSkips,
		A.Vertimills,
		A.InspectionComment,
		A.CreatedBy,
		A.UtcCreatedDate,
		A.ModifiedBy,
		A.UtcModifiedDate
	FROM mill.MetcalfRegrindCycloneForm A (NOLOCK)

