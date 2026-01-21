



/******************************************************************  
* PROCEDURE	: dbo.LoadAndHaulOverview_TruckshiftChangeDurationMinutes_Get
* PURPOSE	: Get data for Truck Shift Chnage Duration Minutes value
* NOTES		: 
* CREATED	: sxavier, 13 Dec 2022
* SAMPLE	: 
	1. EXEC dbo.LoadAndHaulOverview_TruckshiftChangeDurationMinutes_Get 'CURR', 'CVE'
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {13 Dec 2022}		{sxavier}		{Initial Created} 
* {11 Jan 2023}		{jrodulfa}		{Implement Bagdad data.} 
* {25 Jan 2023}		{jrodulfa}		{Implement Safford data.} 
* {27 Jan 2023}		{jrodulfa}		{Change SAF sitecode to SAM.}
* {06 Feb 2023}		{jrodulfa}		{Implement Chino Data.}
* {10 Feb 2023}		{mbote}		    {Implement Cerro Verde Data.}
*******************************************************************/ 
CREATE PROCEDURE [dbo].[LoadAndHaulOverview_TruckshiftChangeDurationMinutes_Get_OLD] 
(	
	@SHIFT VARCHAR(4),
	@SITE VARCHAR(4)
)
AS                        
BEGIN          

	SET @SITE = CASE @SITE
					WHEN 'SAM' THEN 'SAF'
					WHEN 'CVE' THEN 'CER'
					WHEN 'CHN' THEN 'CHI'
					ELSE @SITE
				END;
	
	SELECT 
		FORMAT(AVG(DurationMinute), '#0') [ShiftChangeDuration]
	FROM [dbo].[CONOPS_LH_TRUCK_SHIFT_CHANGE_DIALOG_V] WITH (NOLOCK)
	where shiftflag = @SHIFT
		  AND siteflag = @SITE
	GROUP BY [shiftflag], [siteflag]

		  
SET NOCOUNT OFF
END

