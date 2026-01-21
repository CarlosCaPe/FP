


/******************************************************************  
* PROCEDURE	: dbo.CrushAndConvey_TrafficMatrix_CrusherStats_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: jrodulfa, 09 Jun 2023
* SAMPLE	: 
	1. EXEC dbo.CrushAndConvey_TrafficMatrix_CrusherStats_Get 'CURR', 'MOR'
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {09 Jun 2023}		{jrodulfa}		{Initial Created} 
* {28 Jul 2023}		{lwasini}		{Add ShiftStartDatetime & ShiftEndDatetime} 
* {30 Jan 2024}		{lwasini}		{Add TYR & ABR}
*******************************************************************/ 
CREATE PROCEDURE [dbo].[CrushAndConvey_TrafficMatrix_CrusherStats_Get] 
(	
	@SHIFT VARCHAR(4),
	@SITE VARCHAR(4)
)
AS                        
BEGIN          

BEGIN TRY

	IF @SITE = 'BAG'
	BEGIN

		SELECT [SHIFTFLAG]
			  ,[SITEFLAG]
			  ,[SHIFTSTARTDATETIME]
			  ,[SHIFTENDDATETIME]
			  ,[CRUSHERLOC]
			  ,[DateTime]
			  ,[NOOFTRUCKWAITING]
		FROM [bag].[CONOPS_BAG_EOS_CRUSHER_STATS_V]
		WHERE shiftflag = @SHIFT
		ORDER BY [CrusherLoc], [DateTime];

		SELECT [SHIFTFLAG]
			  ,[SITEFLAG]
			  ,[CRUSHERLOC]
			  ,[DateTime]
			  ,0 AS [DURATION]
		FROM [bag].[CONOPS_BAG_EOS_CRUSHER_STATS_V]
		WHERE shiftflag = @SHIFT
		ORDER BY [CrusherLoc], [DateTime];

	END

	ELSE IF @SITE = 'CVE'
	BEGIN

		SELECT [SHIFTFLAG]
			  ,[SITEFLAG]
			  ,[SHIFTSTARTDATETIME]
			  ,[SHIFTENDDATETIME]
			  ,[CRUSHERLOC]
			  ,[DateTime]
			  ,[NOOFTRUCKWAITING]
		FROM [cer].[CONOPS_CER_EOS_CRUSHER_STATS_V]
		WHERE shiftflag = @SHIFT
		ORDER BY [CrusherLoc], [DateTime];

		SELECT [SHIFTFLAG]
			  ,[SITEFLAG]
			  ,[CRUSHERLOC]
			  ,[DateTime]
			  ,0 AS [DURATION]
		FROM [cer].[CONOPS_CER_EOS_CRUSHER_STATS_V]
		WHERE shiftflag = @SHIFT
		ORDER BY [CrusherLoc], [DateTime];

	END

	ELSE IF @SITE = 'CHN'
	BEGIN

		SELECT [SHIFTFLAG]
			  ,[SITEFLAG]
			  ,[SHIFTSTARTDATETIME]
			  ,[SHIFTENDDATETIME]
			  ,[CRUSHERLOC]
			  ,[DateTime]
			  ,[NOOFTRUCKWAITING]
		FROM [chi].[CONOPS_CHI_EOS_CRUSHER_STATS_V]
		WHERE shiftflag = @SHIFT
		ORDER BY [CrusherLoc], [DateTime];

		SELECT [SHIFTFLAG]
			  ,[SITEFLAG]
			  ,[CRUSHERLOC]
			  ,[DateTime]
			  ,0 AS [DURATION]
		FROM [chi].[CONOPS_CHI_EOS_CRUSHER_STATS_V]
		WHERE shiftflag = @SHIFT
		ORDER BY [CrusherLoc], [DateTime];

	END

	ELSE IF @SITE = 'CMX'
	BEGIN

		SELECT [SHIFTFLAG]
			  ,[SITEFLAG]
			  ,[SHIFTSTARTDATETIME]
			  ,[SHIFTENDDATETIME]
			  ,[CRUSHERLOC]
			  ,[DateTime]
			  ,[NOOFTRUCKWAITING]
		FROM [cli].[CONOPS_CLI_EOS_CRUSHER_STATS_V]
		WHERE shiftflag = @SHIFT
		ORDER BY [CrusherLoc], [DateTime];

		SELECT [SHIFTFLAG]
			  ,[SITEFLAG]
			  ,[CRUSHERLOC]
			  ,[DateTime]
			  ,0 AS [DURATION]
		FROM [cli].[CONOPS_CLI_EOS_CRUSHER_STATS_V]
		WHERE shiftflag = @SHIFT
		ORDER BY [CrusherLoc], [DateTime];

	END

	ELSE IF @SITE = 'MOR'
	BEGIN

		SELECT [SHIFTFLAG]
			  ,[SITEFLAG]
			  ,[SHIFTSTARTDATETIME]
			  ,[SHIFTENDDATETIME]
			  ,[CRUSHERLOC]
			  ,[DateTime]
			  ,[NOOFTRUCKWAITING]
		FROM [mor].[CONOPS_MOR_EOS_CRUSHER_STATS_V]
		WHERE shiftflag = @SHIFT
		ORDER BY [CrusherLoc], [DateTime];

		SELECT [SHIFTFLAG]
			  ,[SITEFLAG]
			  ,[CRUSHERLOC]
			  ,[DateTime]
			  ,0 AS [DURATION]
		FROM [mor].[CONOPS_MOR_EOS_CRUSHER_STATS_V]
		WHERE shiftflag = @SHIFT
		ORDER BY [CrusherLoc], [DateTime];

	END

	ELSE IF @SITE = 'SAM'
	BEGIN

		SELECT [SHIFTFLAG]
			  ,[SITEFLAG]
			  ,[SHIFTSTARTDATETIME]
			  ,[SHIFTENDDATETIME]
			  ,[CRUSHERLOC]
			  ,[DateTime]
			  ,[NOOFTRUCKWAITING]
		FROM [saf].[CONOPS_SAF_EOS_CRUSHER_STATS_V]
		WHERE shiftflag = @SHIFT
		ORDER BY [CrusherLoc], [DateTime];

		SELECT [SHIFTFLAG]
			  ,[SITEFLAG]
			  ,[CRUSHERLOC]
			  ,[DateTime]
			  ,0 AS [DURATION]
		FROM [saf].[CONOPS_SAF_EOS_CRUSHER_STATS_V]
		WHERE shiftflag = @SHIFT
		ORDER BY [CrusherLoc], [DateTime];
