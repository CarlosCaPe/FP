




/******************************************************************  
* PROCEDURE	: dbo.CardsDetail_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: sxavier, 21 Dec 2023
* SAMPLE	: 
	1. EXEC dbo.CardsDetail_Get 'CVE', null

* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {21 Dec 2023}		{sxavier}		{Initial Created}
* {26 Dec 2023}		{ywibowo}		{Code review}
* {03 Jan 2024}		{sxavier}		{Add moduleId}
* {08 Jan 2024}		{sxavier}		{Remove column status}
* {26 Jan 2024}		{sxavier}		{Support new design}
* {29 Jan 2024}		{ywibowo}		{Code review}
*******************************************************************/ 
CREATE PROCEDURE [dbo].[CardsDetail_Get] 
(	
	@SiteCode VARCHAR(3) = NULL,
	@Keyword NVARCHAR(MAX) = NULL
)
AS                        
BEGIN          
SET NOCOUNT ON
	
	SET @Keyword = '%' + ISNULL(@Keyword, '') + '%'

	SELECT
		A.Id,
		A.SiteCode,
		A.SiteName,
		A.CardId,
		B.CardName,
		A.SourceDataLocation,
		A.QueryName,
		A.Notes
	FROM 
		dbo.CONOPS_CARDS_DETAIL_V A
		INNER JOIN dbo.CONOPS_CARDS_V B ON A.CardId = B.Id
	WHERE 
		A.SiteCode LIKE ISNULL(@SiteCode, '%') AND
		(
			(B.CardName LIKE @Keyword) OR
			(A.SourceDataLocation LIKE @Keyword) OR
			(A.QueryName LIKE @Keyword) OR
			(A.Notes LIKE @Keyword)
		)
	ORDER BY
		 B.CardName, A.SiteName 

SET NOCOUNT OFF
END


