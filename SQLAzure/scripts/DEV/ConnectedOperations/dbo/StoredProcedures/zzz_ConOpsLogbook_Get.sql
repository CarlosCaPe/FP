



/******************************************************************  
* PROCEDURE	: dbo.ConOpsLogbook_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: sxavier, 07 Sep 2023
* SAMPLE	: 
	1. EXEC dbo.ConOpsLogbook_Get 'MOR','EN', 10, NULL, NULL, 'LASTSEVENDAYS', 'CATEGORY', NULL, NULL, NULL
		EXEC dbo.ConOpsLogbook_Get 'MOR','EN', 10, NULL, NULL, 'LASTSEVENDAYS', 'CATEGORY', NULL, NULL, '02023-09-07 09:04:11.060'

* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {07 Sep 2023}		{sxavier}		{Initial Created}
*******************************************************************/ 
CREATE PROCEDURE [dbo].[ConOpsLogbook_Get] 
(	
	@SiteCode CHAR(3),
	@LanguageCode CHAR(2),
	@Limit INT,
	@CategoryCode VARCHAR(30) = NULL,
	@PriorityCode VARCHAR(16) = NULL,
	@TimeFrame VARCHAR(30),
	@GroupBy VARCHAR(30),
	@AssignedTo CHAR(10) = NULL,
	@CreatedBy CHAR(10) = NULL,
	@RowIndex VARCHAR(64) = NULL
)
AS                        
BEGIN          
	SET NOCOUNT ON
		
	DECLARE @TimeFrameCurrent VARCHAR(30), @TimeFramePrevious VARCHAR(30), @TimeFrameLastSevenDays VARCHAR(30)
	SET @TimeFrameCurrent = 'CURR'
	SET @TimeFramePrevious = 'PREV'
	SET @TimeFrameLastSevenDays = 'LASTSEVENDAYS'
	SET @TimeFrame = UPPER(@TimeFrame)

	DECLARE @GroupByPriority VARCHAR(30), @GroupByCategory VARCHAR(30)
	SET @GroupByPriority = 'PRIORITY'
	SET @GroupByCategory = 'CATEGORY'
	SET @GroupBy = UPPER(@GroupBy)

	DECLARE @ShiftId VARCHAR(16) = NULL

	IF(@TimeFrame = @TimeFrameCurrent OR @TimeFrame = @TimeFramePrevious)
	BEGIN
		IF @SiteCode = 'BAG'
		BEGIN
			SET @ShiftId = (SELECT ShiftId FROM bag.CONOPS_BAG_SHIFT_INFO_V WHERE SHIFTFLAG = @TimeFrame)
		END
		ELSE IF @SiteCode = 'CVE'
		BEGIN
			SET @ShiftId = (SELECT ShiftId FROM cer.CONOPS_CER_SHIFT_INFO_V WHERE SHIFTFLAG = @TimeFrame)
		END
		ELSE IF @SiteCode = 'CHN'
		BEGIN
			SET @ShiftId = (SELECT ShiftId FROM chi.CONOPS_CHI_SHIFT_INFO_V WHERE SHIFTFLAG = @TimeFrame)
		END
		ELSE IF @SiteCode = 'CMX'
		BEGIN
			SET @ShiftId = (SELECT ShiftId FROM cli.CONOPS_CLI_SHIFT_INFO_V WHERE SHIFTFLAG = @TimeFrame)
		END
		ELSE IF @SiteCode = 'MOR'
		BEGIN
			SET @ShiftId = (SELECT ShiftId FROM mor.CONOPS_MOR_SHIFT_INFO_V WHERE SHIFTFLAG = @TimeFrame)
		END
		ELSE IF @SiteCode = 'SAM'
		BEGIN
			SET @ShiftId = (SELECT ShiftId FROM saf.CONOPS_SAF_SHIFT_INFO_V WHERE SHIFTFLAG = @TimeFrame)
		END
		ELSE IF @SiteCode = 'SIE'
		BEGIN
			SET @ShiftId = (SELECT ShiftId FROM sie.CONOPS_SIE_SHIFT_INFO_V WHERE SHIFTFLAG = @TimeFrame)
		END
	END
	

	SELECT TOP (@Limit)
		A.SiteCode,
		A.Id,
		A.Title,
		A.[Description],
		(SELECT TOP 1 AttachmentUrl FROM dbo.CONOPS_LOGBOOK_ATTACHMENTS_V WHERE LogbookId = A.Id) AS PhotoUrl,
		(SELECT COUNT(Id) FROM dbo.CONOPS_LOGBOOK_ATTACHMENTS_V WHERE LogbookId = A.Id) AS TotalPhoto,
		A.AreaCode,
		A.AreaValue,
		A.ImportanceValue,
		A.ImportanceCode,
		A.ExtendedProperties,
		A.ExtendedProperty1 AS [Location],
		A.ExtendedProperty2 AS [DueDate],
		A.ExtendedProperty3 AS AsigneeEmployeeId,
		C.FULL_NAME AS AsigneeEmployeeName,
		A.ExtendedProperty4 AS IsAddedToEos,
		A.ModifiedBy,
		A.ModifiedByName,
		A.UtcModifiedDate,
		A.CreatedBy,
		A.CreatedByName,
		A.UtcCreatedDate,
		A.EmployeePhotoUrl
	FROM [dbo].[CONOPS_LOGBOOK_V] A
	LEFT JOIN [GlobalEntityRepository].[dbo].[vw_public_employee_data] C ON A.ExtendedProperty3 = C.employee_id
	WHERE
		A.SiteCode = @SiteCode AND
		A.LogbookTypeCode = 'CO' AND
		A.ImportanceLanguageCode = @LanguageCode AND
		A.AreaLanguageCode = @LanguageCode AND
		(A.ImportanceCode IN (SELECT TRIM(VALUE) FROM STRING_SPLIT(@PriorityCode, ','))OR @PriorityCode IS NULL) AND
		(A.AreaCode IN (SELECT TRIM(VALUE) FROM STRING_SPLIT(@CategoryCode, ',')) OR @CategoryCode IS NULL) AND
		(A.ExtendedProperty3 = @AssignedTo OR @AssignedTo IS NULL) AND
		(A.CreatedBy = @CreatedBy OR @CreatedBy IS NULL) AND
		(
			(@GroupBy = @