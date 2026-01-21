



/******************************************************************  
* PROCEDURE	: dbo.Logbook_GetDetail
* PURPOSE	: 
* NOTES		: 
* CREATED	: sxavier, 21 Apr 2025
* SAMPLE	: 
	EXEC dbo.Logbook_GetDetail 726, 'EN'
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {21 Apr 2025}		{sxavier}		{Initial code}
*******************************************************************/ 
CREATE PROCEDURE [dbo].[Logbook_GetDetail] 
(	
	@LogbookId INT,
	@LanguageCode CHAR(2)
)
AS                        
BEGIN          
	SET NOCOUNT ON
	

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
		A.DateCreated,
		A.TaskArea,
		A.EwsTaskId,
		A.EwsTransactionId,
		A.AssignedTo,
		A.TaskEmployeePhotoUrlAssignedTo,
		A.DueDate,
		A.TaskStatusCode,
		A.TaskStatusDescription,
		A.WorkOrder,
		'' AS EwsTaskUrl,
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
	INNER JOIN [dbo].[CONOPS_LOGBOOK_LOOKUPS_V] D ON D.LogbookType = A.LogbookTypeCode AND D.TableType = 'AREA' AND 
		A.AreaCode = D.TableCode AND 
		D.LanguageCode = @LanguageCode AND 
		D.SiteCode = CASE WHEN A.LogbookTypeCode = 'MO' THEN A.SiteCode  ELSE '' END AND
		D.ProcessId = ISNULL(A.ProcessId, CASE WHEN A.LogbookTypeCode = 'MO' THEN 'CON'  ELSE '' END) AND -- ISNULL to support backward compatible
		D.SubProcessId = ISNULL(A.SubProcessId, CASE WHEN A.LogbookTypeCode = 'MO' THEN 'MOR'  ELSE '' END) -- ISNULL to support backward compatible
	INNER JOIN [dbo].[CONOPS_LOGBOOK_LOOKUPS_V] E ON E.LogbookType = A.LogbookTypeCode AND E.TableType = 'IMPT' AND A.ImportanceCode = E.TableCode AND E.LanguageCode = @LanguageCode
	WHERE
		A.Id = @LogbookId
	ORDER BY 
		A.UtcCreatedDate DESC
		

	SET NOCOUNT OFF
END
