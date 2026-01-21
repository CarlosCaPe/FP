
/******************************************************************  
* PROCEDURE	: dbo.EOS_CrusherStats_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: jrodulfa, 09 Jun 2023
* SAMPLE	: 
	1. EXEC dbo.EOS_CrusherStats_Get 'CURR', 'MOR',1
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {09 Jun 2023}		{jrodulfa}		{Initial Created} 
* {28 Jul 2023}		{lwasini}		{Add ShiftStartDatetime & ShiftEndDatetime} 
* {30 Nov 2023}		{lwasini}		{Add Daily Summary} 
* {30 Jan 2024}		{lwasini}		{Add TYR & ABR} 
*******************************************************************/ 
CREATE PROCEDURE [dbo].[EOS_CrusherStats_Get] 
(	
	@SHIFT VARCHAR(4),
	@SITE VARCHAR(4),
	@DAILY INT
)
AS                        
BEGIN          

BEGIN TRY

	IF @SITE = 'BAG'
	BEGIN
		IF @DAILY = 0 
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

		ELSE IF @DAILY = 1
		BEGIN
		SELECT [SHIFTFLAG]
			  ,[SITEFLAG]
			  ,FIRST_VALUE([SHIFTSTARTDATETIME]) OVER (ORDER BY [SHIFTSTARTDATETIME] ASC) AS [SHIFTSTARTDATETIME]
			  ,FIRST_VALUE([SHIFTENDDATETIME]) OVER (ORDER BY [SHIFTENDDATETIME] DESC) AS [SHIFTENDDATETIME]
			  ,[CRUSHERLOC]
			  ,[DateTime]
			  ,[NOOFTRUCKWAITING]
		FROM [bag].[CONOPS_BAG_DAILY_EOS_CRUSHER_STATS_V]
		WHERE shiftflag = @SHIFT
		ORDER BY [CrusherLoc], [DateTime];

		SELECT [SHIFTFLAG]
			  ,[SITEFLAG]
			  ,[CRUSHERLOC]
			  ,[DateTime]
			  ,0 AS [DURATION]
		FROM [bag].[CONOPS_BAG_DAILY_EOS_CRUSHER_STATS_V]
		WHERE shiftflag = @SHIFT
		ORDER BY [CrusherLoc], [DateTime];
		END


	END

	ELSE IF @SITE = 'CVE'
	BEGIN
		
		IF @DAILY = 0
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

		ELSE IF @DAILY = 1
		BEGIN
		SELECT [SHIFTFLAG]
			  ,[SITEFLAG]
			  ,FIRST_VALUE([SHIFTSTARTDATETIME]) OVER (ORDER BY [SHIFTSTARTDATETIME] ASC) AS [SHIFTSTARTDATETIME]
			  ,FIRST_VALUE([SHIFTENDDATETIME]) OVER (ORDER BY [SHIFTENDDATETIME] DESC) AS [SHIFTENDDATETIME]
			  ,[CRUSHERLOC]
			  ,[DateTime]
			  ,[NOOFTRUCKWAITING]
		FROM [cer].[CONOPS_CER_DAILY_EOS_CRUSHER_STATS_V]
		WHERE shiftflag = @SHIFT
		ORDER BY [CrusherLoc], [DateTime];

		SELECT [SHIFTFLAG]
			  ,[SITEFLAG]
			  ,[CRUSHERLOC]
			  ,[DateTime]
			  ,0 AS [DURATION]
		FROM [cer].[CONOPS_CER_DAILY_EOS_CRUSHER_STATS_V]
		WHERE shiftflag = @SHIFT
		ORDER BY [CrusherLoc], [DateTime];
		END

	END

	ELSE IF @SITE = 'CHN'
	BEGIN
		
		IF @DAILY = 0
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

		ELSE IF @DAILY = 1
		BEGIN
		SELECT [SHIFTFLAG]
			  ,[SITEFLAG]
			  ,FIRST_VALUE([SHIFTSTARTDATETIME]) OVER 