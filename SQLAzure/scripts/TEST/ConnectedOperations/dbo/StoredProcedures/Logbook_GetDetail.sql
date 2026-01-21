

/******************************************************************  
* PROCEDURE	: dbo.Logbook_GetDetail
* PURPOSE	: 
* NOTES		: 
* CREATED	: elbert, 26 June 2023
* SAMPLE	: 
	1. EXEC dbo.[Logbook_GetDetail] 2, 'MOR','EN'
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {26 June 2023}		{elbert}		{Initial Created}
* {07 Jul 2023}		    {ywibowo}		{Code Review}
* {11 Jul 2023}			{pananda}		{Return employee name}
*******************************************************************/ 
CREATE PROCEDURE [dbo].[Logbook_GetDetail] 
(	
	@Id INT,
	@Site CHAR(3),
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
		A.PhotoUrl,
		A.AreaCode,
		A.AreaValue,
		A.ImportanceValue,
		A.ImportanceCode,
		A.ExtendedProperties,
		A.ModifiedBy,
		A.ModifiedByName,
		A.UtcModifiedDate,
		A.EmployeePhotoUrl
	FROM [dbo].[CONOPS_LOGBOOK_V] A
	WHERE
		A.Id = @Id AND
		A.SiteCode = @Site AND
		A.ImportanceLanguageCode = @LanguageCode AND
		A.AreaLanguageCode = @LanguageCode

SET NOCOUNT OFF
END

