/******************************************************************  
* PROCEDURE	: mill.Sites_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: pananda, 11 Sep 2024
* SAMPLE	: 
	1. EXEC mill.Sites_Get
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {17 Sep 2024}		{pananda}		{Initial Created}
*******************************************************************/ 
CREATE   PROCEDURE [mill].[Sites_Get]
AS                        
BEGIN    
	SELECT 
		S.SiteCode,
		S.SiteName,
		S.IsEnabled
	FROM 
		[mill].[Sites] S
	ORDER BY 
		S.SiteName
END
