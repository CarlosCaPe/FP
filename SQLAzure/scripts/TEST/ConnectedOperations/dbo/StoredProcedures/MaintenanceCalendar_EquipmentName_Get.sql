


/******************************************************************  
* PROCEDURE	: dbo.MaintenanceCalendar_EquipmentName_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: sxavier, 08 Aug 2023
* SAMPLE	: 
	1. EXEC dbo.MaintenanceCalendar_EquipmentName_Get 'MOR', '1'

* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {08 Aug 2023}		{sxavier}		{Initial Created}
* {08 Aug 2023}		{ywibowo}		{Code Review}
*******************************************************************/ 
CREATE PROCEDURE [dbo].[MaintenanceCalendar_EquipmentName_Get] 
(	
	@SiteCode CHAR(3),
	@EquipmentTypeCode VARCHAR(8)
)
AS                        
BEGIN          
	SET NOCOUNT ON
		
		IF @SiteCode = 'BAG'
		BEGIN
			SELECT
				A.EquipmentId AS [Name]
			FROM
				[bag].[CONOPS_BAG_MC_EQUIPMENT_V] A
			WHERE
				A.EquipmentTypeCode = @EquipmentTypeCode
			ORDER BY 
				A.EquipmentId
		END

		ELSE IF @SiteCode = 'CVE'
		BEGIN
			SELECT
				A.EquipmentId AS [Name]
			FROM
				[cer].[CONOPS_CER_MC_EQUIPMENT_V] A
			WHERE
				A.EquipmentTypeCode = @EquipmentTypeCode
			ORDER BY 
				A.EquipmentId
		END

		ELSE IF @SiteCode = 'CHN'
		BEGIN
			SELECT
				A.EquipmentId AS [Name]
			FROM
				[chi].[CONOPS_CHI_MC_EQUIPMENT_V] A
			WHERE
				A.EquipmentTypeCode = @EquipmentTypeCode
			ORDER BY 
				A.EquipmentId
		END

		ELSE IF @SiteCode = 'CMX'
		BEGIN
			SELECT
				A.EquipmentId AS [Name]
			FROM
				[cli].[CONOPS_CLI_MC_EQUIPMENT_V] A
			WHERE
				A.EquipmentTypeCode = @EquipmentTypeCode
			ORDER BY 
				A.EquipmentId
		END

		ELSE IF @SiteCode = 'MOR'
		BEGIN
			SELECT
				A.EquipmentId AS [Name]
			FROM
				[mor].[CONOPS_MOR_MC_EQUIPMENT_V] A
			WHERE
				A.EquipmentTypeCode = @EquipmentTypeCode
			ORDER BY 
				A.EquipmentId
		END

		ELSE IF @SiteCode = 'SAM'
		BEGIN
			SELECT
				A.EquipmentId AS [Name]
			FROM
				[saf].[CONOPS_SAF_MC_EQUIPMENT_V] A
			WHERE
				A.EquipmentTypeCode = @EquipmentTypeCode
			ORDER BY 
				A.EquipmentId
		END

		ELSE IF @SiteCode = 'SIE'
		BEGIN
			SELECT
				A.EquipmentId AS [Name]
			FROM
				[sie].[CONOPS_SIE_MC_EQUIPMENT_V] A
			WHERE
				A.EquipmentTypeCode = @EquipmentTypeCode
			ORDER BY 
				A.EquipmentId
		END

	SET NOCOUNT OFF
END
