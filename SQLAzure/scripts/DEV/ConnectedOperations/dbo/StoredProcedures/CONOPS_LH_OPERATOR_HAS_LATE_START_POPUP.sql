

/******************************************************************  
* PROCEDURE	: dbo.CONOPS_LH_OPERATOR_HAS_LATE_START_POPUP
* PURPOSE	: 
* NOTES		: 
* CREATED	: jrodulfa, 02 Dec 2022
* SAMPLE	: 
	1. EXEC dbo.CONOPS_LH_OPERATOR_HAS_LATE_START_POPUP 'CURR', 'MOR'
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {02 Dec 2022}		{jrodulfa}		{Initial Created} 
* {05 Dec 2022}		{sxavier}		{Fix select view} 
*******************************************************************/ 
CREATE PROCEDURE [dbo].[CONOPS_LH_OPERATOR_HAS_LATE_START_POPUP] 
(	
	@SHIFT VARCHAR(4),
	@SITE VARCHAR(4)
)
AS                        
BEGIN          
	
	SELECT *
	FROM [dbo].[CONOPS_MOR_OPERATOR_HAS_LATE_START_POPUP_V]
	WHERE shiftflag = @SHIFT
		AND siteflag = @SITE;

SET NOCOUNT OFF
END

