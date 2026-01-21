








/******************************************************************  
* PROCEDURE	: dbo.LogbookTaskJob_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: sxavier, 22 Apr 2025
* SAMPLE	: 

	EXEC LogbookTaskJob_Get 

* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {22 Apr 2025}		{sxavier}		{Initial Created}
*******************************************************************/ 
CREATE PROCEDURE [dbo].[LogbookTaskJob_Get] 
(	
	@LogbookId INT = NULL,
	@Status VARCHAR(1) = NULL
)
AS                        
BEGIN          
	SET NOCOUNT ON
		
		SELECT
			Id,
			LogbookId,
			[Status],
			Error,
			Result,
			Payload
		FROM
			dbo.LOGBOOK_TASK_JOB
		WHERE
			(@LogbookId IS NULL OR LogbookId = @LogbookId) AND
			(@Status IS NULL OR [Status] = @Status)


	SET NOCOUNT OFF
END

