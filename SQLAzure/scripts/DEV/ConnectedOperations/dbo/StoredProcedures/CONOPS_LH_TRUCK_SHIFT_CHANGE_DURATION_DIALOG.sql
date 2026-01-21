
/******************************************************************  
* PROCEDURE	: dbo.CONOPS_LH_TRUCK_SHIFT_CHANGE_DURATION_DIALOG
* PURPOSE	: 
* NOTES		: 
* CREATED	: jrodulfa, 02 Dec 2022
* SAMPLE	: 
	1. EXEC dbo.CONOPS_LH_TRUCK_SHIFT_CHANGE_DURATION_DIALOG 'CURR', 'MOR'
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {02 Dec 2022}		{jrodulfa}		{Initial Created} 
* {05 Dec 2022}		{jrodulfa}		{Change SP based on the updated dialog design for Truck Asset Efficiency} 
*******************************************************************/ 
CREATE PROCEDURE [dbo].[CONOPS_LH_TRUCK_SHIFT_CHANGE_DURATION_DIALOG] 
(	
	@SHIFT VARCHAR(4),
	@SITE VARCHAR(4)
)
AS                        
BEGIN          
	
	SELECT shiftflag,
		   siteflag,
		   TruckID,
		   Operator,
		   [ChangeDuration],
		   Region
	FROM [dbo].[CONOPS_MOR_TRUCK_SHIFT_CHANGE_DIALOG_V]
	WHERE shiftflag = @SHIFT
		AND siteflag = @SITE
	ORDER BY [ChangeDuration] desc;

SET NOCOUNT OFF
END

