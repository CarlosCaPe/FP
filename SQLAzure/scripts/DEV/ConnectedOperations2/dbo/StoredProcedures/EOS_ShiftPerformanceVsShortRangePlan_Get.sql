
/******************************************************************  
* PROCEDURE	: dbo.EOS_ShiftPerformanceVsShortRangePlan_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: ggosal1, 19 May 2023
* SAMPLE	: 
	1. EXEC dbo.EOS_ShiftPerformanceVsShortRangePlan_Get 'CURR', 'ABR', 'EN', 0
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {28 June 2023}		{ggosal1}		{Initial Created} 
* {28 July 2023}		{ggosal1}		{Remove Haulage} 
* {03 Augs 2023}		{sxavier}		{Add parameter languageCode} 
* {08 Augs 2023}		{lwasini}		{Add Language Parameter}
* {07 Dec 2023}			{lwasini}		{Add Daily Summary}
* {30 Jan 2024}			{lwasini}		{Add TYR & ABR}
* {08 Feb 2024}			{ggosal1}		{Fix double value on daily EOS report}
*******************************************************************/ 
CREATE PROCEDURE [dbo].[EOS_ShiftPerformanceVsShortRangePlan_Get] 
(	
	@SHIFT VARCHAR(4),
	@SITE VARCHAR(4),
	@LANG CHAR(2),
	@DAILY INT
)
AS                        
BEGIN          

BEGIN TRY

	IF @SITE = 'BAG' AND @LANG = 'EN'
	BEGIN

		IF @DAILY = 0
		BEGIN
		--Tons Mined
		SELECT
			siteflag,
			KPI,
			ChildKPI,
			ActualValue,
			TargetValue,
			Status
		FROM [BAG].[CONOPS_BAG_EOS_TONS_MINED_V]
		WHERE shiftflag = @SHIFT
	
		--Drills
		SELECT
			siteflag,
			KPI,
			ActualValue,
			TargetValue,
			Status
		FROM [BAG].[CONOPS_BAG_EOS_DRILLED_HOLES_V]
		WHERE shiftflag = @SHIFT
	
		--Equipment Readiness
		SELECT
			siteflag,
			KPI,
			ActualValue,
			TargetValue,
			Status
		FROM [BAG].[CONOPS_BAG_EOS_EQUIPMENT_READINESS_V]
		WHERE shiftflag = @SHIFT
	
		--Asset Efficiency
		SELECT
			siteflag,
			KPI,
			ChildKPI,
			ActualValue,
			TargetValue,
			Status
		FROM [BAG].[CONOPS_BAG_EOS_ASSET_EFFICIENCY_V]
		WHERE shiftflag = @SHIFT
		END

		ELSE IF @DAILY = 1
		BEGIN
		--Tons Mined
		SELECT
			siteflag,
			KPI,
			ChildKPI,
			SUM(ActualValue) ActualValue,
			SUM(TargetValue) TargetValue,
			Status
		FROM [BAG].[CONOPS_BAG_DAILY_EOS_TONS_MINED_V]
		WHERE shiftflag = @SHIFT
		GROUP BY siteflag,KPI,ChildKPI,Status
	
		--Drills
		SELECT
			siteflag,
			KPI,
			ActualValue,
			TargetValue,
			Status
		FROM [BAG].[CONOPS_BAG_DAILY_EOS_DRILLED_HOLES_V]
		WHERE shiftflag = @SHIFT
	
		--Equipment Readiness
		SELECT
			siteflag,
			KPI,
			SUM(ActualValue) ActualValue,
			SUM(TargetValue) TargetValue,
			Status
		FROM [BAG].[CONOPS_BAG_DAILY_EOS_EQUIPMENT_READINESS_V]
		WHERE shiftflag = @SHIFT
		GROUP BY siteflag,KPI,Status
	
		--Asset Efficiency
		SELECT
			siteflag,
			KPI,
			ChildKPI,
			ActualValue,
			TargetValue,
			Status
		FROM [BAG].[CONOPS_BAG_DAILY_EOS_ASSET_EFFICIENCY_V]
		WHERE shiftflag = @SHIFT
		END

	END

	ELSE IF @SITE = 'BAG' AND @LANG = 'ES'
	BEGIN

		IF @DAILY = 0
		BEGIN
		--Tons Mined
		SELECT
			siteflag,
			CASE WHEN KPI = 'Total Material Mined' THEN 'Total Material Minado'
			WHEN KPI = 'Total Material Moved' THEN 'Total Material Movido'
			ELSE KPI END AS KPI,
			ChildKPI,
			ActualValue,
			TargetValue,
			CASE WHEN [Status] = 'Below Plan' THEN 'Bajo el Plan'
			WHEN [Status] = 'Exceeds Plan' THEN 'Sobre el Plan'
			WHEN [Status] = 'Within Plan' THEN 'Dentro del Plan'
			END AS [Status]
		FROM [BAG].[CONOPS_BAG_EOS_TONS_MINED_V]
		WHERE shiftflag = @SHIFT
	
		--Drills
		SELECT
			siteflag,
			CASE WHEN KPI = 'Drilled Holes' THEN 'Agujeros Perforados'
			END AS KPI,
			ActualValue,
			TargetValue,
			CASE WHEN [Status] = 'Below Plan' THEN 'Bajo el Plan'
			WHEN [Status] = 'Exceeds Plan' THEN 'Sobre el Plan'
			WHEN [Status] = 'Within Plan' THEN 'Dentro del Plan'
			END AS [Status]
		FROM [BAG].[CONOPS_BAG_EOS_DRILLED_HOLES_V]
		WHERE shiftflag = @SHIFT
	
		--Equipment Readiness
		SELECT
			siteflag,
			CASE WHEN KPI = 'Trucks' THEN 'Camiones'
			WHEN KPI = 'Shovels' THEN 'Palas'
			WHEN KPI = 'Drills' THEN 'Perforadoras'
