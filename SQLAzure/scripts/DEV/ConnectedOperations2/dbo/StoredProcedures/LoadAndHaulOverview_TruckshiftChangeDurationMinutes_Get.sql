








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
CREATE PROCEDURE [dbo].[LoadAndHaulOverview_TruckshiftChangeDurationMinutes_Get] 
(	
	@SHIFT VARCHAR(4),
	@SITE VARCHAR(4)
)
AS                        
BEGIN          

	IF @SITE = 'BAG'
	BEGIN

		SELECT 
			FORMAT(AVG(DurationMinute), '#0') [ShiftChangeDuration]
		FROM BAG.[CONOPS_BAG_TRUCK_SHIFT_CHANGE_DIALOG_V] WITH (NOLOCK)
		WHERE shiftflag = @SHIFT
		GROUP BY [shiftflag]

	END

	ELSE IF @SITE = 'CVE'
	BEGIN

		SELECT 
			FORMAT(AVG(DurationMinute), '#0') [ShiftChangeDuration]
		FROM CER.[CONOPS_CER_TRUCK_SHIFT_CHANGE_DIALOG_V] WITH (NOLOCK)
		WHERE shiftflag = @SHIFT
		GROUP BY [shiftflag]

	END

	ELSE IF @SITE = 'CHN'
	BEGIN

		SELECT 
			FORMAT(AVG(DurationMinute), '#0') [ShiftChangeDuration]
		FROM CHI.[CONOPS_CHI_TRUCK_SHIFT_CHANGE_DIALOG_V] WITH (NOLOCK)
		WHERE shiftflag = @SHIFT
		GROUP BY [shiftflag]

	END

	ELSE IF @SITE = 'CMX'
	BEGIN

		SELECT 
			FORMAT(AVG(DurationMinute), '#0') [ShiftChangeDuration]
		FROM CLI.[CONOPS_CLI_TRUCK_SHIFT_CHANGE_DIALOG_V] WITH (NOLOCK)
		WHERE shiftflag = @SHIFT
		GROUP BY [shiftflag]

	END

	ELSE IF @SITE = 'MOR'
	BEGIN

		SELECT 
			FORMAT(AVG(DurationMinute), '#0') [ShiftChangeDuration]
		FROM MOR.[CONOPS_MOR_TRUCK_SHIFT_CHANGE_DIALOG_V] WITH (NOLOCK)
		WHERE shiftflag = @SHIFT
		GROUP BY [shiftflag]

	END

	ELSE IF @SITE = 'SAM'
	BEGIN

		SELECT 
			FORMAT(AVG(DurationMinute), '#0') [ShiftChangeDuration]
		FROM SAF.[CONOPS_SAF_TRUCK_SHIFT_CHANGE_DIALOG_V] WITH (NOLOCK)
		WHERE shiftflag = @SHIFT
		GROUP BY [shiftflag]

	END

	ELSE IF @SITE = 'SIE'
	BEGIN

		SELECT 
			FORMAT(AVG(DurationMinute), '#0') [ShiftChangeDuration]
		FROM SIE.[CONOPS_SIE_TRUCK_SHIFT_CHANGE_DIALOG_V] WITH (NOLOCK)
		WHERE shiftflag = @SHIFT
		GROUP BY [shiftflag]

	END

END




