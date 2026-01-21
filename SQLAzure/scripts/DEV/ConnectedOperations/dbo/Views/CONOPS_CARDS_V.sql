CREATE VIEW [dbo].[CONOPS_CARDS_V] AS







/******************************************************************  
* VIEW	    : dbo.CONOPS_CARD_HEADER_V
* PURPOSE	: 
* NOTES		: 
* CREATED	: sxavier, 21 Dec 2023
* SAMPLE	: 
	1. SELECT * FROM dbo.CONOPS_CARD_HEADER_V
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {21 Dec 2023}		{sxavier}		{Initial Created}
* {26 Dec 2023}		{ywibowo}		{Code review}
* {03 Jan 2024}		{sxavier}		{Remove moduleId}
* {08 Jan 2024}		{sxavier}		{Remove column status}
* {26 Jan 2024}		{sxavier}		{Support new design}
* {29 Jan 2024}		{ywibowo}		{Code review}
*******************************************************************/ 


CREATE VIEW [dbo].[CONOPS_CARDS_V]
AS
	SELECT
		A.Id,
		A.CardName,
		A.CreatedBy,
		A.UtcCreatedDate,
		A.ModifiedBy,
		A.UtcModifiedDate
	FROM [dbo].[CARDS] A (NOLOCK)

