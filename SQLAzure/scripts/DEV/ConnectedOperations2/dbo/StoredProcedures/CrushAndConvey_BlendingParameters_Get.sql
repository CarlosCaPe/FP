
/******************************************************************  
* PROCEDURE	: dbo.CrushAndConvey_BlendingParameters_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: jrodulfa, 28 Jun 2023
* SAMPLE	: 
	1. EXEC dbo.CrushAndConvey_BlendingParameters_Get 'PREV', 'CMX'
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {28 Jun 2023}		{jrodulfa}		{Initial Created} 
* {31 Oct 2023}		{lwasini}		{Add Location}
* {02 Nov 2023}		{ggosal1}		{Add Location, OXIDE_SULFIDE_RATIO, FE_PCT, PB_PCT} 
* {04 Dec 2023}		{lwasini}		{Order by Shovel}
* {30 Jan 2024}		{lwasini}		{Add ABR & TYR}
*******************************************************************/ 
CREATE PROCEDURE [dbo].[CrushAndConvey_BlendingParameters_Get] 
(	
	@SHIFT VARCHAR(4),
	@SITE VARCHAR(4)
)
AS                        
BEGIN          

BEGIN TRY

	IF @SITE = 'BAG'
	BEGIN

		SELECT [CrusherLoc]
			  ,AVG([TCU_PCT]) AS [TCU_PCT]
			  ,AVG([TMO_PCT]) AS [TMO_PCT]
			  ,AVG([TCLAY_PCT]) AS [TCLAY_PCT]
			  ,AVG([XCU_PCT]) AS [XCU_PCT]
			  ,AVG([KAOLINITE_PCT]) AS [KAOLINITE_PCT]
			  ,AVG([ASCU_PCT]) AS [ASCU_PCT]
			  ,AVG([SWELLING_CLAY_PCT]) AS [SWELLING_CLAY_PCT]
			  ,AVG([SDR_P80]) AS [SDR_P80]
			  ,[hr]
			  ,[HOS]
		FROM [bag].[CONOPS_BAG_MMT_RAW_V]
		WHERE [SHIFTFLAG] = @SHIFT
		GROUP BY [CrusherLoc], [hr], [HOS]
		ORDER BY [hr] desc;

		SELECT [CrusherLoc]
			  ,AVG([TCU_PCT]) AS [TCU_PCT]
			  ,AVG([TMO_PCT]) AS [TMO_PCT]
			  ,AVG([TCLAY_PCT]) AS [TCLAY_PCT]
			  ,AVG([XCU_PCT]) AS [XCU_PCT]
			  ,AVG([KAOLINITE_PCT]) AS [KAOLINITE_PCT]
			  ,AVG([ASCU_PCT]) AS [ASCU_PCT]
			  ,AVG([SWELLING_CLAY_PCT]) AS [SWELLING_CLAY_PCT]
			  ,AVG([SDR_P80]) AS [SDR_P80]
		FROM [bag].[CONOPS_BAG_MMT_RAW_V]
		WHERE [SHIFTFLAG] = @SHIFT
		GROUP BY [CrusherLoc];

		SELECT [CrusherLoc]
			  ,[LOAD_EXCAV]
			  ,[LOCATION]
			  ,AVG([TCU_PCT]) AS [TCU_PCT]
			  ,NULL AS [TCU_PCT_TARGET] --Hardcoded Value for DEV
			  ,AVG([TMO_PCT]) AS [TMO_PCT]
			  ,NULL AS [TMO_PCT_TARGET] --Hardcoded Value for DEV
			  ,AVG([TCLAY_PCT]) AS [TCLAY_PCT]
			  ,NULL AS [TCLAY_PCT_TARGET] --Hardcoded Value for DEV
			  ,AVG([XCU_PCT]) AS [XCU_PCT]
			  ,NULL AS [XCU_PCT_TARGET] --Hardcoded Value for DEV
			  ,AVG([KAOLINITE_PCT]) AS [KAOLINITE_PCT]
			  ,NULL AS [KAOLINITE_PCT_TARGET] --Hardcoded Value for DEV
			  ,AVG([ASCU_PCT]) AS [ASCU_PCT]
			  ,NULL AS [ASCU_PCT_TARGET] --Hardcoded Value for DEV
			  ,AVG([SWELLING_CLAY_PCT]) AS [SWELLING_CLAY_PCT]
			  ,NULL AS [SWELLING_CLAY_TARGET] --Hardcoded Value for DEV
			  ,AVG([SDR_P80]) AS [SDR_P80]
			  ,NULL AS [SDR_P80_TARGET] --Hardcoded Value for DEV
		FROM [bag].[CONOPS_BAG_MMT_RAW_V]
		WHERE [SHIFTFLAG] = @SHIFT
		GROUP BY [CrusherLoc], [LOAD_EXCAV], [LOCATION]
		ORDER BY LEFT([LOAD_EXCAV],1) DESC, [LOAD_EXCAV] ASC;
		

		SELECT [CrusherLoc]
			  ,[LOAD_EXCAV]
			  ,AVG([TCU_PCT]) AS [TCU_PCT]
			  ,AVG([TMO_PCT]) AS [TMO_PCT]
			  ,AVG([TCLAY_PCT]) AS [TCLAY_PCT]
			  ,AVG([XCU_PCT]) AS [XCU_PCT]
			  ,AVG([KAOLINITE_PCT]) AS [KAOLINITE_PCT]
			  ,AVG([ASCU_PCT]) AS [ASCU_PCT]
			  ,AVG([SWELLING_CLAY_PCT]) AS [SWELLING_CLAY_PCT]
			  ,AVG([SDR_P80]) AS [SDR_P80]
			  ,[hr]
			  ,[HOS]
		FROM [bag].[CONOPS_BAG_MMT_RAW_V]
		WHERE [SHIFTFLAG] = @SHIFT
		GROUP BY [CrusherLoc], [LOAD_EXCAV], [hr], [HOS]
		ORDER BY LEFT([LOAD_EXCAV],1) DESC, [LOAD_EXCAV] ASC, [hr] desc;
		

	END

	ELSE IF @SITE = 'CVE'
	BEGIN

		SELECT [CrusherLoc]
			  ,AVG([TCU_PCT]) AS [TCU_PCT]
			  ,AVG([TMO_PCT]) AS [TMO_PCT]
			  ,AVG([TCLAY_PCT]) AS [TCLAY_PCT]
			  ,AVG([XCU_PCT]) AS [XCU_PCT]
			  ,AVG([KAOLINITE_PCT]) AS [KAOLINITE_PCT]
			  ,AVG([ASCU_PCT]) AS [ASCU_PCT]
			  ,AVG([SWELLING_CLAY_PCT]) AS [SWELLING_CLAY_PCT]
			  ,AVG([SDR_P80]) AS [SDR_P80]
			  ,[hr]
			  ,[HOS]
		FROM [cer].[CONOPS_CER_MMT_RAW_V]
		WHERE [SHIFTFLAG] = @SHIFT
		GROUP BY [CrusherLoc], [hr], [HOS]
		ORDER B