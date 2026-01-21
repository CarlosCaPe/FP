


/******************************************************************  
* PROCEDURE	: dbo.Lookup_Task_Area_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: sxavier, 17 Apr 2025
* SAMPLE	: 
	1. EXEC dbo.Lookup_Task_Area_Get 'EN', 'MO', '', '', ''
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {17 Apr 2025}		{sxavier}		{Initial Created}
*******************************************************************/ 
CREATE PROCEDURE [dbo].[Lookup_Task_Area_Get] 
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
		SiteCode = @SiteCode AND
		ProcessId = @ProcessId AND
		SubProcessId = @SubProcessId AND
		TableType = 'TSAR' AND
		IsActive = 1

SET NOCOUNT OFF
END

