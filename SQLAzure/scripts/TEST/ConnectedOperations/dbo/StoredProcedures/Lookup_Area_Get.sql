

/******************************************************************  
* PROCEDURE	: dbo.Lookup_Area_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: elbert, 26 June 2023
* SAMPLE	: 
	1. EXEC dbo.Lookup_Area_Get 'EN', 'MO', 'MOR', 'CON', 'MOR'
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {26 Jun 2023}		{elbert}		{Initial Created}
* {07 Jul 2023}		{sxavier}		{Refactor query}
* {07 Jul 2023}		{ywibowo}		{Code Review}
* {02 Oct 2023}		{sxavier}		{Select from logbook lookup}
* {23 Oct 2024}		{sxavier}		{Add SiteCode, ProcessId and SubProcessId}
*******************************************************************/ 
CREATE PROCEDURE [dbo].[Lookup_Area_Get] 
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
		TableType = 'AREA' AND
		IsActive = 1

SET NOCOUNT OFF
END


