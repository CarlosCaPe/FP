



/****************************************************************************  
* PROCEDURE	: dbo.ConOpsLogbook_Update
* PURPOSE	: 
* NOTES		: 
* CREATED	: sxavier, 05 Sep 2023
* SAMPLE	: 
	1. 
		DECLARE @Attachments AS dbo.LogbookAttachmentList
		INSERT INTO @Attachments VALUES ('test 3.png', 'https://conops-services/test3.png'), ('test 4.png', 'https://conops-services/test4.png')
		EXEC dbo.ConOpsLogbook_Update 245, 'Test Sam 3', 'Test Sam 3', 'AA1223', '2023-08-13 15:00:22.753', '0', '1', '0060092257', @Attachments, '0060092257'

* MODIFIED DATE     AUTHOR			DESCRIPTION  
*----------------------------------------------------------------------------  
* {05 Sep 2023}		{sxavier}		{Initial Created}
*****************************************************************************/ 
CREATE PROCEDURE [dbo].[zzz_ConOpsLogbook_Update] 
(
	@Id INT,
	@Title NVARCHAR(512),
	@Comment NVARCHAR(MAX),
	@Location NVARCHAR(512),
	@DueDate DATETIME,
	@Category VARCHAR(8),
	@Priority VARCHAR(8),
	@AsigneeEmployeeId NVARCHAR(512),
	--@Attachments AS dbo.LogbookAttachmentList READONLY,
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
			Title = @Title,
			[Description] = @Comment,
			AreaCode = @Category,
			ImportanceCode = @Priority,
			ExtendedProperty1 = @Location,
			ExtendedProperty2 = CONVERT(VARCHAR(30), @DueDate, 121),
			ExtendedProperty3 = @AsigneeEmployeeId,
			OrderByAreaCreatedDate = CONCAT(@Category, CONVERT(VARCHAR(30), UtcCreatedDate, 121)),
			OrderByImportanceCreatedDate = CONCAT(@Priority, CONVERT(VARCHAR(30), UtcCreatedDate, 121)),
			ModifiedBy = @User,
			UtcModifiedDate = GETUTCDATE()
		WHERE 
			Id = @Id

		DELETE FROM
			dbo.LOGBOOK_ATTACHMENTS
		WHERE
			LogbookId = @Id

		--IF EXISTS (SELECT TOP 1 * FROM @Attachments)
		--BEGIN
		--	INSERT INTO dbo.LOGBOOK_ATTACHMENTS
		--	(
		--		LogbookId,
		--		Title,
		--		AttachmentUrl,
		--		CreatedBy,
		--		UtcCreatedDate,
		--		ModifiedBy,
		--		UtcModifiedDate
		--	)
		--	SELECT
		--		@Id,
		--		Title,
		--		AttachmentUrl,
		--		@User,
		--		GETUTCDATE(),
		--		@User,
		--		GETUTCDATE()
		--	FROM
		--		@Attachments
		--END

		COMMIT TRANSACTION

	SET NOCOUNT OFF
END

