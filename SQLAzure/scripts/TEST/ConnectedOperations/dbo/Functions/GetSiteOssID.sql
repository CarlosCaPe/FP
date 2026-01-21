

/******************************************************************    
* FUNCTION : dbo.GetSiteOssID  
* PURPOSE : To get OSS Site ID 
* NOTES  :  
* CREATED : ggosal1, 06 Jan 2025
* SAMPLE :   
 1. SELECT dbo.GetSiteOssID('CER')
   
* MODIFIED DATE     AUTHOR   DESCRIPTION    
*------------------------------------------------------------------    
* {06 Jan 2025}  {ggosal1}  {Initial Created}   
*******************************************************************/   

CREATE FUNCTION [dbo].[GetSiteOssID] (@SITE VARCHAR(3))
RETURNS VARCHAR(3)
AS
BEGIN

	SET @SITE = ISNULL((SELECT OssID FROM dbo.SITE_LOOKUPS WHERE SiteID = @SITE), @SITE);
	
	RETURN @SITE;

END;
