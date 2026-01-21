



/******************************************************************  
* PROCEDURE	: dbo.EWS_TruckShovelOverview_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: lwasini, 31 Mar 2023
* SAMPLE	: 
	1. EXEC dbo.EWS_TruckShovelOverview_Get 'CURR', 'BAG'
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {31 Mar 2023}		{lwasini}		{Initial Created} 
* {01 Mar 2024}		{lwasini}		{Display 0 for Other Site} 
* {06 Jan 2025}		{ggosal1}		{Handling Site Code} 
*******************************************************************/ 
CREATE PROCEDURE [dbo].[EWS_TruckShovelOverview_Get] 
(	
	@SHIFT VARCHAR(4),
	@SITE VARCHAR(4)
)
AS                        
BEGIN          

SET @SITE = dbo.GetSiteOssID(@SITE)

IF @SITE NOT IN ('BAG','CVE','CHN','CMX','MOR','SAM','SIE')
BEGIN

		SELECT 
		'TRUCK' Equipment, 
		0 TPHPayload,
		0 Delay,
		0 Down,
		0 Ready,
		0 Spare,
		0 Efficiency,
		0 Availability,
		0 UseOfAvailability

		UNION ALL

		SELECT 
		'SHOVEL' Equipment, 
		0 TPHPayload,
		0 Delay,
		0 Down,
		0 Ready,
		0 Spare,
		0 Efficiency,
		0 Availability,
		0 UseOfAvailability
		
END


ELSE IF @SITE = 'BAG'
BEGIN

		SELECT 
		Equipment, 
		TPHPayload,
		ISNULL(Delay,0) Delay,
		ISNULL(Down,0) Down,
		ISNULL(Ready,0) Ready,
		ISNULL(Spare,0) Spare,
		ISNULL(Efficiency,0) Efficiency,
		ISNULL(Availability,0) Availability,
		ISNULL(UseOfAvailability,0) UseOfAvailability
		FROM [BAG].[EWS_BAG_TRUCK_SHOVEL_OVERVIEW_V] 
		WHERE shiftflag = @SHIFT
END


ELSE IF @SITE = 'CVE'
BEGIN

		SELECT 
		Equipment, 
		TPHPayload,
		ISNULL(Delay,0) Delay,
		ISNULL(Down,0) Down,
		ISNULL(Ready,0) Ready,
		ISNULL(Spare,0) Spare,
		ISNULL(Efficiency,0) Efficiency,
		ISNULL(Availability,0) Availability,
		ISNULL(UseOfAvailability,0) UseOfAvailability
		FROM [CER].[EWS_CER_TRUCK_SHOVEL_OVERVIEW_V] 
		WHERE shiftflag = @SHIFT
END


ELSE IF @SITE = 'CHN'
BEGIN

		SELECT 
		Equipment, 
		TPHPayload,
		ISNULL(Delay,0) Delay,
		ISNULL(Down,0) Down,
		ISNULL(Ready,0) Ready,
		ISNULL(Spare,0) Spare,
		ISNULL(Efficiency,0) Efficiency,
		ISNULL(Availability,0) Availability,
		ISNULL(UseOfAvailability,0) UseOfAvailability
		FROM [CHI].[EWS_CHI_TRUCK_SHOVEL_OVERVIEW_V] 
		WHERE shiftflag = @SHIFT
END


ELSE IF @SITE = 'CMX'
BEGIN

		SELECT 
		Equipment, 
		TPHPayload,
		ISNULL(Delay,0) Delay,
		ISNULL(Down,0) Down,
		ISNULL(Ready,0) Ready,
		ISNULL(Spare,0) Spare,
		ISNULL(Efficiency,0) Efficiency,
		ISNULL(Availability,0) Availability,
		ISNULL(UseOfAvailability,0) UseOfAvailability
		FROM [CLI].[EWS_CLI_TRUCK_SHOVEL_OVERVIEW_V] 
		WHERE shiftflag = @SHIFT
END


ELSE IF @SITE = 'MOR'
BEGIN

		SELECT 
		Equipment, 
		TPHPayload,
		ISNULL(Delay,0) Delay,
		ISNULL(Down,0) Down,
		ISNULL(Ready,0) Ready,
		ISNULL(Spare,0) Spare,
		ISNULL(Efficiency,0) Efficiency,
		ISNULL(Availability,0) Availability,
		ISNULL(UseOfAvailability,0) UseOfAvailability
		FROM [MOR].[EWS_MOR_TRUCK_SHOVEL_OVERVIEW_V] 
		WHERE shiftflag = @SHIFT
END


ELSE IF @SITE = 'SAM'
BEGIN

		SELECT 
		Equipment, 
		TPHPayload,
		ISNULL(Delay,0) Delay,
		ISNULL(Down,0) Down,
		ISNULL(Ready,0) Ready,
		ISNULL(Spare,0) Spare,
		ISNULL(Efficiency,0) Efficiency,
		ISNULL(Availability,0) Availability,
		ISNULL(UseOfAvailability,0) UseOfAvailability
		FROM [SAF].[EWS_SAF_TRUCK_SHOVEL_OVERVIEW_V] 
		WHERE shiftflag = @SHIFT
END


ELSE IF @SITE = 'SIE'
BEGIN

		SELECT 
		Equipment, 
		TPHPayload,
		ISNULL(Delay,0) Delay,
		ISNULL(Down,0) Down,
		ISNULL(Ready,0) Ready,
		ISNULL(Spare,0) Spare,
		ISNULL(Efficiency,0) Efficiency,
		ISNULL(Availability,0) Availability,
		ISNULL(UseOfAvailability,0) UseOfAvailability
		FROM [SIE].[EWS_SIE_TRUCK_SHOVEL_OVERVIEW_V] 
		WHERE shiftflag = @SHIFT
END

END

