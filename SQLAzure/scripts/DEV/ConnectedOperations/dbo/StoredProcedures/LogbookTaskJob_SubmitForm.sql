







/******************************************************************  
* PROCEDURE	: dbo.Logbook_Task_Update
* PURPOSE	: 
* NOTES		: 
* CREATED	: sxavier, 22 Apr 2025
* SAMPLE	: 

	EXEC LogbookTaskJob_SubmitForm 726, '29BC4D5B-7919-4BC0-B616-95E92F7C3B21', 'C6AA365B-AE90-4D11-A93F-08BC7037510B', '0000000000', '2025-04-22 04:26:12.903', 'N', 'Open', '', '0000000000' 

* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {22 Apr 2025}		{sxavier}		{Initial Created}
*******************************************************************/ 
CREATE PROCEDURE [dbo].[LogbookTaskJob_SubmitForm] 
(	
	@LogbookId INT,
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
	
	BEGIN TRY
        SET NOCOUNT ON
        SET XACT_ABORT ON

		BEGIN TRANSACTION

		DECLARE @JobId INT, @Payload VARCHAR(MAX); 
		SELECT @JobId = Id, @Payload = Payload FROM dbo.LOGBOOK_TASK_JOB WHERE LogbookId = @LogbookId

		EXEC Logbook_TaskUpdate @LogbookId, @EwsTaskId, @EwsTransactionId, @AssignTo, @DueDate, @TaskStatusCode, @TaskStatusDescription, @WorkOrder, @User

		EXEC LogbookTaskJob_Update @JobId, 'D', '', '', @Payload

		COMMIT TRANSACTION

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 AND XACT_STATE() <> 0 
            ROLLBACK TRAN;

        THROW
    END CATCH
END

