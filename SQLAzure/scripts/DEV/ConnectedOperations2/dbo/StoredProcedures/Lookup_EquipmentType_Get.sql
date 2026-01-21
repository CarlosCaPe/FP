




/******************************************************************  
* PROCEDURE	: dbo.Lookup_EquipmentType_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: sxavier, 07 Aug 2023
* SAMPLE	: 
	1. EXEC dbo.Lookup_EquipmentType_Get 'EN'

* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {07 Aug 2023}		{sxavier}		{Initial Created}
* {7 Aug 2023}		{ywibowo}		{Code review}
*******************************************************************/ 
CREATE PROCEDURE [dbo].[Lookup_EquipmentType_Get] 
(	
	@LanguageCode CHAR(2)
)
AS                        
BEGIN          
SET NOCOUNT ON

	SELECT
		TableCode,
		[Value]
	FROM 
		dbo.CONOPS_LOOKUPS_V
	WHERE 
		LanguageCode = @LanguageCode AND 
		TableType = 'EQMT' AND
		IsActive = 1
	ORDER BY
		[Value]

SET NOCOUNT OFF
END


