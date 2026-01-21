




/******************************************************************  
* PROCEDURE	: dbo.EOS_TruckOperatorLateStart_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: lwasini, 15 Jun 2023
* SAMPLE	: 
	1. EXEC dbo.EOS_TruckOperatorLateStart_Get 'PREV', 'BAG'
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {15 Jun 2023}		{lwasini}		{Initial Created} 
*******************************************************************/ 
CREATE PROCEDURE [dbo].[EOS_TruckOperatorLateStart_Get] 
(	
	@SHIFT VARCHAR(4),
	@SITE VARCHAR(4)
)
AS                        
BEGIN          
	
	IF @SITE = 'BAG'
	BEGIN
		SELECT REGION,
			   LateStart
		FROM (
		SELECT REGION
			  ,count(b.eqmtid) AS LateStart
		FROM [bag].[CONOPS_BAG_TRUCK_DETAIL_V] a
		LEFT JOIN [bag].[CONOPS_BAG_OPERATOR_HAS_LATE_START_V] b
		ON a.shiftflag = b.shiftflag AND a.TruckID = b.eqmtid AND b.unit_code = 1
		WHERE a.shiftflag = @SHIFT AND a.SiteFlag = @SITE
		GROUP BY a.shiftflag, region) c
		WHERE LateStart <> 0;
		

	END

	ELSE IF @SITE = 'CVE'
	BEGIN
		
		SELECT REGION,
			   LateStart
		FROM (
		SELECT REGION
			  ,count(b.eqmtid) AS LateStart
		FROM [cer].[CONOPS_CER_TRUCK_DETAIL_V] a
		LEFT JOIN [cer].[CONOPS_CER_OPERATOR_HAS_LATE_START_V] b
		ON a.shiftflag = b.shiftflag AND a.TruckID = b.eqmtid AND b.unit_code = 1
		WHERE a.shiftflag = @SHIFT AND a.SiteFlag = @SITE
		GROUP BY a.shiftflag, region ) c
		WHERE LateStart <> 0;

	END

	ELSE IF @SITE = 'CHN'
	BEGIN

		SELECT REGION,
			   LateStart
		FROM (
		SELECT REGION
			  ,count(b.eqmtid) AS LateStart
		FROM [chi].[CONOPS_CHI_TRUCK_DETAIL_V] a
		LEFT JOIN [chi].[CONOPS_CHI_OPERATOR_HAS_LATE_START_V] b
		ON a.shiftflag = b.shiftflag AND a.TruckID = b.eqmtid AND b.unit_code = 1
		WHERE a.shiftflag = @SHIFT AND a.SiteFlag = @SITE
		GROUP BY a.shiftflag, region ) c
		WHERE LateStart <> 0;

	END

	ELSE IF @SITE = 'CMX'
	BEGIN

		SELECT REGION,
			   LateStart
		FROM (
		SELECT REGION
			  ,count(b.eqmtid) AS LateStart
		FROM [cli].[CONOPS_CLI_TRUCK_DETAIL_V] a
		LEFT JOIN [cli].[CONOPS_CLI_OPERATOR_HAS_LATE_START_V] b
		ON a.shiftflag = b.shiftflag AND a.TruckID = b.eqmtid AND b.unit_code = 1
		WHERE a.shiftflag = @SHIFT AND a.SiteFlag = @SITE
		GROUP BY a.shiftflag, region) c
		WHERE LateStart <> 0;

	END

	ELSE IF @SITE = 'MOR'
	BEGIN

		SELECT REGION,
			   LateStart
		FROM (
		SELECT REGION
			  ,count(b.eqmtid) AS LateStart
		FROM [mor].[CONOPS_MOR_TRUCK_DETAIL_V] a
		LEFT JOIN [mor].[CONOPS_MOR_OPERATOR_HAS_LATE_START_V] b
		ON a.shiftflag = b.shiftflag AND a.TruckID = b.eqmtid AND b.unit_code = 1
		WHERE a.shiftflag = @SHIFT AND a.SiteFlag = @SITE
		GROUP BY a.shiftflag, region) c
		WHERE LateStart <> 0;

	END

	ELSE IF @SITE = 'SAM'
	BEGIN

		SELECT REGION,
			   LateStart
		FROM (
		SELECT REGION
			  ,count(b.eqmtid) AS LateStart
		FROM [saf].[CONOPS_SAF_TRUCK_DETAIL_V] a
		LEFT JOIN [saf].[CONOPS_SAF_OPERATOR_HAS_LATE_START_V] b
		ON a.shiftflag = b.shiftflag AND a.TruckID = b.eqmtid AND b.unit_code = 1
		WHERE a.shiftflag = @SHIFT AND a.SiteFlag = @SITE
		GROUP BY a.shiftflag, region) c
		WHERE LateStart <> 0;

	END

	ELSE IF @SITE = 'SIE'
	BEGIN

		SELECT REGION,
			   LateStart
		FROM (
		SELECT REGION
			  ,count(b.eqmtid) AS LateStart
		FROM [sie].[CONOPS_SIE_TRUCK_DETAIL_V] a
		LEFT JOIN [sie].[CONOPS_SIE_OPERATOR_HAS_LATE_START_V] b
		ON a.shiftflag = b.shiftflag AND a.TruckID = b.eqmtid AND b.unit_code = 1
		WHERE a.shiftflag = @SHIFT AND a.SiteFlag = @SITE
		GROUP BY a.shiftflag, region) c
		WHERE LateStart <> 0;

	END

END



