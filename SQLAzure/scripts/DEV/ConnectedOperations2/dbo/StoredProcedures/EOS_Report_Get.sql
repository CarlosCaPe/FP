
/******************************************************************  
* PROCEDURE	: dbo.EOS_Report_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: jrodulfa, 13 Jun 2023
* SAMPLE	: 
	1. EXEC dbo.EOS_Report_Get 'CURR', 'MOR',0
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {13 Jun 2023}		{jrodulfa}		{Initial Created} 
* {06 Dec 2023}		{lwasini}		{Add Daily Summary} 
* {30 Jan 2024}		{lwasini}		{Add TYR & ABR}
*******************************************************************/ 
CREATE PROCEDURE [dbo].[EOS_Report_Get] 
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
			  ,[Crew]
			  ,[ShiftDate]
			  ,[ShiftName]
		FROM [bag].[CONOPS_BAG_EOS_REPORT_V] WITH (NOLOCK)
		WHERE shiftflag = @SHIFT;
		END

		ELSE IF @DAILY = 1
		BEGIN
		SELECT [SHIFTFLAG]
			  ,[SITEFLAG]
			  ,[Crew]
			  ,[ShiftDate]
			  ,[ShiftName]
		FROM [bag].[CONOPS_BAG_DAILY_EOS_REPORT_V] WITH (NOLOCK)
		WHERE shiftflag = @SHIFT;
		END

	END

	ELSE IF @SITE = 'CVE'
	BEGIN

		IF @DAILY = 0
		BEGIN
		SELECT [SHIFTFLAG]
			  ,[SITEFLAG]
			  ,[Crew]
			  ,[ShiftDate]
			  ,[ShiftName]
		FROM [cer].[CONOPS_CER_EOS_REPORT_V] WITH (NOLOCK)
		WHERE shiftflag = @SHIFT;
		END

		ELSE IF @DAILY = 1
		BEGIN
		SELECT [SHIFTFLAG]
			  ,[SITEFLAG]
			  ,[Crew]
			  ,[ShiftDate]
			  ,[ShiftName]
		FROM [cer].[CONOPS_CER_DAILY_EOS_REPORT_V] WITH (NOLOCK)
		WHERE shiftflag = @SHIFT;
		END

	END

	ELSE IF @SITE = 'CHN'
	BEGIN

		IF @DAILY = 0
		BEGIN
		SELECT [SHIFTFLAG]
			  ,[SITEFLAG]
			  ,[Crew]
			  ,[ShiftDate]
			  ,[ShiftName]
		FROM [chi].[CONOPS_CHI_EOS_REPORT_V] WITH (NOLOCK)
		WHERE shiftflag = @SHIFT;
		END

		ELSE IF @DAILY = 1
		BEGIN
		SELECT [SHIFTFLAG]
			  ,[SITEFLAG]
			  ,[Crew]
			  ,[ShiftDate]
			  ,[ShiftName]
		FROM [chi].[CONOPS_CHI_DAILY_EOS_REPORT_V] WITH (NOLOCK)
		WHERE shiftflag = @SHIFT;
		END

	END

	ELSE IF @SITE = 'CMX'
	BEGIN

		IF @DAILY = 0
		BEGIN
		SELECT [SHIFTFLAG]
			  ,[SITEFLAG]
			  ,[Crew]
			  ,[ShiftDate]
			  ,[ShiftName]
		FROM [cli].[CONOPS_CLI_EOS_REPORT_V] WITH (NOLOCK)
		WHERE shiftflag = @SHIFT;
		END

		ELSE IF @DAILY = 1
		BEGIN
		SELECT [SHIFTFLAG]
			  ,[SITEFLAG]
			  ,[Crew]
			  ,[ShiftDate]
			  ,[ShiftName]
		FROM [cli].[CONOPS_CLI_DAILY_EOS_REPORT_V] WITH (NOLOCK)
		WHERE shiftflag = @SHIFT;
		END

	END

	ELSE IF @SITE = 'MOR'
	BEGIN

		IF @DAILY = 0
		BEGIN
		SELECT [SHIFTFLAG]
			  ,[SITEFLAG]
			  ,[Crew]
			  ,[ShiftDate]
			  ,[ShiftName]
		FROM [mor].[CONOPS_MOR_EOS_REPORT_V] WITH (NOLOCK)
		WHERE shiftflag = @SHIFT;
		END

		ELSE IF @DAILY = 1
		BEGIN
		SELECT [SHIFTFLAG]
			  ,[SITEFLAG]
			  ,[Crew]
			  ,[ShiftDate]
			  ,[ShiftName]
		FROM [mor].[CONOPS_MOR_DAILY_EOS_REPORT_V] WITH (NOLOCK)
		WHERE shiftflag = @SHIFT;
		END

	END

	ELSE IF @SITE = 'SAM'
	BEGIN

		IF @DAILY = 0
		BEGIN
		SELECT [SHIFTFLAG]
			  ,[SITEFLAG]
			  ,[Crew]
			  ,[ShiftDate]
			  ,[ShiftName]
		FROM [saf].[CONOPS_SAF_EOS_REPORT_V] WITH (NOLOCK)
		WHERE shiftflag = @SHIFT;
		END

		ELSE IF @DAILY = 1
		BEGIN
		SELECT [SHIFTFLAG]
			  ,[SITEFLAG]
			  ,[Crew]
			  ,[ShiftDate]
			  ,[ShiftName]
		FROM [saf].[CONOPS_SAF_DAILY_EOS_REPORT_V] WITH (NOLOCK)
		WHERE shiftflag = @SHIFT;
		END

	END

	ELSE IF @SITE = 'SIE'
	BEGIN

		IF @DAILY = 0
		BEGIN
		SELECT [SHIFTFLAG]
			  ,[SITEFLAG]
			  ,[Crew]
			  ,[ShiftDate]
			  ,[ShiftName]
		FROM [sie].[CONOPS_SIE_EOS_REPORT_V] WITH (NOLOCK)
		WHERE shiftflag = @SHIFT;
		END

		ELSE IF @DAILY = 1
		BEGIN
		SELECT [SHIFTFLAG]
			  ,[SITEFLAG]
			  ,[Crew]
			  ,[ShiftDate]
			  ,[ShiftName]
		FROM [sie].[CONOPS_SIE_DAILY_EOS_REPORT_V] WITH (NOLOCK)
		WHERE shiftfl