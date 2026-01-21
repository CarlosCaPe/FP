







/******************************************************************  
* PROCEDURE	: dbo.EOS_IOS_Stockpile_Tons_Grades_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: jrodulfa, 30 May 2023
* SAMPLE	: 
	1. EXEC dbo.EOS_IOS_Stockpile_Tons_Grades_Get 'CURR', 'BAG',1
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {30 May 2023}		{jrodulfa}		{Initial Created} 
* {20 Oct 2023}		{ggosal1}		{Add Hourly Data} 
* {06 Dec 2023}		{lwasini}		{Add Daily Summary} 
* {30 Jan 2024}		{lwasini}		{Add TYR & ABR} 
*******************************************************************/ 
CREATE PROCEDURE [dbo].[EOS_IOS_Stockpile_Tons_Grades_Get] 
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
		SELECT UPPER([CRUSHERLOC]) AS [CRUSHERLOC]
			  ,ISNULL(CONVERT(DECIMAL(10,2),[CrusherStockpile]), 0) AS [CrusherStockpile]
			  ,ISNULL(CONVERT(DECIMAL(10,2),[CrusherStockpileTons]), 0) AS [CrusherStockpileTons]
		FROM [bag].[CONOPS_BAG_EOS_IOS_STOCKPILE_V]
		WHERE [SHIFTFLAG] = @SHIFT
		ORDER BY CRUSHERLOC;

		SELECT
			   UPPER([CRUSHERLOC]) AS [CRUSHERLOC]
			  ,DateTime
			  ,ISNULL(CONVERT(DECIMAL(10,2),[CrusherStockpile]), 0) AS [CrusherStockpile]
			  ,ISNULL(CONVERT(DECIMAL(10,2),[CrusherStockpileTons]), 0) AS [CrusherStockpileTons]
		FROM [bag].[CONOPS_BAG_EOS_IOS_STOCKPILE_HOURLY_V]
		WHERE [SHIFTFLAG] = @SHIFT
		ORDER BY CRUSHERLOC, shiftseq;
		
		SELECT UPPER([CrusherLoc]) AS [CrusherLoc]
			  ,ROUND([TCU_PCT],3) AS TcuPct
			  ,ROUND([TMO_PCT],3) AS TmoPct
			  ,ROUND([TCLAY_PCT],3) AS TClayPct
			  ,ROUND([XCU_PCT],3) AS XcuPct
			  ,ROUND([KAOLINITE_PCT],3) AS KaolinitePct
			  ,ROUND([ASCU_PCT],3) AS AscuPct
			  ,ROUND([SWELLING_CLAY_PCT],3) AS SwellingClayPct
			  ,ROUND([SDR_P80],3) AS SdrP80
		FROM [bag].[CONOPS_BAG_EOS_TONS_CRUSHED_GRADES_V]
		WHERE shiftflag = @SHIFT
		ORDER BY [CrusherLoc];
		END


		ELSE IF @DAILY = 1
		BEGIN
		SELECT UPPER([CRUSHERLOC]) AS [CRUSHERLOC]
			  ,ISNULL(CONVERT(DECIMAL(10,2),SUM([CrusherStockpile])), 0) AS [CrusherStockpile]
			  ,ISNULL(CONVERT(DECIMAL(10,2),SUM([CrusherStockpileTons])), 0) AS [CrusherStockpileTons]
		FROM [bag].[CONOPS_BAG_DAILY_EOS_IOS_STOCKPILE_V]
		WHERE [SHIFTFLAG] = @SHIFT
		GROUP BY [CRUSHERLOC]
		ORDER BY CRUSHERLOC;

		SELECT DISTINCT
			   UPPER([CRUSHERLOC]) AS [CRUSHERLOC]
			  ,[DateTime]
			  ,ISNULL(CONVERT(DECIMAL(10,2),[CrusherStockpile]), 0) AS [CrusherStockpile]
			  ,ISNULL(CONVERT(DECIMAL(10,2),[CrusherStockpileTons]), 0) AS [CrusherStockpileTons]
		FROM [bag].[CONOPS_BAG_DAILY_EOS_IOS_STOCKPILE_HOURLY_V]
		WHERE [SHIFTFLAG] = @SHIFT
		ORDER BY CRUSHERLOC, [DateTime];
		
		SELECT UPPER([CrusherLoc]) AS [CrusherLoc]
			  ,ROUND(SUM([TCU_PCT]),3) AS TcuPct
			  ,ROUND(SUM([TMO_PCT]),3) AS TmoPct
			  ,ROUND(SUM([TCLAY_PCT]),3) AS TClayPct
			  ,ROUND(SUM([XCU_PCT]),3) AS XcuPct
			  ,ROUND(SUM([KAOLINITE_PCT]),3) AS KaolinitePct
			  ,ROUND(SUM([ASCU_PCT]),3) AS AscuPct
			  ,ROUND(SUM([SWELLING_CLAY_PCT]),3) AS SwellingClayPct
			  ,ROUND(SUM([SDR_P80]),3) AS SdrP80
		FROM [bag].[CONOPS_BAG_DAILY_EOS_TONS_CRUSHED_GRADES_V]
		WHERE shiftflag = @SHIFT
		GROUP BY [CrusherLoc]
		ORDER BY [CrusherLoc];
		END

	END

	ELSE IF @SITE = 'CVE'
	BEGIN


		IF @DAILY = 0
		BEGIN
		SELECT UPPER([CRUSHERLOC]) AS [CRUSHERLOC]
			  ,ISNULL(CONVERT(DECIMAL(10,2),[CrusherStockpile]), 0) AS [CrusherStockpile]
			  ,ISNULL(CONVERT(DECIMAL(10,2),[CrusherStockpileTons]), 0) AS [CrusherStockpileTons]
		FROM [cer].[CONOPS_CER_EOS_IOS_STOCKPILE_V]
		WHERE [SHIFTFLAG] = @SHIFT
		ORDER BY CRUSHERLOC;

		SELECT
			   UPPER([CRUSHERLOC]) AS [CRUSHERLOC]
			  ,DateTime
			  ,ISNULL(CONVERT(DECIMAL(10,2),[CrusherStockpile]), 0) AS [CrusherStockpile]
			  ,ISNULL(CONVERT(DECIMAL(10,2),[CrusherStockpileTons