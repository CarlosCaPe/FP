CREATE VIEW [mill].[METCALF_SECONDARY_CRUSHER_INSPECTION_FORM_V] AS



/******************************************************************  
* VIEW	    : mill.METCALF_SECONDARY_CRUSHER_INSPECTION_FORM_V
* PURPOSE	: 
* NOTES		: 
* CREATED	: sxavier, 15 Nov 2024
* SAMPLE	: 
	1. SELECT * FROM mill.METCALF_SECONDARY_CRUSHER_INSPECTION_FORM_V
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {15 Nov 2024}		{sxavier}		{Initial Created}
*******************************************************************/ 


CREATE VIEW [mill].[METCALF_SECONDARY_CRUSHER_INSPECTION_FORM_V]
AS
	SELECT
		A.TransactionId,
		A.SiteCode,
		A.TransactionDate,
		A.ShiftId,
		A.RawData,
		A.AreaId,
		A.ApronFeeder501,
		A.ApronFeeder601,
		A.ApronFeeder701,
		A.ScreenFeeder2120,
		A.ScreenFeeder2125,
		A.Screen2140,
		A.Screen2145,
		A.SecondaryCrusher1,
		A.SecondaryCrusher2,
		A.SecondaryCrusherMetalToMetal1,
		A.SecondaryCrusherMetalToMetal2,
		A.CrusherFeeder2190,
		A.CrusherFeeder2195,
		A.B5Tripper,
		A.ChuteCheck,
		A.R11Conveyor,
		A.R1BConveyor,
		A.R2Conveyor,
		A.B1Conveyor,
		A.B2Conveyor,
		A.B3Conveyor,
		A.B4Conveyor,
		A.B5Conveyor,
		A.InspectionComment,
		A.CreatedBy,
		A.UtcCreatedDate,
		A.ModifiedBy,
		A.UtcModifiedDate
	FROM mill.MetcalfSecondaryCrusherInspectionForm A (NOLOCK)

