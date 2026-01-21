


/****************************************************************************  
* PROCEDURE	: dbo.Logbook_Update
* PURPOSE	: 
* NOTES		: 
* CREATED	: elbert, 26 June 2023
* SAMPLE	: 
	1. 
		DECLARE @Attachments AS dbo.LogbookAttachmentList
		INSERT INTO @Attachments VALUES 
			('test 3.png', 'https://conops-services/test3.png', 267), 
			('test 5.png', 'https://conops-services/test3.png', 266), 
			('test 6.png', 'https://conops-services/test3.png', 266)
		DECLARE @LogbookList AS dbo.LogbookList
		INSERT INTO @LogbookList VALUES 
			(267, 'Equipment Med 3', 'Equipment Med 3', '1', '3', '0060092257', 'ACC1223', '2023-08-13 15:00:22.753', 0, NULL), 
			(267, 'Equipment Med', 'Equipment Med', '1', '0', '0060092257', 'ACC1223', '2023-08-13 15:00:22.753', 0, NULL)
		EXEC dbo.Logbook_Update @LogbookList, @Attachments, '0060092257'

* MODIFIED DATE     AUTHOR			DESCRIPTION  
*----------------------------------------------------------------------------  
* {26 Jun 2023}		{elbert}		{Initial Created}
* {07 Jul 2023}		{sxavier}		{Refactor query}
* {07 Jul 2023}		{ywibowo}		{Code Review}
* {11 Jul 2023}		{pananda}		{Add support to delete logbook photo}
* {05 Sep 2023}		{sxavier}		{Support new adjustment on logbook}
* {02 Oct 2023}		{sxavier}		{Support ConOps Logbook}
* {03 Oct 2023}		{ywibowo}		{Code Review}
* {17 Apr 2025}		{sxavier}		{Adjust new logbook}
* {28 Apr 2025}		{elbert}		{add assignTo & duedate}
*****************************************************************************/ 
CREATE PROCEDURE [dbo].[Logbook_Update] 
(
	@LogbookList AS dbo.LogbookListNew READONLY,
	@Attachments AS dbo.LogbookAttachmentList READONLY,
	@User CHAR(10)
)
AS                        
BEGIN          
	SET NOCOUNT ON
	SET XACT_ABORT ON
		
		BEGIN TRANSACTION

		UPDATE
			LogbookTable
		SET
			ShiftId = LogbookList.ShiftId,
			Title = LogbookList.Title,
			[Description] = LogbookList.[Description],
			ImportanceCode = LogbookList.Importance,
			AreaCode = LogbookList.Area,
			EmployeeId = ISNULL(LogbookList.AsigneeEmployeeId, ''),
			ExtendedProperty1 = LogbookList.ExtendedProperty1,
			ExtendedProperty2 = LogbookList.ExtendedProperty2,
			ExtendedProperty3 = LogbookList.ExtendedProperty3,
			ExtendedProperties = LogbookList.ExtendedProperties,
			ModifiedBy = @User,
			UtcModifiedDate = GETUTCDATE(),
			AssignedTo=LogbookList.AssignTo,
			DueDate=LogbookList.DueDate,
			TaskAreaCode = LogbookList.TaskAreaCode 
		FROM
			dbo.LOGBOOK LogbookTable
			INNER JOIN @LogbookList LogbookList ON LogbookTable.Id = LogbookList.Id

		DELETE FROM
			dbo.LOGBOOK_ATTACHMENTS
		WHERE
			LogbookId IN (SELECT Id FROM @LogbookList)

		INSERT INTO dbo.LOGBOOK_ATTACHMENTS
		(
			LogbookId,
			Title,
			AttachmentUrl,
			CreatedBy,
			UtcCreatedDate,
			ModifiedBy,
			UtcModifiedDate
		)
		SELECT
			LogbookId,
			Title,
			AttachmentUrl,
			@User,
			GETUTCDATE(),
			@User,
			GETUTCDATE()
		FROM
			@Attachments

		INSERT INTO dbo.LOGBOOK_TASK_JOB
			(
				LogbookId,
				[Status],
				[Error],
				[Result],
				[Payload]
			)
		SELECT Id LogbookId,'O','','','' FROM @LogbookList WHERE AssignTo is not null and AssignTo<>''

		SELECT Id JobId, LogbookId FROM dbo.LOGBOOK_TASK_JOB where LogbookId in(SELECT Id  FROM @LogbookList WHERE AssignTo is not null and AssignTo<>'') and [Status]='O'
		COMMIT TRANSACTION

	SET NOCOUNT OFF
END

SELECT NEWID()