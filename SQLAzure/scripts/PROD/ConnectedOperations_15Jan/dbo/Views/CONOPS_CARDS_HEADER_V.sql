CREATE VIEW [dbo].[CONOPS_CARDS_HEADER_V] AS








/******************************************************************  
* VIEW	    : dbo.CONOPS_CARD_HEADER_LANG_V
* PURPOSE	: 
* NOTES		: 
* CREATED	: sxavier, 26 Jan 2024
* SAMPLE	: 
	1. SELECT * FROM dbo.CONOPS_CARD_HEADER_LANG_V
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {26 Jan 2024}		{sxavier}		{Initial Created}
* {29 Jan 2024}		{ywibowo}		{Code review}
*******************************************************************/ 


CREATE VIEW [dbo].[CONOPS_CARDS_HEADER_V]
AS
	SELECT
		A.Id,
		A.CardId,
		A.LanguageCode,
		B.[Value] AS LanguageName,
		A.CardTitle,
		A.CardDescription,
		A.Notes,
		A.CreatedBy,
		A.UtcCreatedDate,
		A.ModifiedBy,
		A.UtcModifiedDate
	FROM [dbo].[CARDS_HEADER] A (NOLOCK)
	INNER JOIN [dbo].[CONOPS_LOOKUPS_V] B (NOLOCK) ON B.TableType = 'LANG' AND A.LanguageCode = B.TableCode
