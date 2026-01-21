




/******************************************************************  
* PROCEDURE	: dbo.CardsHeader_Add
* PURPOSE	: 
* NOTES		: 
* CREATED	: sxavier, 26 Jan 2024
* SAMPLE	: 
	1. EXEC dbo.CardsHeader_Add 1, 'EN', 'Total Material Delivered', 'Display mmaterial delivered', '', '0060092257'

* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {26 Jan 2024}		{sxavier}		{Initial Created}
* {29 Jan 2024}		{ywibowo}		{Code review}
*******************************************************************/ 
CREATE PROCEDURE [dbo].[CardsHeader_Add] 
(	
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

		INSERT INTO dbo.CARDS_HEADER
		(	
			CardId,
			LanguageCode,
			CardTitle,
			CardDescription,
			Notes,
			CreatedBy,
			UtcCreatedDate,
			ModifiedBy,
			UtcModifiedDate
		)
		VALUES			
		( 				
			@CardId,
			@LanguageCode,
			@CardTitle,
			@CardDescription,
			@Notes,
			@UserId,
			GETUTCDATE(),
			@UserId,
			GETUTCDATE()
		)

	SET NOCOUNT OFF
END
