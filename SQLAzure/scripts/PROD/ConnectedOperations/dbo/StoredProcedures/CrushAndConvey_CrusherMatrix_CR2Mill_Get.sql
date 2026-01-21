

/******************************************************************  
* PROCEDURE	: dbo.CrushAndConvey_CrusherMatrix_CR2Mill_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: jrodulfa, 23 Jun 2023
* SAMPLE	: 
	1. EXEC dbo.CrushAndConvey_CrusherMatrix_CR2Mill_Get 'PREV', 'MOR'
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {23 Jun 2023}		{jrodulfa}		{Initial Created} 
* {18 Oct 2023}		{lwasini}		{Add Hourly CR2Mill} 
* {04 Jan 2024}		{lwasini}		{Added CrusherLoc} 
*******************************************************************/ 
CREATE PROCEDURE [dbo].[CrushAndConvey_CrusherMatrix_CR2Mill_Get] 
(	
	@SHIFT VARCHAR(4),
	@SITE VARCHAR(4)
)
AS                        
BEGIN          

BEGIN TRY

	IF @SITE = 'MOR'
	BEGIN

		SELECT [SITEFLAG]
			  ,[SHIFTFLAG]
			  ,CrusherLoc
			  ,Crusher
			  ,CR2Mill AS CR2MillValue
			  /*,CrusherCR2ToMill
			  ,CrusherMFLIOS
			  ,CrusherMillIOS*/
		FROM [mor].[CONOPS_MOR_CM_CR2Mill_V] WITH (NOLOCK)
		WHERE [SHIFTFLAG] = @SHIFT

		UNION ALL

		SELECT [SITEFLAG]
			  ,[SHIFTFLAG]
			  ,'All' AS CrusherLoc
			  ,Crusher
			  ,SUM(CR2Mill) AS CR2MillValue
		FROM [mor].[CONOPS_MOR_CM_CR2Mill_V] WITH (NOLOCK)
		WHERE [SHIFTFLAG] = @SHIFT
		GROUP BY [SITEFLAG], [SHIFTFLAG], Crusher;


		SELECT --CrusherCR2ToMill
			  CrusherLoc
			  ,Crusher
			  ,CR2Mill AS CR2MillValue
			  ,TimeInHour
		FROM [mor].[CONOPS_MOR_CM_HOURLY_CR2Mill_V] WITH (NOLOCK)
		WHERE [SHIFTFLAG] = @SHIFT
		AND Crusher = 'CrusherCR2ToMill'
		--ORDER BY TimeInHour DESC;

		UNION ALL

		SELECT --CrusherCR2ToMill
			  'All' AS CrusherLoc
			  ,Crusher
			  ,SUM(CR2Mill) AS CR2MillValue
			  ,TimeInHour
		FROM [mor].[CONOPS_MOR_CM_HOURLY_CR2Mill_V] WITH (NOLOCK)
		WHERE [SHIFTFLAG] = @SHIFT
		AND Crusher = 'CrusherCR2ToMill'
		GROUP BY Crusher, TimeInHour
		--ORDER BY TimeInHour DESC;

	END

END TRY
BEGIN CATCH
	PRINT ERROR_MESSAGE();
END CATCH

END






