



/******************************************************************  
* PROCEDURE	: dbo.ConOpsLogbook_Delete
* PURPOSE	: 
* NOTES		: 
* CREATED	: sxavier, 05 Sep 2023
* SAMPLE	: 
	1. EXEC dbo.ConOpsLogbook_Delete 244

* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {05 Sep 2023}		{sxavier}		{Initial Created}
*******************************************************************/ 
CREATE PROCEDURE [dbo].[ConOpsLogbook_Delete] 
(	
	@Id INT
)
AS                        
BEGIN          
	SET NOCOUNT ON
	SET XACT_ABORT ON
		
		BEGIN TRANSACTION

		DELETE FROM 
			dbo.LOGBOOK_ATTACHMENTS
		WHERE 
			LogbookId = @Id

		DELETE FROM 
			dbo.LOGBOOK 
		WHERE 
			Id = @Id

		COMMIT TRANSACTION

	SET NOCOUNT OFF
END

