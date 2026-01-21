CREATE VIEW [mill].[METCALF_THICKENER_DENSITY_SOLIDS_FORM_V] AS























/******************************************************************  
* VIEW	    : [mill].[METCALF_THICKENER_DENSITY_SOLIDS_FORM_V]
* PURPOSE	: 
* NOTES		: 
* CREATED	: aarivian, 26 Feb 2025
* SAMPLE	: 
	1. SELECT * FROM [mill].[METCALF_THICKENER_DENSITY_SOLIDS_FORM_V]
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {26 Feb 2025}		{aarivian}		{Initial Created}
*******************************************************************/ 


CREATE VIEW [mill].[METCALF_THICKENER_DENSITY_SOLIDS_FORM_V]
AS
	SELECT
		TransactionId,
		SiteCode,
		TransactionDate,
		ShiftId,
		RawData,
		DensitySolids,
		InspectionComment,
		CreatedBy,
		UtcCreatedDate,
		ModifiedBy,
		UtcModifiedDate
  FROM [mill].[MetcalfThickenerDensitySolidsForm] (NOLOCK)

