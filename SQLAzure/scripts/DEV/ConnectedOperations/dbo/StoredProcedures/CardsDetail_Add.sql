



/******************************************************************  
* PROCEDURE	: dbo.CardsDetail_Add
* PURPOSE	: 
* NOTES		: 
* CREATED	: sxavier, 21 Dec 2023
* SAMPLE	: 
	1. EXEC dbo.CardsDetail_Add 1, 'MOR', 'Sharepoint A', 'Total_Get', '', '0060092257'

* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {21 Dec 2023}		{sxavier}		{Initial Created}
* {26 Dec 2023}		{ywibowo}		{Code review}
* {03 Jan 2024}		{sxavier}		{Add moduleId}
* {26 Jan 2024}		{sxavier}		{Support new design}
* {29 Jan 2024}		{ywibowo}		{Code review}
*******************************************************************/ 
CREATE PROCEDURE [dbo].[CardsDetail_Add] 
(	
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

		INSERT INTO dbo.CARDS_DETAIL
		(	
			CardId,
			SiteCode,
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
			@CardId,
			@SiteCode,
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
