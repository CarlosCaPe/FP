





/******************************************************************  
* PROCEDURE	: dbo.CardsDetail_Update
* PURPOSE	: 
* NOTES		: 
* CREATED	: sxavier, 22 Dec 2023
* SAMPLE	: 
	1. EXEC dbo.CardsDetail_Update 1, 1, 'CVE', 'grounds', 'LH_Overview_Mined', '', '0060092257'

* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {22 Dec 2023}		{sxavier}		{Initial Created}
* {26 Dec 2023}		{ywibowo}		{Code review}
* {03 Jan 2024}		{sxavier}		{Add moduleId}
* {26 Jan 2024}		{sxavier}		{Support new design}
* {29 Jan 2024}		{ywibowo}		{Code review}
*******************************************************************/ 
CREATE PROCEDURE [dbo].[CardsDetail_Update] 
(	
	@Id INT,
	@CardId INT,
	@SiteCode CHAR(3),
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
			dbo.CARDS_DETAIL
		SET
			CardId = @CardId,
			SiteCode = @SiteCode,
			SourceDataLocation = @SourceDataLocation,
			QueryName = @QueryName,
			Notes = @Notes,
			ModifiedBy = @UserId,
			UtcModifiedDate = GETUTCDATE()
		WHERE
			Id = @Id

	SET NOCOUNT OFF
END
