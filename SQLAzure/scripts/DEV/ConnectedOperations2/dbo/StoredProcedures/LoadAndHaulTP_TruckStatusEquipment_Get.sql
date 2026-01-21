
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
* {11 Nov 2025}		{ggosal1}		{Enhance SplitValue}
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

	DECLARE @splitEqmt [dbo].[udTT_SplitValue];
	DECLARE @splitEStat [dbo].[udTT_SplitValue];
	DECLARE @splitEType [dbo].[udTT_SplitValue];

	INSERT INTO @splitEqmt ([Value])
	SELECT TRIM([value]) FROM STRING_SPLIT(@EQMT, ',');
	
	INSERT INTO @splitEStat ([Value])
	SELECT TRIM([value]) FROM STRING_SPLIT(@STATUS, ',');
	
	INSERT INTO @splitEType ([Value])
	SELECT TRIM([value]) FROM STRING_SPLIT(@EQMTTYPE, ',');

BEGIN TRY

	IF @SITE = 'BAG'
	BEGIN
		
		DECLARE @TempTableBAG dbo.[udTT_TruckStatusEquipmentTemp];

		INSERT INTO @TempTableBAG ([EquipmentName], [EquipmentType], [StartDateTime], [EndDateTime], [TimeInState], [Description1], 
		[Description2], [Status], [CurrentStatus], [DeltaC], [AvePL], [OperatorName], [UseOfAvailability], [Autonomous])
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
		FROM BAG.[CONOPS_BAG_TP_EQMT_STATUS_GANTTCHART_V] a (NOLOCK) 
		LEFT JOIN [BAG].[CONOPS_BAG_TRUCK_DETAIL_V] b
		ON a.shiftid = b.shiftid AND a.eqmt = b.TruckID
		LEFT JOIN [BAG].[CONOPS_BAG_TRUCK_ASSET_EFFICIENCY_PER_TRUCK_V] c
		ON a.shiftflag = c.shiftflag AND a.eqmt = c.eqmt
		LEFT JOIN BAG.CONOPS_BAG_AUTONOMOUS_TRUCK_V d
		ON a.eqmt = d.TruckID
		WHERE a.shiftflag = @SHIFT
			AND (a.eqmt IN (SELECT [Value] FROM @splitEqmt) OR @EQMT IS NULL)
			AND (eqmtcurrstatus IN (SELECT [Value] FROM @splitEStat) OR @STATUS IS NULL)
			AND (a.EQMTTYPE IN (SELECT [Value] FROM @splitEType) OR @EQMTTYPE IS NULL)
			AND (d.Autonomous = @AUTONOMOUS OR @AUTONOMOUS IS NULL)
			AND a.eqmt IS NOT NULL;
	 
		SELECT
			EquipmentName,
			EquipmentType,
			ROUND(DeltaC,1) As DeltaC,
			ROUND(AvePl,0) AS AvePl,
			CurrentStatus,
			UseOfAvailability,
			Autonomous
		FROM @TempTableBAG
		GROUP BY EquipmentName, EquipmentType, DeltaC, AvePl, CurrentStatus, UseOfAvailability, Autonomous;
	 
		SELECT * FROM @TempTableBAG;

		SELECT SHIFTSTARTDATETIME,
			   SHIFTENDDATETIME
		FROM [BAG].[CONOPS_BAG_SHIFT_INFO_V] WITH (NOLOCK)
		WHERE SHIFTFLAG = @SHIFT ;

	END

	ELSE IF @SITE = 'CVE'
	BEGIN

		DECLARE @TempTableCER dbo.[udTT_TruckStatusEquipmentTemp];

		INSERT INTO @TempTableCER ([EquipmentName], [EquipmentType], [StartDateTime], [EndDateTime], [TimeInState], [Description1], 
		[Description2], [Status], [CurrentStatus], [DeltaC], [AvePL], [OperatorName], [UseOfAvailability], [Autonomous])
		SELECT 
			a.eqmt AS EquipmentName,
			a.EQMTTYPE AS EquipmentType,
			StartDateTime,
			EndDateTime,
			duration A