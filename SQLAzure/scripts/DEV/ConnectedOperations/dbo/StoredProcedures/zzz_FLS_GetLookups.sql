




/******************************************************************  
* PROCEDURE	: dbo.FLS_GetLookups
* PURPOSE	: 
* NOTES		: 
* CREATED	: sxavier, 17 Apr 2023
* SAMPLE	: 
	1. EXEC dbo.FLS_GetLookups NULL, NULL
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {17 Apr 2023}		{sxavier}		{Initial Created} 
*******************************************************************/ 
CREATE PROCEDURE [dbo].[FLS_GetLookups] 
(	
	@TableType CHAR(4),
	@TableCode CHAR(8)
)
AS                        
BEGIN    
	
	SET NOCOUNT ON

	SELECT
		TableType,
		TableCode,
		[Value],
		Descriptions
	FROM 
		dbo.FLS_ViewLookups (NOLOCK)
	WHERE
		(@TableType IS NULL OR TableType = @TableType)
		AND (@TableCode IS NULL OR TableCode = @TableCode)
	
	SET NOCOUNT OFF

END

