







/******************************************************************  
* PROCEDURE	: dbo.Logbook_Task_Update
* PURPOSE	: 
* NOTES		: 
* CREATED	: sxavier, 22 Apr 2025
* SAMPLE	: 

	EXEC Logbook_Task_Update 726, '29BC4D5B-7919-4BC0-B616-95E92F7C3B21', 'C6AA365B-AE90-4D11-A93F-08BC7037510B', '0000000000', '2025-04-22 04:26:12.903', 'N', 'Open', '', '0000000000' 

* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {22 Apr 2025}		{sxavier}		{Initial Created}
*******************************************************************/ 
CREATE PROCEDURE [dbo].[Logbook_TaskUpdate] 
(	
	@LogbookId INT = NULL,
	@EwsTaskId UNIQUEIDENTIFIER,
	@EwsTransactionId INT,
	@AssignTo CHAR(10),
	@DueDate DATETIME,
	@TaskStatusCode VARCHAR(MAX),
	@TaskStatusDescription VARCHAR(MAX),
	@WorkOrder VARCHAR(MAX),
	@User CHAR(10)
)
AS                        
BEGIN          
	SET NOCOUNT ON
	SET XACT_ABORT ON

		BEGIN TRANSACTION

		UPDATE
			dbo.LOGBOOK
		SET
			EwsTaskId = @EwsTaskId,
			EwsTransactionId = @EwsTransactionId,
			AssignedTo = @AssignTo,
			DueDate = @DueDate,
			TaskStatusCode = @TaskStatusCode,
			TaskStatusDescription = @TaskStatusDescription,
			WorkOrder = @WorkOrder,
			ModifiedBy = @User,
			UtcModifiedDate = GETUTCDATE()
		WHERE
			Id = @LogbookId 
			 OR EwsTaskId=@EwsTaskId

		COMMIT TRANSACTION

	SET NOCOUNT OFF
END

