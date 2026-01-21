




/******************************************************************  
* PROCEDURE	: dbo.CardsHeader_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: sxavier, 26 Jan 2024
* SAMPLE	: 
	1. EXEC dbo.CardsHeader_Get null, null

* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {26 Jan 2024}		{sxavier}		{Initial Created}
* {29 Jan 2024}		{ywibowo}		{Code review}
*******************************************************************/ 
CREATE PROCEDURE [dbo].[CardsHeader_Get] 
(	
	@LanguageCode VARCHAR(2) = NULL,
	@Keyword NVARCHAR(MAX) = NULL
)
AS                        
BEGIN          
SET NOCOUNT ON
	
	SET @Keyword = '%' + ISNULL(@Keyword, '') + '%'

	SELECT
		A.Id,
		A.CardId,
		A.LanguageCode,
		B.CardName,
		A.CardTitle,
		A.CardDescription,
		A.Notes
	FROM 
		dbo.CONOPS_CARDS_HEADER_V A
		INNER JOIN dbo.CONOPS_CARDS_V B ON A.CardId = B.Id
	WHERE 
		A.LanguageCode LIKE ISNULL(@LanguageCode, '%') AND
		(
			(B.CardName LIKE @Keyword) OR
			(A.CardTitle LIKE @Keyword) OR
			(A.CardDescription LIKE @Keyword) OR
			(A.Notes LIKE @Keyword)
		)
	ORDER BY
		B.CardName, A.LanguageCode

SET NOCOUNT OFF
END


