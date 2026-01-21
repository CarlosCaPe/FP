



/******************************************************************  
* PROCEDURE	: dbo.ConOpsLogbook_GetDetail
* PURPOSE	: 
* NOTES		: 
* CREATED	: sxavier, 05 Sep 2023
* SAMPLE	: 
	1. EXEC dbo.[ConOpsLogbook_GetDetail] 245, 'MOR','EN'
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {05 Sep 2023}			{sxavier}		{Initial Created}
*******************************************************************/ 
CREATE PROCEDURE [dbo].[ConOpsLogbook_GetDetail] 
(	
	@Id INT,
	@SiteCode CHAR(3),
	@LanguageCode CHAR(2)
)
AS                        
BEGIN          
SET NOCOUNT ON
	SELECT
		A.SiteCode,
		A.Id,
		A.Title,
		A.[Description],
		A.AreaCode,
		A.AreaValue,
		A.ImportanceValue,
		A.ImportanceCode,
		A.ExtendedProperty1 AS [Location],
		CONVERT(DATETIME, A.ExtendedProperty2, 121) AS DueDate,
		A.ExtendedProperty3 AS AsigneeEmployeeId,
		B.FULL_NAME AS AsigneeEmployeeName,
		A.ExtendedProperties,
		A.ModifiedBy,
		A.ModifiedByName,
		A.UtcModifiedDate,
		A.EmployeePhotoUrl
	FROM [dbo].[CONOPS_LOGBOOK_V] A
	LEFT JOIN [GlobalEntityRepository].[dbo].[vw_public_employee_data] B ON A.ExtendedProperty3 = B.employee_id
	WHERE
		A.Id = @Id AND
		A.SiteCode = @SiteCode AND
		A.LogbookTypeCode = 'CO' AND
		A.ImportanceLanguageCode = @LanguageCode AND
		A.AreaLanguageCode = @LanguageCode

	SELECT
		A.Title,
		A.AttachmentUrl
	FROM 
		[dbo].[CONOPS_LOGBOOK_ATTACHMENTS_V] A
	WHERE
		LogbookId = @Id

SET NOCOUNT OFF
END

