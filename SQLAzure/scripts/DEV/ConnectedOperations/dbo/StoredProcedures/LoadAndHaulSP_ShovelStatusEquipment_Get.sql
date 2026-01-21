

/******************************************************************  
* PROCEDURE	: dbo.LoadAndHaulSP_ShovelStatusEquipment_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: lwasini, 25 Oct 2022
* SAMPLE	: 
	1. EXEC dbo.LoadAndHaulSP_ShovelStatusEquipment_Get 'CURR', 'MOR', NULL, NULL
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {25 Oct 2022}		{lwasini}		{Initial Created}
* {7 Dec 2022}		{sxavier}		{Rename field}
* {31 Aug 2023}		{lwasini}		{Add Equipment Type}
* {10 Nov 2023}		{lwasini}		{Add OperatorName}
* {03 Jan 2024}		{lwasini}		{Added TYR}
* {23 Jan 2024}		{lwasini}		{Add ABR}
* {17 May 2024}		{ggosal1}		{Add UseOfAvailability}
*******************************************************************/ 
CREATE PROCEDURE [dbo].[LoadAndHaulSP_ShovelStatusEquipment_Get] 
(	
	@SHIFT VARCHAR(4),
	@SITE VARCHAR(4),
	@STATUS NVARCHAR(MAX),
	@EQMT NVARCHAR(MAX)
)
AS                        
BEGIN          

BEGIN TRY

	IF @SITE = 'BAG'
	BEGIN

		SELECT 
			a.eqmt AS EquipmentName,
			a.EQMTTYPE AS EquipmentType,
			StartDateTime,
			EndDateTime,
			a.duration AS TimeInState,
			reasonidx AS Description1,
			reasons AS Description2,
			LOWER([status]) AS [Status],
			LOWER(eqmtcurrstatus) AS CurrentStatus,
			EFH AS Efficiency,
			TPRH As Tprh,
			UPPER(Operator) AS OperatorName,
			ROUND(use_of_availability_pct,2) AS UseOfAvailability
		INTO #TempTableBAG
		FROM BAG.[CONOPS_BAG_SP_EQMT_STATUS_GANTTCHART_V] a (NOLOCK)
		LEFT JOIN [BAG].[CONOPS_BAG_SHOVEL_INFO_V] b
		ON a.shiftid = b.shiftid AND a.eqmt = b.ShovelID
		LEFT JOIN [BAG].[CONOPS_BAG_SHOVEL_ASSET_EFFICIENCY_PER_SHOVEL_V] c
		ON a.shiftflag = c.shiftflag AND a.eqmt = c.eqmt
		WHERE a.shiftflag = @SHIFT
			AND (a.eqmt IN (SELECT TRIM(value) FROM STRING_SPLIT(@EQMT, ',')) OR ISNULL(@EQMT, '') = '')
			AND (eqmtcurrstatus IN (SELECT TRIM(value) FROM STRING_SPLIT(UPPER(@STATUS), ',')) OR ISNULL(@STATUS, '') = '')
			AND a.eqmt is not null;
 
		SELECT
			EquipmentName,
			EquipmentType,
			Efficiency,
			Tprh,
			CurrentStatus,
			UseOfAvailability
		FROM #TempTableBAG
		GROUP BY EquipmentName, EquipmentType, Efficiency, Tprh, CurrentStatus, UseOfAvailability

		SELECT * FROM #TempTableBAG
 
		DROP TABLE #TempTableBAG;

		SELECT SHIFTSTARTDATETIME,
		       SHIFTENDDATETIME
		FROM [bag].[CONOPS_BAG_SHIFT_INFO_V] WITH (NOLOCK)
		WHERE SHIFTFLAG = @SHIFT ;

	END

	ELSE IF @SITE = 'CVE'
	BEGIN

		SELECT 
			a.eqmt AS EquipmentName,
			a.EQMTTYPE AS EquipmentType,
			StartDateTime,
			EndDateTime,
			a.duration AS TimeInState,
			reasonidx AS Description1,
			reasons AS Description2,
			LOWER([status]) AS [Status],
			LOWER(eqmtcurrstatus) AS CurrentStatus,
			EFH AS Efficiency,
			TPRH As Tprh,
			UPPER(Operator) AS OperatorName,
			ROUND(use_of_availability_pct,2) AS UseOfAvailability
		INTO #TempTableCER
		FROM CER.[CONOPS_CER_SP_EQMT_STATUS_GANTTCHART_V] a (NOLOCK)
		LEFT JOIN [CER].[CONOPS_CER_SHOVEL_INFO_V] b
		ON a.shiftid = b.shiftid AND a.eqmt = b.ShovelID
		LEFT JOIN [CER].[CONOPS_CER_SHOVEL_ASSET_EFFICIENCY_PER_SHOVEL_V] c
		ON a.shiftflag = c.shiftflag AND a.eqmt = c.eqmt
		WHERE a.shiftflag = @SHIFT
			AND (a.eqmt IN (SELECT TRIM(value) FROM STRING_SPLIT(@EQMT, ',')) OR ISNULL(@EQMT, '') = '')
			AND (eqmtcurrstatus IN (SELECT TRIM(value) FROM STRING_SPLIT(UPPER(@STATUS), ',')) OR ISNULL(@STATUS, '') = '')
			AND a.eqmt is not null;
 
		SELECT
			EquipmentName,
			EquipmentType,
			Efficiency,
			Tprh,
			CurrentStatus,
			UseOfAvailability
		FROM #TempTableCER
		GROUP BY EquipmentName, EquipmentType, Efficiency, Tprh, CurrentStatus, UseOfAvailability

		SELECT * FROM #TempTableCER
 
		DROP TABLE #TempTableCER;

		SELECT SHIFTSTARTDATETIME,
		       SHIFTENDDATETIME
		FROM [CER].[CONOPS_CER_SHIFT_INFO_V] WITH (NOLOCK)
		WHERE SHIFTFLAG = @SHIFT ;

	END

	ELSE IF @SITE = 'CHN'
	BEGI