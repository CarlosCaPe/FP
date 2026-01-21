



/******************************************************************  
* PROCEDURE	: dbo.Card_Detail_Add
* PURPOSE	: 
* NOTES		: 
* CREATED	: sxavier, 21 Dec 2023
* SAMPLE	: 
	1. EXEC dbo.Card_Detail_Add 1, 1, 'MOR', 'EN', 'Display material mined by shovel bar chart', 'ground', 'LoahAndHaul_TotalMaterialMined','', '0060092257'

* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {21 Dec 2023}		{sxavier}		{Initial Created}
* {26 Dec 2023}		{ywibowo}		{Code review}
* {03 Jan 2024}		{sxavier}		{Add moduleId}
*******************************************************************/ 
CREATE PROCEDURE [dbo].[Card_Detail_Add] 
(	
	@CardHeaderId CHAR(1),
	@ModuleId VARCHAR(8),
	@SiteCode CHAR(3),
	@LanguageCode CHAR(2),
	@CardDescription NVARCHAR(MAX),
	@SourceDataLocation NVARCHAR(512),
	@QueryName NVARCHAR(512),
	@Notes NVARCHAR(MAX),
	@UserId CHAR(10)
)
AS                        
BEGIN          
	SET NOCOUNT ON
	SET XACT_ABORT ON

		INSERT INTO dbo.CARD_DETAIL
		(	
			CardHeaderId,
			ModuleId,
			SiteCode,
			LanguageCode,
			CardDescription,
			SourceDataLocation,
			QueryName,
			Notes,
			CreatedBy,
			UtcCreatedDate,
			ModifiedBy,
			UtcModifiedDate
		)
		VALUES			
		( 				
			@CardHeaderId,
			@ModuleId,
			@SiteCode,
			@LanguageCode,
			@CardDescription,
			@SourceDataLocation,
			@QueryName,
			@Notes,
			@UserId,
			GETUTCDATE(),
			@UserId,
			GETUTCDATE()
		)

	SET NOCOUNT OFF
END
