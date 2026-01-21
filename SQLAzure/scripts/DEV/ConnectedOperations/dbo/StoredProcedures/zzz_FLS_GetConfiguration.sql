








/******************************************************************  
* PROCEDURE	: dbo.FLS_GetConfiguration
* PURPOSE	: 
* NOTES		: 
* CREATED	: sxavier, 18 Apr 2023
* SAMPLE	: 
	1. EXEC dbo.FLS_GetConfiguration
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {26 Apr 2023}		{sxavier}		{Initial Created} 
*******************************************************************/ 
CREATE PROCEDURE [dbo].[FLS_GetConfiguration] 
AS                        
BEGIN    
	
	SET NOCOUNT ON

	SELECT
		TableType,
		TableCode,
		[Value]
	FROM 
		dbo.FLS_ViewLookups (NOLOCK)
	WHERE
		TableType = 'CONF'

	SET NOCOUNT OFF

END

