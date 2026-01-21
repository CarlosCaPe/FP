
/******************************************************************  
* PROCEDURE	: dbo.LoadAndHaulOverview_TotalMaterialMovedByShovelBarChart_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: lwasini, 25 Jul 2023
* SAMPLE	: 
	1. EXEC dbo.LoadAndHaulOverview_TotalMaterialMovedByShovelBarChart_Get 'CURR', 'BAG', NULL
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {25 Jul 2023}	 {lwasini}	{Initial Created} 
* {09 Aug 2023}  {lwasini}  {Update GPSElevation to NULL} 
* {15 Nov 2023}	 {ggosal1}  {Update to RIGHT join to Shovel Info, to display all shovels} 
* {17 Nov 2023}	 {lwasini}  {Add GPSElevation} 
* {24 Nov 2023}	 {lwasini}  {Add Filter Material Type & OperatorId}
* {12 Dec 2023}	 {lwasini}  {Add Filter List} 
* {10 jan 2024}	 {lwasini}  {Add TYR} 
* {23 Jan 2024}	 {lwasini}	{Add ABR}
*******************************************************************/ 
CREATE PROCEDURE [dbo].[LoadAndHaulOverview_TotalMaterialMovedByShovelBarChart_Get] 
(	
	@SHIFT VARCHAR(4),
	@SITE VARCHAR(4),
	@MTRL VARCHAR(12)
)
AS                        
BEGIN          

BEGIN TRY

	IF @SITE = 'BAG'
	BEGIN
	
	-- FIlter List
		SELECT DISTINCT 
		MaterialMined
		FROM (
		SELECT 
		shiftid, 
		shovelid, 
		MaterialMined,
		ISNULL(TotalMined,0) TotalMined
		FROM [bag].[CONOPS_BAG_SHIFT_OVERVIEW_V] 
		CROSS APPLY (VALUES ('Waste', wastemined),
							('Mill', MillOreMined))
		CrossApplied (MaterialMined, TotalMined)
		) x;
	
	IF @MTRL IS NULL
	BEGIN
		SELECT
			b.ShovelId,
			ROUND(sum(a.TotalMaterialMoved)/1000,1) as Actual,
			ROUND(a.TotalMaterialMovedShiftTarget/1000,1) as [ShiftTarget],
			ROUND(sum(a.TotalMaterialMovedTarget)/1000,1) as [Target],
			b.Operator AS OperatorName,
			b.OperatorImageURL AS ImageUrl,
			b.OperatorId,
			ShovelElevation AS GPSElevation
		FROM [BAG].[CONOPS_BAG_OVERVIEW_V] a (NOLOCK)
		RIGHT JOIN BAG.[CONOPS_BAG_SHOVEL_INFO_V] b
		ON a.shiftflag = b.shiftflag AND a.Shovelid = b.ShovelID AND a.siteflag = b.siteflag
		LEFT JOIN [BAG].[CONOPS_BAG_GPS_ELEVATION_V] c ON a.shiftflag = c.shiftflag AND a.ShovelId = c.shovelId
		WHERE b.shiftflag = @SHIFT
		GROUP BY b.ShovelId,b.Operator,b.OperatorImageURL,b.OperatorId,ShovelElevation,
		TotalMaterialMoved,TotalMaterialMovedShiftTarget
		ORDER BY b.ShovelId
	END

	ELSE IF @MTRL IS NOT NULL
	BEGIN
		SELECT
			b.ShovelId,
			ROUND(sum(a.TotalMaterialMoved)/1000,1) as Actual,
			ROUND(a.TotalMaterialMovedShiftTarget/1000,1) as [ShiftTarget],
			ROUND(sum(a.TotalMaterialMovedTarget)/1000,1) as [Target],
			b.Operator AS OperatorName,
			b.OperatorImageURL AS ImageUrl,
			b.OperatorId,
			ShovelElevation AS GPSElevation
		FROM [BAG].[CONOPS_BAG_OVERVIEW_V] a (NOLOCK)
		RIGHT JOIN BAG.[CONOPS_BAG_SHOVEL_INFO_V] b
		ON a.shiftflag = b.shiftflag AND a.Shovelid = b.ShovelID AND a.siteflag = b.siteflag
		LEFT JOIN [BAG].[CONOPS_BAG_GPS_ELEVATION_V] c ON a.shiftflag = c.shiftflag AND a.ShovelId = c.shovelId
		WHERE b.shiftflag = @SHIFT
		GROUP BY b.ShovelId,b.Operator,b.OperatorImageURL,b.OperatorId,ShovelElevation,
		TotalMaterialMoved,TotalMaterialMovedShiftTarget
		ORDER BY b.ShovelId
	END

	END

	ELSE IF @SITE = 'CVE'
	BEGIN

		-- FIlter List
		SELECT DISTINCT 
		MaterialMined
		FROM (
		SELECT shiftid, shovelid, MaterialMined,ISNULL(TotalMined,0) TotalMined
		FROM [cer].[CONOPS_CER_SHIFT_OVERVIEW_V] 
		CROSS APPLY (VALUES ('Waste', WasteMined),
                    ('Mill', MillMined),
					('ROM', ROMMined))
		CrossApplied (MaterialMined, TotalMined)
		) x;

		IF @MTRL IS NULL
		BEGIN
		SELECT
			b.ShovelId,
			ROUND(sum(a.TotalMaterialMoved)/1000,1) as Actual,
			ROUND(a.ShiftTarget/1000,1) as [ShiftTarget],
			ROUND(sum(a.shoveltarget)/1000,1) as [Target],
			b.Operator AS OperatorName,
			b.OperatorImageURL AS ImageUrl,
			b.OperatorId,
			ShovelElevation AS GPSElevation
		FROM CER.[CONOPS_CER_OVERVIEW_V] a (NOL