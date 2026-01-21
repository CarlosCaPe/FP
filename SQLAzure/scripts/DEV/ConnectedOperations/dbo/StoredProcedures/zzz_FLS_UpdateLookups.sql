





/******************************************************************  
* PROCEDURE	: dbo.FLS_UpdateLookups
* PURPOSE	: 
* NOTES		: 
* CREATED	: sxavier, 17 Apr 2023
* SAMPLE	: 
	1. EXEC dbo.FLS_UpdateLookups 'ST01', 'APPR', 'Approve', 'Data Approved 1', '0000000005'
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {17 Apr 2023}		{sxavier}		{Initial Created} 
*******************************************************************/ 
CREATE PROCEDURE [dbo].[FLS_UpdateLookups] 
(	
	@TableType CHAR(4),
	@TableCode CHAR(8),
	@Value VARCHAR(MAX),
	@Descriptions VARCHAR(MAX),
	@ModifiedBy CHAR(10)
)
AS                        
BEGIN    
	
	SET NOCOUNT ON
	
	UPDATE 
		dbo.FLS_Lookups
	SET
		[Value] = @Value,
		Descriptions = @Descriptions,
		LastModifiedBy = @ModifiedBy,
		UtcLastModifiedDate = GETUTCDATE()
	WHERE
		TableType = @TableType
		AND TableCode = @TableCode

	SET NOCOUNT OFF

END

