




/******************************************************************  
* PROCEDURE	: dbo.Card_Detail_Update
* PURPOSE	: 
* NOTES		: 
* CREATED	: sxavier, 22 Dec 2023
* SAMPLE	: 
	1. EXEC dbo.Card_Detail_Update 1, 1, 1, 'CVE', 'EN', 'Display bar chart', 'grounds', 'LH_Overview_Mined', '', '0060092257'

* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {22 Dec 2023}		{sxavier}		{Initial Created}
* {26 Dec 2023}		{ywibowo}		{Code review}
* {03 Jan 2024}		{sxavier}		{Add moduleId}
*******************************************************************/ 
CREATE PROCEDURE [dbo].[Card_Detail_Update] 
(	
	@Id INT,
	@CardHeaderId INT,
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

		UPDATE
			dbo.CARD_DETAIL
		SET
			CardHeaderId = @CardHeaderId,
			ModuleId = @ModuleId,
			SiteCode = @SiteCode,
			LanguageCode = @LanguageCode,
			CardDescription = @CardDescription,
			SourceDataLocation = @SourceDataLocation,
			QueryName = @QueryName,
			Notes = @Notes,
			ModifiedBy = @UserId,
			UtcModifiedDate = GETUTCDATE()
		WHERE
			Id = @Id

	SET NOCOUNT OFF
END
