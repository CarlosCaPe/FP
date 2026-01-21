





/******************************************************************  
* PROCEDURE	: dbo.EOS_LineUp_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: lwasini, 22 Jun 2023
* SAMPLE	: 
	1. EXEC dbo.EOS_LineUp_Get 'PREV', 'MOR'
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {22 Jun 2023}		{lwasini}		{Initial Created}  
*******************************************************************/ 
CREATE PROCEDURE [dbo].[EOS_LineUp_Get] 
(	
	@SHIFT VARCHAR(4),
	@SITE VARCHAR(4)
)
AS                        
BEGIN  
	
	IF @SITE = 'BAG'
	BEGIN
		SELECT 
		Equipment,
		EquipmentAvailable
		FROM [bag].[CONOPS_BAG_EOS_LINEUP_EQUIPMENT_V] 
		WHERE shiftflag = @SHIFT


	END

	ELSE IF @SITE = 'CVE'
	BEGIN
		SELECT 
		Equipment,
		EquipmentAvailable
		FROM [cer].[CONOPS_CER_EOS_LINEUP_EQUIPMENT_V] 
		WHERE shiftflag = @SHIFT

	END
		
	ELSE IF @SITE = 'CHN'
	BEGIN
		SELECT 
		Equipment,
		EquipmentAvailable
		FROM [chi].[CONOPS_CHI_EOS_LINEUP_EQUIPMENT_V] 
		WHERE shiftflag = @SHIFT

	END
		
	ELSE IF @SITE = 'CMX'
	BEGIN
		SELECT 
		Equipment,
		EquipmentAvailable
		FROM [cli].[CONOPS_CLI_EOS_LINEUP_EQUIPMENT_V] 
		WHERE shiftflag = @SHIFT

	END
		
	ELSE IF @SITE = 'MOR'
	BEGIN
		SELECT 
		Equipment,
		EquipmentAvailable
		FROM [mor].[CONOPS_MOR_EOS_LINEUP_EQUIPMENT_V] 
		WHERE shiftflag = @SHIFT

	END
		
	ELSE IF @SITE = 'SAM'
	BEGIN
		SELECT 
		Equipment,
		EquipmentAvailable
		FROM [saf].[CONOPS_SAF_EOS_LINEUP_EQUIPMENT_V] 
		WHERE shiftflag = @SHIFT


	END
		
	ELSE IF @SITE = 'SIE'
	BEGIN
		SELECT 
		Equipment,
		EquipmentAvailable
		FROM [sie].[CONOPS_SIE_EOS_LINEUP_EQUIPMENT_V] 
		WHERE shiftflag = @SHIFT

	END


	
	

SET NOCOUNT OFF
END



