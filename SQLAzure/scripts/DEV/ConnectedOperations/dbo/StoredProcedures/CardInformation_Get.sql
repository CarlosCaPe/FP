





/******************************************************************  
* PROCEDURE	: dbo.CardInformation_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: sxavier, 21 Dec 2023
* SAMPLE	: 
	1. EXEC dbo.CardInformation_Get 'CVE', 'EN'

* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {26 Jan 2024}		{sxavier}		{Initial Created}
* {29 Jan 2024}		{ywibowo}		{Code review}
*******************************************************************/ 
CREATE PROCEDURE [dbo].[CardInformation_Get] 
(	
	@SiteCode VARCHAR(3),
	@LanguageCode VARCHAR(2)
)
AS                        
BEGIN          
SET NOCOUNT ON
	
	SELECT
		A.Id,
		A.SiteCode,
		B.LanguageCode,
		B.CardTitle,
		B.CardDescription,
		A.SourceDataLocation,
		A.QueryName
	FROM 
		dbo.CONOPS_CARDS_DETAIL_V A
		INNER JOIN dbo.CONOPS_CARDS_HEADER_V B ON A.CardId = B.CardId
	WHERE 
		A.SiteCode = @SiteCode AND
		B.LanguageCode = @LanguageCode
	ORDER BY
		 B.CardTitle, A.SiteName 

SET NOCOUNT OFF
END


