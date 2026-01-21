CREATE VIEW [mill].[METCALF_HRC_LIME_PLANT_INSPECTION_FORM_V] AS




/******************************************************************  
* VIEW	    : mill.METCALF_HRC_LIME_PLANT_INSPECTION_FORM_V
* PURPOSE	: 
* NOTES		: 
* CREATED	: sxavier, 11 Dec 2024
* SAMPLE	: 
	1. SELECT * FROM mill.METCALF_HRC_LIME_PLANT_INSPECTION_FORM_V
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {11 Dec 2024}		{sxavier}		{Initial Created}
*******************************************************************/ 


CREATE VIEW [mill].[METCALF_HRC_LIME_PLANT_INSPECTION_FORM_V]
AS
	SELECT
		A.TransactionId,
		A.SiteCode,
		A.TransactionDate,
		A.RawData,
		A.Hrc,
		A.LimePlant,
		A.DryFeeder,
		A.DryFeederDustCollectors,
		A.WetFeeders,
		A.B6Conveyor,
		A.B7Conveyor,
		A.B8AConveyor,
		A.B8BConveyor,
		A.B9Conveyor,
		A.B10Conveyor,
		A.InspectionComment,
		A.CreatedBy,
		A.UtcCreatedDate,
		A.ModifiedBy,
		A.UtcModifiedDate
	FROM mill.MetcalfHrcLimePlantInspectionForm A (NOLOCK)

