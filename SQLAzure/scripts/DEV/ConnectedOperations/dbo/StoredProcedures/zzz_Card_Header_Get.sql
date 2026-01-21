




/******************************************************************  
* PROCEDURE	: dbo.Card_Header_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: sxavier, 27 Dec 2023
* SAMPLE	: 
	1. EXEC dbo.Card_Header_Get

* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {27 Dec 2023}		{sxavier}		{Initial Created}
* {03 Jan 2024}		{ywibowo}		{Code review}
* {03 Jan 2024}		{sxavier}		{Remove moduleId}
* {08 Jan 2024}		{sxavier}		{Remove column status}
*******************************************************************/ 
CREATE PROCEDURE [dbo].[Card_Header_Get] 
AS                        
BEGIN          
SET NOCOUNT ON
	
	SELECT
		A.Id,
		A.CardTitle
	FROM 
		dbo.CONOPS_CARD_HEADER_V A
	ORDER BY
		A.CardTitle

SET NOCOUNT OFF
END


