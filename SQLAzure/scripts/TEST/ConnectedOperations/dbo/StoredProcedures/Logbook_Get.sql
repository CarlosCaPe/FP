


/******************************************************************  
* PROCEDURE	: dbo.Logbook_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: elbert, 26 June 2023
* SAMPLE	: 
	1. EXEC dbo.Logbook_Get NULL, 'CO', 'MOR', NULL, NULL, NULL, 'EN', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
	2. EXEC dbo.Logbook_Get NULL, 'MO', 'MOR', NULL, 'EN', NULL, NULL, NULL, NULL, NULL, '2023-10-16T22:00:00.000Z', '2023-10-17T07:35:14.081Z', NULL

* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {26 Jun 2023}		{elbert}		{Initial Created}
* {07 Jul 2023}		{sxavier}		{Remove parameter Id and refactor query}
* {07 Jul 2023}		{ywibowo}		{Code Review, todo: need to set maximum return record}
* {10 Jul 2023}		{sxavier}		{Support pagination}
* {11 Jul 2023}		{pananda}		{Return employee name}
* {03 Aug 2023}		{sxavier}		{Support backward compatible based on parameter Page}
* {05 Sep 2023}		{sxavier}		{Support new database desing for Logbook}
* {03 Oct 2023}		{sxavier}		{Support CO Logbook}
* {03 Oct 2023}		{ywibowo}		{Code Review}
* {11 Oct 2024}		{sxavier}		{Remove join to GER}
* {21 Oct 2024}		{sxavier}		{Add ProcessId and SubProcessId}
* {23 Oct 2024}		{sxavier}		{Support different processId/subProcessId for Area}
* {28 Oct 2024}		{sxavier}		{Adjust MO to also support time frame}
*******************************************************************/ 
CREATE PROCEDURE [dbo].[Logbook_Get] 
(	
	@LogbookId INT = NULL,
	@LogbookType CHAR(2),
	@SiteCode CHAR(3),
	@ProcessId VARCHAR(3) = '',
	@SubProcessId VARCHAR(3) = '',
	@ShiftId VARCHAR(16) = NULL,
	@LanguageCode CHAR(2),
	@ImportanceCode VARCHAR(8) = NULL,
	@AreaCode VARCHAR(8) = NULL,
	@EmployeeId CHAR(10) = NULL,
	@CreatedBy CHAR(10) = NULL,
	@TimeFrame VARCHAR(30) = NULL,
	@DateFrom DATETIME = NULL,
	@DateTo DATETIME = NULL,
	@Page INT = NULL -- Not used only for backward compatibility
)
AS                        
BEGIN          
	SET NOCOUNT ON
		
		IF(@Page IS NULL)
			BEGIN

				SET @TimeFrame = UPPER(@TimeFrame)

				IF (@TimeFrame = 'CURR' OR @TimeFrame = 'PREV')
				BEGIN
					SET @ShiftId = (SELECT dbo.GetShiftIdFromSiteCode(@SiteCode, @TimeFrame))
				END

				SELECT
					A.SiteCode,
					A.Id,
					A.ShiftId,
					A.Title,
					A.[Description],
					B.AttachmentUrl AS PhotoUrl,
					A.AreaCode,
					D.[Value] AS AreaValue,
					A.ImportanceCode,
					E.[Value] AS ImportanceValue,
					A.EmployeeId AS AsigneeEmployeeId,
					A.ExtendedProperties,
					A.ExtendedProperty1,
					A.ExtendedProperty2,
					A.ExtendedProperty3,
					A.ModifiedBy,
					A.UtcModifiedDate,
					A.CreatedBy,
					A.UtcCreatedDate,
					A.EmployeePhotoUrlCreatedBy,
					A.EmployeePhotoUrlModifiedBy
				FROM [dbo].[CONOPS_LOGBOOK_V] A
				LEFT JOIN [dbo].[CONOPS_LOGBOOK_ATTACHMENTS_V] B ON A.Id = B.LogbookId
				INNER JOIN [dbo].[CONOPS_LOGBOOK_LOOKUPS_V] D ON D.LogbookType = @LogbookType AND D.TableType = 'AREA' AND 
					A.AreaCode = D.TableCode AND 
					D.LanguageCode = @LanguageCode AND 
					D.SiteCode = CASE WHEN A.LogbookTypeCode = 'MO' THEN @SiteCode  ELSE '' END AND
					D.ProcessId = @ProcessId AND
					D.SubProcessId = @SubProcessId
				INNER JOIN [dbo].[CONOPS_LOGBOOK_LOOKUPS_V] E ON E.LogbookType = @LogbookType AND E.TableType = 'IMPT' AND A.ImportanceCode = E.TableCode AND E.LanguageCode = @LanguageCode
				WHERE
					(A.Id = @LogbookId OR @LogbookId IS NULL) AND
					A.LogbookTypeCode = @LogbookType AND
					A.SiteCode = @SiteCode AND
					A.ProcessId = @ProcessId AND
					A.SubProcessId = @SubProcessId AND
					(A.ImportanceCode IN (SELECT TRIM(VALUE) FROM STRING_SPLIT(@ImportanceCode, ','))OR @ImportanceCode IS NULL) AND
					(A.AreaCode IN (SELECT TRIM(VALUE) FROM STRING_SPLIT(@AreaCode, ',')) OR @AreaCode IS NULL) AND
					(A.EmployeeId = @EmployeeId OR @EmployeeId IS NULL) AND
					(A.CreatedBy = @CreatedBy OR @CreatedBy IS NULL) AND