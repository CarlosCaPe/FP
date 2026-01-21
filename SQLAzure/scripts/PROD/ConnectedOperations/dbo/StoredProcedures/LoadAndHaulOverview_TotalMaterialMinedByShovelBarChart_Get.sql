

/******************************************************************    
* PROCEDURE : dbo.LoadAndHaulOverview_TotalMaterialMinedByShovelBarChart_Get  
* PURPOSE : To get CDC of table mor.ShiftInfo  
* NOTES  : Using by job_conops_shoft_info  
* CREATED : lwasini, 25 Oct 2022  
* SAMPLE :   
 1. EXEC dbo.LoadAndHaulOverview_TotalMaterialMinedByShovelBarChart_Get 'CURR', 'CVE',NULL
   
* MODIFIED DATE     AUTHOR   DESCRIPTION    
*------------------------------------------------------------------    
* {25 Oct 2022}  {lwasini}  {Initial Created}   
* {16 Nov 2022}  {sxavier}  {Add ShiftTarget field}   
* {13 Jun 2023}  {lwasini}  {Add GPS Elevation}  
* {04 Aug 2023}  {mfahmi}   {Switch GPS Elevation source with extension view} 
* {09 Aug 2023}	 {lwasini}  {Update GPSElevation to NULL} 
* {15 Nov 2023}	 {ggosal1}  {Update to RIGHT join to Shovel Info, to display all shovels} 
* {17 Nov 2023}	 {lwasini}  {Add GPSElevation} 
* {22 Nov 2023}	 {lwasini}  {Add Filter Material Type & OperatorId} 
* {12 Dec 2023}	 {lwasini}  {Add Filter List} 
* {10 jan 2024}	 {lwasini}  {Add TYR} 
* {23 Jan 2024}	 {lwasini}	{Add ABR} 
*******************************************************************/   
CREATE PROCEDURE [dbo].[LoadAndHaulOverview_TotalMaterialMinedByShovelBarChart_Get]   
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
	   ROUND(sum(a.TotalMaterialMined)/1000,1) as Actual,  
	   ROUND(a.ShiftTarget/1000,1) as [ShiftTarget],  
	   ROUND(sum(a.shoveltarget)/1000,1) as [Target],  
	   b.Operator AS OperatorName,  
	   b.OperatorImageURL AS ImageUrl,  
	   b.OperatorId,
	   ShovelElevation AS GPSElevation
	  FROM [BAG].[CONOPS_BAG_OVERVIEW_V] a (NOLOCK)  
	  RIGHT JOIN BAG.[CONOPS_BAG_SHOVEL_INFO_V] b  
	  ON a.shiftflag = b.shiftflag AND a.Shovelid = b.ShovelID AND a.siteflag = b.siteflag  
	  LEFT JOIN [BAG].[CONOPS_BAG_GPS_ELEVATION_V] c ON a.shiftflag = c.shiftflag AND a.ShovelId = c.shovelId  
	  WHERE b.shiftflag = @SHIFT  
	  GROUP BY b.ShovelId,a.ShiftTarget,b.Operator,b.OperatorImageURL,b.OperatorId,ShovelElevation  
	  ORDER BY b.ShovelId
	END
	ELSE IF @MTRL IS NOT NULL
	BEGIN
	
		SELECT
		b.shovelid,
		ROUND(SUM(TotalMined)/1000.0,1) AS Actual,
		ROUND(d.ShiftTarget/1000,1) as [ShiftTarget],  
		ROUND(SUM(d.shoveltarget)/1000,1) as [Target],  
		b.Operator AS OperatorName,  
		b.OperatorImageURL AS ImageUrl,  
		b.OperatorId,
		ShovelElevation AS GPSElevation
		FROM (
		SELECT shiftid, shovelid, MaterialMined,ISNULL(TotalMined,0) TotalMined
		FROM [bag].[CONOPS_BAG_SHIFT_OVERVIEW_V] 
		CROSS APPLY (VALUES ('Waste', wastemined),
                    ('Mill', MillOreMined))
		CrossApplied (MaterialMined, TotalMined)
		) c
		RIGHT JOIN [bag].[CONOPS_BAG_SHOVEL_INFO_V] b
		ON c.shiftid = b.shiftid AND b.ShovelID = c.ShovelId
		LEFT JOIN [bag].[CONOPS_BAG_OVERVIEW_V] d
		ON c.shiftid = d.shiftid AND c.ShovelId = d.ShovelId
		LEFT JOIN [bag].[CONOPS_BAG_GPS_ELEVATION_V] e
		ON b.shiftflag = e.shiftflag AND c.ShovelId = e.shovelId  
		WHERE 
		b.SHIFTFLAG = @SHIFT
		AND (MaterialMined IN (SELECT TRIM(value) FROM STRING_SPLIT(@MTRL, ',')) OR ISNULL(@MTRL, '') = '')
		GROUP BY b.shovelid,d.ShiftTarget,b.Operator,b.OperatorImageURL,b.OperatorId,ShovelElevation
		END
  
 END  
  
 ELSE IF @SITE = 'CVE'  
 BEGIN  
  
	-- FIlter List
		SELECT DISTINCT 
		MaterialMined
		FROM (
		SELECT shiftid, shovelid, MaterialMined,ISNULL(TotalMined,0) TotalMined