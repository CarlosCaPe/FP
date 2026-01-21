




/******************************************************************  
* PROCEDURE	: dbo.Card_Detail_Delete
* PURPOSE	: 
* NOTES		: 
* CREATED	: sxavier, 22 Dec 2023
* SAMPLE	: 
	1. EXEC dbo.Card_Detail_Delete

* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {22 Dec 2023}		{sxavier}		{Initial Created}
* {26 Dec 2023}		{ywibowo}		{Code review}
*******************************************************************/ 
CREATE PROCEDURE [dbo].[Card_Detail_Delete] 
(	
	@Id INT
)
AS                        
BEGIN          
	SET NOCOUNT ON
	SET XACT_ABORT ON

		DELETE FROM 
			dbo.CARD_DETAIL
		WHERE
			Id = @Id

	SET NOCOUNT OFF
END
