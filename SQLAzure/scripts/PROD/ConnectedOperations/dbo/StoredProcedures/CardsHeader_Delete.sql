





/******************************************************************  
* PROCEDURE	: dbo.CardsHeader_Delete
* PURPOSE	: 
* NOTES		: 
* CREATED	: sxavier, 26 Jan 2024
* SAMPLE	: 
	1. EXEC dbo.CardsHeader_Delete

* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {26 Jan 2024}		{sxavier}		{Initial Created}
* {29 Jan 2024}		{ywibowo}		{Code review}
*******************************************************************/ 
CREATE PROCEDURE [dbo].[CardsHeader_Delete] 
(	
	@Id INT
)
AS                        
BEGIN          
	SET NOCOUNT ON
	SET XACT_ABORT ON

		DELETE FROM 
			dbo.CARDS_HEADER
		WHERE
			Id = @Id

	SET NOCOUNT OFF
END
