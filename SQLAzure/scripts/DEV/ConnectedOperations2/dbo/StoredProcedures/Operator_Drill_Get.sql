
/******************************************************************  
* PROCEDURE	: dbo.Operator_Drill_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: jrodulfa, 26 Apr 2023
* SAMPLE	: 
	1. EXEC dbo.Operator_Drill_Get 'PREV', 'BAG'
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {26 Apr 2023}		{jrodulfa}		{Initial Created}  
* {27 Oct 2023}		{ggosal1}		{MVP 8.2}  
* {22 Jan 2024}		{lwasini}		{Add TYR}  
* {24 Jan 2024}		{lwasini}		{Add ABR}  
*******************************************************************/ 
CREATE PROCEDURE [dbo].[Operator_Drill_Get] 
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

BEGIN TRY

	IF @SITE = 'BAG'
	BEGIN
		SELECT [shiftflag]
			  ,[siteflag]
			  ,[OPERATORID]
			  ,[OperatorName]
			  ,[OperatorImageURL]
			  ,[DRILL_ID]
			  ,[PATTERN_NO]
			  ,[FeetDrilledActual]
			  ,[FeetDrilledTarget]
			  ,[AvgUseofAvailActual]
			  ,[AvgUseofAvailTarget]
			  ,[PenetrationRateActual]
			  ,[PenetrationRateTarget]
			  ,[HolesDrilledActual]
			  ,[HolesDrilledTarget]
			  ,[AvgTimeBnHolesActual]
			  ,[AvgTimeBnHolesTarget]
			  ,[AvgDrillingTimeActual]
			  ,[AvgDrillingTimeTarget]
			  ,[PerformanceMatrixActual]
			  ,[PerformanceMatrixTarget]
			  ,[XyDrillScoreActual]
			  ,[XyDrillScoreTarget]
			  ,[DepthDrillActual]
			  ,[DepthDrillTarget]
			  ,[OverDrilledActual]
			  ,[OverDrilledTarget]
			  ,[UnderDrilledActual]
			  ,[UnderDrilledTarget]
			  ,[GPSQualityActual]
			  ,[GPSQualityTarget]
			  ,[AvgFirstLastDrillActual]
			  ,[AvgFirstLastDrillTarget]
			  ,[AvgFirstDrillActual]
			  ,[AvgFirstDrillTarget]
			  ,[AvgLastDrillActual]
			  ,[AvgLastDrillTarget]
			  ,[Status]
			  ,[eqmtcurrstatus] AS [EqmtStatus]
		  FROM [bag].[CONOPS_BAG_OPERATOR_DRILL_LIST_V]
		  WHERE shiftflag = @SHIFT
			    AND siteflag =  @SITE;
	END

	ELSE IF @SITE = 'CER'
	BEGIN
		SELECT [shiftflag]
			  ,[siteflag]
			  ,[OPERATORID]
			  ,[OperatorName]
			  ,[OperatorImageURL]
			  ,[DRILL_ID]
			  ,[PATTERN_NO]
			  ,[FeetDrilledActual]
			  ,[FeetDrilledTarget]
			  ,[AvgUseofAvailActual]
			  ,[AvgUseofAvailTarget]
			  ,[PenetrationRateActual]
			  ,[PenetrationRateTarget]
			  ,[HolesDrilledActual]
			  ,[HolesDrilledTarget]
			  ,[AvgTimeBnHolesActual]
			  ,[AvgTimeBnHolesTarget]
			  ,[AvgDrillingTimeActual]
			  ,[AvgDrillingTimeTarget]
			  ,[PerformanceMatrixActual]
			  ,[PerformanceMatrixTarget]
			  ,[XyDrillScoreActual]
			  ,[XyDrillScoreTarget]
			  ,[DepthDrillActual]
			  ,[DepthDrillTarget]
			  ,[OverDrilledActual]
			  ,[OverDrilledTarget]
			  ,[UnderDrilledActual]
			  ,[UnderDrilledTarget]
			  ,[GPSQualityActual]
			  ,[GPSQualityTarget]
			  ,[AvgFirstLastDrillActual]
			  ,[AvgFirstLastDrillTarget]
			  ,[AvgFirstDrillActual]
			  ,[AvgFirstDrillTarget]
			  ,[AvgLastDrillActual]
			  ,[AvgLastDrillTarget]
			  ,[Status]
			  ,[eqmtcurrstatus] AS [EqmtStatus]
		  FROM [cer].[CONOPS_CER_OPERATOR_DRILL_LIST_V]
		  WHERE shiftflag = @SHIFT
			    AND siteflag =  @SITE;
	END

	ELSE IF @SITE = 'CHI'
	BEGIN
		SELECT [shiftflag]
			  ,[siteflag]
			  ,[OPERATORID]
			  ,[OperatorName]
			  ,[OperatorImageURL]
			  ,[DRILL_ID]
			  ,[PATTERN_NO]
			  ,[FeetDrilledActual]
			  ,[FeetDrilledTarget]
			  ,[AvgUseofAvailActual]
			  ,[AvgUseofAvailTarget]
			  ,[PenetrationRateActual]
			  ,[PenetrationRateTarget]
			  ,[HolesDrilledActual]
			  ,[HolesDrilledTarget]
			  ,[AvgTimeBnHolesActual]
			  ,[AvgTimeBnHolesTarget]
			  ,[AvgDrillingTimeActual]
			  ,[AvgDrillingTimeTarget]
			  ,[PerformanceMatrixActual]
			  ,[PerformanceMatrixTarget]
			  ,[XyDrillScoreActual]
			  ,[XyDrillScoreTarget]
			  ,[DepthDrillActual]
			  