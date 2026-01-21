



/******************************************************************  
* PROCEDURE	: dbo.FLS_InsertLookups
* PURPOSE	: 
* NOTES		: 
* CREATED	: sxavier, 17 Apr 2023
* SAMPLE	: 
	1. EXEC dbo.FLS_InsertLookups 'ST01', 'APPR', 'Approved', 'Data Approved', '0000000005'
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {17 Apr 2023}		{sxavier}		{Initial Created} 
*******************************************************************/ 
CREATE PROCEDURE [dbo].[FLS_InsertLookups] 
(	
	@TableType CHAR(4),
	@TableCode CHAR(8),
	@Value VARCHAR(MAX),
	@Descriptions VARCHAR(MAX),
	@CreatedBy CHAR(10)
)
AS                        
BEGIN    
	
	SET NOCOUNT ON

	INSERT INTO dbo.FLS_Lookups
	(
		TableType,
		TableCode,
		[Value],
		Descriptions,
		CreatedBy,
		UtcCreatedDate,
		LastModifiedBy,
		UtcLastModifiedDate
	)
	VALUES
	(
		@TableType,
		@TableCode,
		@Value,
		@Descriptions,
		@CreatedBy,
		GETUTCDATE(),
		@CreatedBy,
		GETUTCDATE()
	)
		
	SET NOCOUNT OFF

END

