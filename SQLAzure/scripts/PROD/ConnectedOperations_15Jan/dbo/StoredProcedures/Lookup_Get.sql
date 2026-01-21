



/******************************************************************  
* PROCEDURE	: dbo.Lookup_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: sxavier, 21 Dec 2023
* SAMPLE	: 
	1. EXEC dbo.Lookup_Get 'MODL'

* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {21 Dec 2023}		{sxavier}		{Initial Created}
* {26 Dec 2023}		{ywibowo}		{Code review}
*******************************************************************/ 
CREATE PROCEDURE [dbo].[Lookup_Get] 
(	
	@Type VARCHAR(4) = NULL,
	@Code VARCHAR(8) = NULL,
	@LanguageCode VARCHAR(2) = NULL
)
AS                        
BEGIN          
SET NOCOUNT ON

	SELECT
		TableCode,
		TableType,
		LanguageCode,
		[Value],
		[Description]
	FROM 
		dbo.CONOPS_LOOKUPS_V
	WHERE 
		TableType LIKE ISNULL(@Type, '%') AND
		TableCode LIKE ISNULL(@Code, '%') AND
		LanguageCode LIKE ISNULL(@LanguageCode, '%') AND 
		IsActive = 1
	ORDER BY
		[Value]

SET NOCOUNT OFF
END


