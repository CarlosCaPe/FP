


/******************************************************************  
* PROCEDURE	: dbo.[Lookup_Category_Get] 
* PURPOSE	: 
* NOTES		: 
* CREATED	: npratama 8 may 2025
* SAMPLE	: 
	1. EXEC dbo.Lookup_Category_Get 'EN', 'MO', 'MOR', 'CON', 'MCF'
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {8 May 2025}		{npratama}		{Initial Created}
*******************************************************************/ 
CREATE PROCEDURE [dbo].[Lookup_Category_Get] 
(	
	@LanguageCode CHAR(2),
	@LogbookType CHAR(2),
	@SiteCode VARCHAR(3) = '',
	@ProcessId VARCHAR(3) = '',
	@SubProcessId VARCHAR(3) = ''
)
AS                        
BEGIN          
SET NOCOUNT ON

	SELECT
		TableCode,
		[Description]
	FROM 
		dbo.CONOPS_LOGBOOK_LOOKUPS_V
	WHERE 
		LanguageCode = @LanguageCode AND 
		LogbookType = @LogbookType AND
		SiteCode = CASE WHEN @SiteCode = '' THEN CASE WHEN @LogbookType = 'MO' THEN 'MOR'  ELSE '' END ELSE @SiteCode END AND -- CASE WHEN used to support backward compatible 
		ProcessId = CASE WHEN @ProcessId = '' THEN CASE WHEN @LogbookType = 'MO' THEN 'CON'  ELSE '' END ELSE @ProcessId END AND -- CASE WHEN used to support backward compatible 
		SubProcessId = CASE WHEN @SubProcessId = '' THEN CASE WHEN @LogbookType = 'MO' THEN 'MOR'  ELSE '' END ELSE @SubProcessId END AND -- CASE WHEN used to support backward compatible 
		TableType = 'CTGY' AND
		IsActive = 1

SET NOCOUNT OFF
END


