





/******************************************************************  
* PROCEDURE	: dbo.Cards_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: sxavier, 27 Dec 2023
* SAMPLE	: 
	1. EXEC dbo.Cards_Get

* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {27 Dec 2023}		{sxavier}		{Initial Created}
* {03 Jan 2024}		{ywibowo}		{Code review}
* {03 Jan 2024}		{sxavier}		{Remove moduleId}
* {08 Jan 2024}		{sxavier}		{Remove column status}
* {29 Jan 2024}		{ywibowo}		{Code review}
*******************************************************************/ 
CREATE PROCEDURE [dbo].[Cards_Get] 
AS                        
BEGIN          
SET NOCOUNT ON
	
	SELECT
		A.Id,
		A.CardName
	FROM 
		dbo.CONOPS_CARDS_V A
	ORDER BY
		A.CardName

SET NOCOUNT OFF
END


