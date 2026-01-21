





/******************************************************************  
* PROCEDURE	: dbo.CardsHeader_Update
* PURPOSE	: 
* NOTES		: 
* CREATED	: sxavier, 26 Jan 2024
* SAMPLE	: 
	1. EXEC dbo.CardsHeader_Update 1, 1, 'ES', 'Total Material Moved 2', 'Material moved 2', '', '0060092257'

* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {26 Jan 2024}		{sxavier}		{Initial Created}
* {29 Jan 2024}		{ywibowo}		{Code review}
*******************************************************************/ 
CREATE PROCEDURE [dbo].[CardsHeader_Update] 
(	
	@Id INT,
	@CardId INT,
	@LanguageCode CHAR(2),
	@CardTitle VARCHAR(128),
	@CardDescription NVARCHAR(MAX),
	@Notes NVARCHAR(MAX),
	@UserId CHAR(10)
)
AS                        
BEGIN          
	SET NOCOUNT ON
	SET XACT_ABORT ON

		UPDATE
			dbo.CARDS_HEADER
		SET
			CardId = @CardId,
			LanguageCode = @LanguageCode,
			CardTitle = @CardTitle,
			CardDescription = @CardDescription,
			Notes = @Notes,
			ModifiedBy = @UserId,
			UtcModifiedDate = GETUTCDATE()
		WHERE
			Id = @Id

	SET NOCOUNT OFF
END
