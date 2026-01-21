

/******************************************************************  
* PROCEDURE	: dbo.LoadAndHaulTP_DeltaC_Component_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: ggosal1, 27 Feb 2025
* SAMPLE	: 
	1. EXEC dbo.LoadAndHaulTP_DeltaC_Component_Get 'CURR', 'MOR', 'EN'
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {27 Feb 2025}		{ggosal1}		{Initial Created}
* {14 Mar 2025}		{ggosal1}		{Add LastLoadCount, Change ContributionDeltaC to ContributionDeltaC}
* {20 Mar 2025}		{ggosal1}		{Add Espanol Language}
*******************************************************************/ 
CREATE PROCEDURE [dbo].[LoadAndHaulTP_DeltaC_Component_Get] 
(	
	@SHIFT VARCHAR(4),
	@SITE VARCHAR(4),
	@LANG CHAR(2)
)
AS                        
BEGIN    

BEGIN TRY
	
	IF @SITE = 'BAG' AND @LANG = 'EN'
	BEGIN

		SELECT
			TOP 10
			Component,
			ActionAt,
			PlotName,
			ROUND(MinsOverExpected, 1) AS MinsOverExpected,
			CycleCount,
			ROUND(ComponentDeltaC, 1) AS ComponentDeltaC,
			ROUND(ContributionDeltaC, 1) AS ContributionDeltaC
		FROM BAG.CONOPS_BAG_DELTA_C_COMPONENT_V
		WHERE shiftflag = @SHIFT
		ORDER BY MinsOverExpected DESC;

		SELECT 
			SUM(CycleCount) AS LastLoadsCount
		FROM BAG.CONOPS_BAG_DELTA_C_COMPONENT_V
		WHERE shiftflag = @SHIFT
		AND Component = 'Loading'


	END

	ELSE IF @SITE = 'BAG' AND @LANG = 'ES'
	BEGIN

		SELECT
			TOP 10
			CASE Component
				WHEN 'Queueing' THEN 'Cola'
				WHEN 'Spotting' THEN 'Cuadre'
				WHEN 'Loading' THEN 'CarguÃ­o'
				WHEN 'Full Travel' THEN 'Viaje Lleno'
				WHEN 'Dumping' THEN 'Descarga'
				WHEN 'Empty Travel' THEN 'Viaje VacÃ­o'
			END AS Component,
			ActionAt,
			PlotName,
			ROUND(MinsOverExpected, 1) AS MinsOverExpected,
			CycleCount,
			ROUND(ComponentDeltaC, 1) AS ComponentDeltaC,
			ROUND(ContributionDeltaC, 1) AS ContributionDeltaC
		FROM BAG.CONOPS_BAG_DELTA_C_COMPONENT_V
		WHERE shiftflag = @SHIFT
		ORDER BY MinsOverExpected DESC;

		SELECT 
			SUM(CycleCount) AS LastLoadsCount
		FROM BAG.CONOPS_BAG_DELTA_C_COMPONENT_V
		WHERE shiftflag = @SHIFT
		AND Component = 'Loading'


	END

	ELSE IF @SITE = 'CVE' AND @LANG = 'EN'
	BEGIN

		SELECT
			TOP 10
			Component,
			ActionAt,
			PlotName,
			ROUND(MinsOverExpected, 1) AS MinsOverExpected,
			CycleCount,
			ROUND(ComponentDeltaC, 1) AS ComponentDeltaC,
			ROUND(ContributionDeltaC, 1) AS ContributionDeltaC
		FROM CER.CONOPS_CER_DELTA_C_COMPONENT_V
		WHERE shiftflag = @SHIFT
		ORDER BY MinsOverExpected DESC;

		SELECT 
			SUM(CycleCount) AS LastLoadsCount
		FROM CER.CONOPS_CER_DELTA_C_COMPONENT_V
		WHERE shiftflag = @SHIFT
		AND Component = 'Loading'


	END

	ELSE IF @SITE = 'CVE' AND @LANG = 'ES'
	BEGIN

		SELECT
			TOP 10
			CASE Component
				WHEN 'Queueing' THEN 'Cola'
				WHEN 'Spotting' THEN 'Cuadre'
				WHEN 'Loading' THEN 'CarguÃ­o'
				WHEN 'Full Travel' THEN 'Viaje Lleno'
				WHEN 'Dumping' THEN 'Descarga'
				WHEN 'Empty Travel' THEN 'Viaje VacÃ­o'
			END AS Component,
			ActionAt,
			PlotName,
			ROUND(MinsOverExpected, 1) AS MinsOverExpected,
			CycleCount,
			ROUND(ComponentDeltaC, 1) AS ComponentDeltaC,
			ROUND(ContributionDeltaC, 1) AS ContributionDeltaC
		FROM CER.CONOPS_CER_DELTA_C_COMPONENT_V
		WHERE shiftflag = @SHIFT
		ORDER BY MinsOverExpected DESC;

		SELECT 
			SUM(CycleCount) AS LastLoadsCount
		FROM CER.CONOPS_CER_DELTA_C_COMPONENT_V
		WHERE shiftflag = @SHIFT
		AND Component = 'Loading'


	END

	ELSE IF @SITE = 'CHN' AND @LANG = 'EN'
	BEGIN

		SELECT
			TOP 10
			Component,
			ActionAt,
			PlotName,
			ROUND(MinsOverExpected, 1) AS MinsOverExpected,
			CycleCount,
			ROUND(ComponentDeltaC, 1) AS ComponentDeltaC,
			ROUND(ContributionDeltaC, 1) AS ContributionDeltaC
		FROM CHI.CONOPS_CHI_DELTA_C_COMPONENT_V
		WHERE shiftflag = @SHIFT
		ORDER BY MinsOverExpected DESC;

		SELECT 
			SUM(CycleCount) AS L