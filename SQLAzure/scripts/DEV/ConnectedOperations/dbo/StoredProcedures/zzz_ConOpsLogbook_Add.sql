





/******************************************************************  
* PROCEDURE	: dbo.ConOpsLogbook_Add
* PURPOSE	: 
* NOTES		: 
* CREATED	: sxavier, 05 Sep 2023
* SAMPLE	: 
	1. 
		DECLARE @Attachments AS dbo.LogbookAttachmentList
		INSERT INTO @Attachments VALUES ('test 1.png', 'https://conops-services/test1.png'), ('test 2.png', 'https://conops-services/test2.png')
		EXEC dbo.ConOpsLogbook_Add 'MOR', 'Test Sam 2', 'Test Sam 2', 'AB1223', '2023-08-11 02:47:45.753', '0', '2', '0060092257', @Attachments, '0060092257'

* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {05 Sep 2023}		{sxavier}		{Initial Created}
*******************************************************************/ 
CREATE PROCEDURE [dbo].[zzz_ConOpsLogbook_Add] 
(	
	@SiteCode CHAR(3),
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

		DECLARE @TempTable TABLE(Id INT)
		DECLARE @InsertedId INT, @ShiftId VARCHAR(16)
			
		IF @SiteCode = 'BAG'
		BEGIN
			SET @ShiftId = (SELECT ShiftId FROM bag.CONOPS_BAG_SHIFT_INFO_V WHERE SHIFTFLAG = 'CURR')
		END
		ELSE IF @SiteCode = 'CVE'
		BEGIN
			SET @ShiftId = (SELECT ShiftId FROM cer.CONOPS_CER_SHIFT_INFO_V WHERE SHIFTFLAG = 'CURR')
		END
		ELSE IF @SiteCode = 'CHN'
		BEGIN
			SET @ShiftId = (SELECT ShiftId FROM chi.CONOPS_CHI_SHIFT_INFO_V WHERE SHIFTFLAG = 'CURR')
		END
		ELSE IF @SiteCode = 'CMX'
		BEGIN
			SET @ShiftId = (SELECT ShiftId FROM cli.CONOPS_CLI_SHIFT_INFO_V WHERE SHIFTFLAG = 'CURR')
		END
		ELSE IF @SiteCode = 'MOR'
		BEGIN
			SET @ShiftId = (SELECT ShiftId FROM mor.CONOPS_MOR_SHIFT_INFO_V WHERE SHIFTFLAG = 'CURR')
		END
		ELSE IF @SiteCode = 'SAM'
		BEGIN
			SET @ShiftId = (SELECT ShiftId FROM saf.CONOPS_SAF_SHIFT_INFO_V WHERE SHIFTFLAG = 'CURR')
		END
		ELSE IF @SiteCode = 'SIE'
		BEGIN
			SET @ShiftId = (SELECT ShiftId FROM sie.CONOPS_SIE_SHIFT_INFO_V WHERE SHIFTFLAG = 'CURR')
		END

		INSERT INTO dbo.LOGBOOK
		(	
			SiteCode,
			ShiftId,
			Title,
			[Description],
			AreaCode,
			ImportanceCode,
			LogbookTypeCode,
			ExtendedProperty1, --Location
			ExtendedProperty2, --Due Date
			ExtendedProperty3, --Assignee Employee Id
			--ExtendedProperty4, --Is Added To EOS
			IsActive,
			OrderByAreaCreatedDate,
			OrderByImportanceCreatedDate,
			CreatedBy,
			UtcCreatedDate,
			ModifiedBy,
			UtcModifiedDate
		)
		OUTPUT inserted.Id INTO @TempTable
		VALUES			
		( 	
			@SiteCode,
			@ShiftId,
			@Title,
			@Comment,
			@Category,
			@Priority,
			'CO',
			@Location,
			CONVERT(VARCHAR(30), @DueDate, 121),
			@AsigneeEmployeeId,
			--'0',
			1,
			CONCAT(@Category, CONVERT(VARCHAR(30), GETUTCDATE(), 121)),
			CONCAT(@Priority, CONVERT(VARCHAR(30), GETUTCDATE(), 121)),
			@User,
			GETUTCDATE(),
			@User,
			GETUTCDATE()
		)

		SET @InsertedId = (SELECT Id FROM @TempTable)

		--INSERT INTO dbo.LOGBOOK_ATTACHMENTS
		--(
		--	LogbookId,
		--	Title,
		--	AttachmentUrl,
		--	CreatedBy,
		--	UtcCreatedDate,
		--	ModifiedBy,
		--	UtcModifiedDate
		--)
		--SELECT
		--	@InsertedId,
		--	Title,
		--	AttachmentUrl,
		--	@User,
		--	GETUTCDATE(),
		--	@User,
		--	GETUTCDATE()
		--FROM
		--	@Attachments

		COMMIT TRANSACTION

	SET NOCOUNT OFF
END

