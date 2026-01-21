







/******************************************************************  
* PROCEDURE	: dbo.Logbook_Task_Job_Update
* PURPOSE	: 
* NOTES		: 
* CREATED	: sxavier, 22 Apr 2025
* SAMPLE	: 

	EXEC Logbook_Task_Job_Update 

* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {22 Apr 2025}		{sxavier}		{Initial Created}
*******************************************************************/ 
CREATE PROCEDURE [dbo].[LogbookTaskJob_Update] 
(	
	@Id INT,
	@Status VARCHAR(1),
	@Error VARCHAR(MAX),
	@Result VARCHAR(MAX),
	@Payload VARCHAR(MAX)
)
AS                        
BEGIN          
	SET NOCOUNT ON
	SET XACT_ABORT ON

		BEGIN TRANSACTION

		UPDATE
			dbo.LOGBOOK_TASK_JOB
		SET
			[Status] = @Status,
			Error = @Error,
			Result = @Result
		WHERE
			Id = @Id

		COMMIT TRANSACTION

	SET NOCOUNT OFF
END

