



/******************************************************************  
* PROCEDURE	: dbo.Card_Detail_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: sxavier, 21 Dec 2023
* SAMPLE	: 
	1. EXEC dbo.Card_Detail_Get '0', null

* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {21 Dec 2023}		{sxavier}		{Initial Created}
* {26 Dec 2023}		{ywibowo}		{Code review}
* {03 Jan 2024}		{sxavier}		{Add moduleId}
* {08 Jan 2024}		{sxavier}		{Remove column status}
*******************************************************************/ 
CREATE PROCEDURE [dbo].[Card_Detail_Get] 
(	
	@ModuleId VARCHAR(8) = NULL,
	@SiteCode VARCHAR(3) = NULL,
	@LanguageCode VARCHAR(2) = NULL,
	@Keyword NVARCHAR(MAX) = NULL
)
AS                        
BEGIN          
SET NOCOUNT ON
	
	SET @Keyword = '%' + ISNULL(@Keyword, '') + '%'

	SELECT
		A.Id,
		A.ModuleId,
		A.ModuleName,
		A.SiteCode,
		A.SiteName,
		A.LanguageCode,
		A.CardHeaderId,
		B.CardTitle,
		A.CardDescription,
		A.SourceDataLocation,
		A.QueryName,
		A.Notes
	FROM 
		dbo.CONOPS_CARD_DETAIL_V A
		INNER JOIN dbo.CONOPS_CARD_HEADER_V B ON A.CardHeaderId = B.Id
	WHERE 
		A.ModuleId LIKE ISNULL(@ModuleId, '%') AND
		A.SiteCode LIKE ISNULL(@SiteCode, '%') AND
		A.LanguageCode LIKE ISNULL(@LanguageCode, '%') AND
		(
			(A.ModuleName LIKE @Keyword) OR
			(B.CardTitle LIKE @Keyword) OR
			(A.CardDescription LIKE @Keyword) OR
			(A.SourceDataLocation LIKE @Keyword) OR
			(A.QueryName LIKE @Keyword) OR
			(A.Notes LIKE @Keyword)
		)
	ORDER BY
		A.ModuleName, A.SiteName, A.LanguageCode, B.CardTitle

SET NOCOUNT OFF
END


