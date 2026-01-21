



/******************************************************************  
* PROCEDURE	: dbo.LoadAndHaulTP_TruckStatusEquipment_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: lwasini, 25 Oct 2022
* SAMPLE	: 
	1. EXEC dbo.LoadAndHaulTP_TruckStatusEquipment_Get 'PREV', 'MOR', NULL, NULL, NULL, 0
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {25 Oct 2022}		{lwasini}		{Initial Created}  
* {6 Dec 2022}		{sxavier}		{Rename field}
* {31 Aug 2022}		{lwasini}		{Add Equipment Type}
* {10 Nov 2023}		{lwasini}		{Add OperatorName}
* {03 Jan 2024}		{lwasini}		{Added TYR}
* {23 Jan 2024}     {lwasini}		{Add ABR}
* {21 May 2024}     {ggosal1}		{Add UseOfAvailability}
* {09 May 2025}		{ggosal1}		{Add Autonomous Filter}
*******************************************************************/ 
CREATE PROCEDURE [dbo].[LoadAndHaulTP_TruckStatusEquipment_Get] 
(	
	@SHIFT VARCHAR(4),
	@SITE VARCHAR(4),
	@STATUS NVARCHAR(MAX),
	@EQMT NVARCHAR(MAX),
	@EQMTTYPE NVARCHAR(MAX),
	@AUTONOMOUS INT
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
			duration AS TimeInState,
			reasonidx AS Description1,
			reasons AS Description2,
			LOWER([status]) AS [Status],
			LOWER(eqmtcurrstatus) AS CurrentStatus,
			avg_deltac AS DeltaC,
			avg_payload AS AvePl,
			UPPER(operator) AS OperatorName,
			ROUND(use_of_availability_pct,2) AS UseOfAvailability,
			Autonomous
		INTO #TempTableBAG
		FROM BAG.[CONOPS_BAG_TP_EQMT_STATUS_GANTTCHART_V] a (NOLOCK) 
		LEFT JOIN [BAG].[CONOPS_BAG_TRUCK_DETAIL_V] b
		ON a.shiftid = b.shiftid AND a.eqmt = b.TruckID
		LEFT JOIN [BAG].[CONOPS_BAG_TRUCK_ASSET_EFFICIENCY_PER_TRUCK_V] c
		ON a.shiftflag = c.shiftflag AND a.eqmt = c.eqmt
		LEFT JOIN BAG.CONOPS_BAG_AUTONOMOUS_TRUCK_V d
		ON a.eqmt = d.TruckID
		WHERE a.shiftflag = @SHIFT
			AND (a.eqmt IN (SELECT TRIM(value) FROM STRING_SPLIT(@EQMT, ',')) OR ISNULL(@EQMT, '') = '')
			AND (eqmtcurrstatus IN (SELECT TRIM(value) FROM STRING_SPLIT(UPPER(@STATUS), ',')) OR ISNULL(@STATUS, '') = '')
			AND (a.EQMTTYPE IN (SELECT TRIM(value) FROM STRING_SPLIT(@EQMTTYPE, ',')) OR ISNULL(@EQMTTYPE, '') = '')
			AND (d.Autonomous = @AUTONOMOUS OR ISNULL(@AUTONOMOUS, '') = '')
			AND a.eqmt IS NOT NULL;
	 
		SELECT
			EquipmentName,
			EquipmentType,
			ROUND(DeltaC,1) As DeltaC,
			ROUND(AvePl,0) AS AvePl,
			CurrentStatus,
			UseOfAvailability,
			Autonomous
		FROM #TempTableBAG
		GROUP BY EquipmentName, EquipmentType, DeltaC, AvePl, CurrentStatus, UseOfAvailability, Autonomous, Autonomous
	 
		SELECT * FROM #TempTableBAG
	 
		DROP TABLE #TempTableBAG;

		SELECT SHIFTSTARTDATETIME,
			   SHIFTENDDATETIME
		FROM [BAG].[CONOPS_BAG_SHIFT_INFO_V] WITH (NOLOCK)
		WHERE SHIFTFLAG = @SHIFT ;

	END

	ELSE IF @SITE = 'CVE'
	BEGIN

		SELECT 
			a.eqmt AS EquipmentName,
			a.EQMTTYPE AS EquipmentType,
			StartDateTime,
			EndDateTime,
			duration AS TimeInState,
			reasonidx AS Description1,
			reasons AS Description2,
			LOWER([status]) AS [Status],
			LOWER(eqmtcurrstatus) AS CurrentStatus,
			avg_deltac AS DeltaC,
			avg_payload AS AvePl,
			UPPER(operator) AS OperatorName,
			ROUND(use_of_availability_pct,2) AS UseOfAvailability,
			Autonomous
		INTO #TempTableCER
		FROM CER.[CONOPS_CER_TP_EQMT_STATUS_GANTTCHART_V] a (NOLOCK) 
		LEFT JOIN [CER].[CONOPS_CER_TRUCK_DETAIL_V] b
		ON a.shiftid = b.shiftid AND a.eqmt = b.TruckID
		LEFT JOIN [CER].[CONOPS_CER_TRUCK_ASSET_EFFICIENCY_PER_TRUCK_V] c
		ON a.shiftflag = c.shiftflag AND a.eqmt = c.eqmt
		LEFT JOIN CER.CONOPS_CER_AUTONOMOUS_TRUCK_V d
		ON a.eqmt = d.TruckID
		WHERE a.shiftflag = @SHIFT
			AND (a.eqmt IN (SELECT TRIM(value) FROM STRING_SPLIT(@EQMT, ',')) OR ISNULL(@EQMT, '') = '')
			AND (eqmtcurrstatus IN (SELECT TRIM(value) FROM STRING_SPLIT