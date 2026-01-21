






/******************************************************************  
* PROCEDURE	: dbo.Logbook_Add
* PURPOSE	: 
* NOTES		: 
* CREATED	: elbert, 26 June 2023
* SAMPLE	: 
	1. DECLARE @Attachments AS dbo.LogbookAttachmentList
		INSERT INTO @Attachments VALUES ('test 1.png', 'https://conops-services/test1.png', NULL), ('test 2.png', 'https://conops-services/test2.png', NULL)
		EXEC dbo.Logbook_Add 'CO', 'MOR', NULL, 'Equip C', 'Equip C', '0', '1', '0060092257', 'AAK445', '2023-10-13 02:47:45.753', '1' , @Attachments, '0060092257'

* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {26 Jun 2023}		{elbert}		{Initial Created}
* {07 Jul 2023}		{sxavier}		{Refactor query}
* {07 Jul 2023}		{ywibowo}		{Code Review}
* {14 Jul 2023}		{sxavier}		{Add isActive}
* {04 Aug 2023}		{sxavier}		{Add OrderByImportanceCreatedDate}
* {02 Oct 2023}		{sxavier}		{Support ConOps Logbook}
* {02 Oct 2023}		{ywibowo}		{Code Review}
* {21 Oct 2024}		{sxavier}		{Add ProcessId and SubProcessId}
* {28 Oct 2024}		{sxavier}		{Adjust MO to also save shiftId}
* {17 Apr 2025}		{sxavier}		{Adjust new logbook}
*******************************************************************/ 
CREATE PROCEDURE [dbo].[Logbook_Add] 
(	
	@LogbookType CHAR(2),
	@SiteCode CHAR(3),
	@ProcessId VARCHAR(3),
	@SubProcessId VARCHAR(3),
	@ShiftId VARCHAR(16) = '',
	@Title NVARCHAR(512),
	@Description NVARCHAR(MAX),
	@Importance VARCHAR(8),
	@Area VARCHAR(8),
	@AsigneeEmployeeId CHAR(10) = '',
	@DateCreated DATETIME = NULL,
	@TaskArea VARCHAR(MAX) = NULL,
	@TaskAreaCode VARCHAR(8) = NULL,
	@EwsTaskId UNIQUEIDENTIFIER = NULL,
	@EwsTransactionId INT = NULL,
	@AssignTo CHAR(10) = NULL,
	@DueDate DATETIME = NULL,
	@TaskStatusCode VARCHAR(MAX) = NULL,
	@TaskStatusDescription VARCHAR(MAX) = NULL,
	@WorkOrder VARCHAR(MAX) = NULL,
	@ExtendedProperty1 NVARCHAR(512),
	@ExtendedProperty2 NVARCHAR(512),
	@ExtendedProperty3 NVARCHAR(512),
	@Attachments AS dbo.LogbookAttachmentList READONLY,
	@PayloadJob VARCHAR(MAX),
	@User CHAR(10)
)
AS                        
BEGIN          
	SET NOCOUNT ON
	SET XACT_ABORT ON

		BEGIN TRANSACTION

		DECLARE @TempTable TABLE(Id INT)
		DECLARE @InsertedId INT

		DECLARE @TempJobTable TABLE(Id INT)
		DECLARE @InsertedJobId INT
	
		SET @ShiftId = (SELECT dbo.GetShiftIdFromSiteCode(@SiteCode, 'CURR'))

		INSERT INTO dbo.LOGBOOK
		(	
			SiteCode,
			ProcessId,
			SubProcessId,
			ShiftId,
			Title,
			[Description],
			AreaCode,
			ImportanceCode,
			LogbookTypeCode,
			EmployeeId,
			DateCreated,
			TaskArea,
			TaskAreaCode,
			EwsTaskId,
			EwsTransactionId,
			AssignedTo,
			DueDate,
			TaskStatusCode,
			TaskStatusDescription,
			WorkOrder,
			ExtendedProperty1,
			ExtendedProperty2,
			ExtendedProperty3,
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
			ISNULL(@ProcessId, CASE WHEN @LogbookType = 'MO' THEN 'CON'  ELSE '' END), -- ISNULL used to support backward compatible
			ISNULL(@SubProcessId, CASE WHEN @LogbookType = 'MO' THEN 'MOR'  ELSE '' END), -- ISNULL used to support backward compatible
			ISNULL(@ShiftId, ''),
			@Title,
			@Description,
			@Area,
			@Importance,
			@LogbookType,
			ISNULL(@AsigneeEmployeeId, ''),
			@DateCreated,
			@TaskArea,
			@TaskAreaCode,
			@EwsTaskId,
			@EwsTransactionId,
			@AssignTo,
			@DueDate,
			@TaskStatusCode,
			@TaskStatusDescription,
			@WorkOrder,
			@ExtendedProperty1,
			@ExtendedProperty2,
			@ExtendedProperty3,
			1,
			'',
			'',
			@User,
			GETUTCDATE(),
			@User,
			GETUTCDATE()
		)

		SET @InsertedId = (SELECT Id FROM @TempTable)

		INSERT INTO dbo.LOGBOOK_ATTACHMENTS
		(
			LogbookId,
			Title,
			AttachmentUrl,
			CreatedBy,
			Utc