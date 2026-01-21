









/******************************************************************  
* PROCEDURE	: dbo.CrushAndConvey_CrusherMatrix_IntermediateStockpile_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: jrodulfa, 12 Jun 2023
* SAMPLE	: 
	1. EXEC dbo.CrushAndConvey_CrusherMatrix_IntermediateStockpile_Get 'PREV', 'MOR'
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {12 Jun 2023}		{jrodulfa}		{Initial Created} 
* {18 Oct 2023}		{lwasini}		{Add Hourly Data & MillStockpile} 
* {30 Jan 2024}		{jrodulfa}		{Add TYR & ABR} 
*******************************************************************/ 
CREATE PROCEDURE [dbo].[CrushAndConvey_CrusherMatrix_IntermediateStockpile_Get] 
(	
	@SHIFT VARCHAR(4),
	@SITE VARCHAR(4)
)
AS                        
BEGIN          
	
	IF @SITE = 'BAG'
	BEGIN

		SELECT [SITEFLAG]
			  ,[SHIFTFLAG]
			  ,ROUND([MFLStockpile],0) [MFLStockpile]
			  ,ROUND([MillStockpile],0) [MillStockpile]
		FROM [bag].[CONOPS_BAG_CM_INTERMEDIATE_STOCKPILE_V] WITH (NOLOCK)
		WHERE [SHIFTFLAG] = @SHIFT;

		SELECT [SITEFLAG]
			  ,[SHIFTFLAG]
			  ,ROUND([MFLStockpile],0) [MFLStockpile]
			  ,ROUND([MillStockpile],0) [MillStockpile]
			  ,TimeInHour
		FROM [bag].[CONOPS_BAG_CM_HOURLY_INTERMEDIATE_STOCKPILE_V] WITH (NOLOCK)
		WHERE [SHIFTFLAG] = @SHIFT
		ORDER BY TimeInHour DESC;

	END

	ELSE IF @SITE = 'CVE'
	BEGIN

		SELECT [SITEFLAG]
			  ,[SHIFTFLAG]
			  ,ROUND([MFLStockpile],0) [MFLStockpile]
			  ,ROUND([MillStockpile],0) [MillStockpile]
		FROM [cer].[CONOPS_CER_CM_INTERMEDIATE_STOCKPILE_V] WITH (NOLOCK)
		WHERE [SHIFTFLAG] = @SHIFT;

		SELECT [SITEFLAG]
			  ,[SHIFTFLAG]
			  ,ROUND([MFLStockpile],0) [MFLStockpile]
			  ,ROUND([MillStockpile],0) [MillStockpile]
			  ,TimeInHour
		FROM [cer].[CONOPS_CER_CM_HOURLY_INTERMEDIATE_STOCKPILE_V] WITH (NOLOCK)
		WHERE [SHIFTFLAG] = @SHIFT
		ORDER BY TimeInHour DESC;

	END

	ELSE IF @SITE = 'CHN'
	BEGIN

		SELECT [SITEFLAG]
			  ,[SHIFTFLAG]
			  ,ROUND([MFLStockpile],0) [MFLStockpile]
			  ,ROUND([MillStockpile],0) [MillStockpile]
		FROM [chi].[CONOPS_CHI_CM_INTERMEDIATE_STOCKPILE_V] WITH (NOLOCK)
		WHERE [SHIFTFLAG] = @SHIFT;

		SELECT [SITEFLAG]
			  ,[SHIFTFLAG]
			  ,ROUND([MFLStockpile],0) [MFLStockpile]
			  ,ROUND([MillStockpile],0) [MillStockpile]
			  ,TimeInHour
		FROM [chi].[CONOPS_CHI_CM_HOURLY_INTERMEDIATE_STOCKPILE_V] WITH (NOLOCK)
		WHERE [SHIFTFLAG] = @SHIFT
		ORDER BY TimeInHour DESC;

	END

	ELSE IF @SITE = 'CMX'
	BEGIN

		SELECT [SITEFLAG]
			  ,[SHIFTFLAG]
			  ,ROUND([MFLStockpile],0) [MFLStockpile]
			  ,ROUND([MillStockpile],0) [MillStockpile]
		FROM [cli].[CONOPS_CLI_CM_INTERMEDIATE_STOCKPILE_V] WITH (NOLOCK)
		WHERE [SHIFTFLAG] = @SHIFT;

		SELECT [SITEFLAG]
			  ,[SHIFTFLAG]
			  ,ROUND([MFLStockpile],0) [MFLStockpile]
			  ,ROUND([MillStockpile],0) [MillStockpile]
			  ,TimeInHour
		FROM [cli].[CONOPS_CLI_CM_HOURLY_INTERMEDIATE_STOCKPILE_V] WITH (NOLOCK)
		WHERE [SHIFTFLAG] = @SHIFT
		ORDER BY TimeInHour DESC;

	END

	ELSE IF @SITE = 'MOR'
	BEGIN

		SELECT [SITEFLAG]
			  ,[SHIFTFLAG]
			  ,ROUND([MFLStockpile],0) [MFLStockpile]
			  ,ROUND([MillStockpile],0) [MillStockpile]
		FROM [mor].[CONOPS_MOR_CM_INTERMEDIATE_STOCKPILE_V] WITH (NOLOCK)
		WHERE [SHIFTFLAG] = @SHIFT;

		SELECT [SITEFLAG]
			  ,[SHIFTFLAG]
			  ,ROUND([MFLStockpile],0) [MFLStockpile]
			  ,ROUND([MillStockpile],0) [MillStockpile]
			  ,TimeInHour
		FROM [mor].[CONOPS_MOR_CM_HOURLY_INTERMEDIATE_STOCKPILE_V] WITH (NOLOCK)
		WHERE [SHIFTFLAG] = @SHIFT
		ORDER BY TimeInHour DESC;

	END

	ELSE IF @SITE = 'SAM'
	BEGIN

		SELECT [SITEFLAG]
			  ,[SHIFTFLAG]
			  ,ROUND([MFLStockpile],0) [MFLStockpile]
			  ,ROUND([MillStockpile],0) [MillStockpile]
		FROM [saf].[CONOPS_SAF_CM_INTERMEDIATE_STOCKPILE_V] WITH (NOLOCK)
		WHERE [SHIFTFLAG] = @SHIFT;

		SELECT [SITEFLAG]
			  ,[SHIFTFLAG]
			  ,ROUND