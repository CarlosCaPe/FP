CREATE VIEW [mill].[METCALF_FLOTATION_OPERATION_INSPECTION_FORM_V] AS





/******************************************************************  
* VIEW	    : mill.METCALF_FLOTATION_OPERATION_INSPECTION_FORM_V
* PURPOSE	: 
* NOTES		: 
* CREATED	: sxavier, 11 Dec 2024
* SAMPLE	: 
	1. SELECT * FROM mill.METCALF_FLOTATION_OPERATION_INSPECTION_FORM_V
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {11 Dec 2024}		{sxavier}		{Initial Created}
*******************************************************************/ 


CREATE VIEW [mill].[METCALF_FLOTATION_OPERATION_INSPECTION_FORM_V]
AS
	SELECT
		A.TransactionId,
		A.SiteCode,
		A.TransactionDate,
		A.RawData,
		A.InspectionTimeId,
		A.InitialInspections,
		A.MediaSkips,
		A.DripPansCleaned,
		A.CoreMeasurements,
		A.Reagents,
		A.Column1AirSparger,
		A.Column2AirSparger,
		A.Column3AirSparger,
		A.Column4AirSparger,
		A.Column1StaticMixers,
		A.Column2StaticMixers,
		A.Column3StaticMixers,
		A.Column4StaticMixers,
		A.InspectionComment,
		A.CreatedBy,
		A.UtcCreatedDate,
		A.ModifiedBy,
		A.UtcModifiedDate
	FROM mill.MetcalfFlotationOperationInspectionForm A (NOLOCK)

