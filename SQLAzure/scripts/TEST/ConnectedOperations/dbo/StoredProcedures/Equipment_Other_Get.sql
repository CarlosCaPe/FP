





/******************************************************************  
* PROCEDURE	: dbo.Equipment_Truck_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: mbote, 28 Mar 2023
* SAMPLE	: 
	1. EXEC dbo.Equipment_Other_Get 'CURR', 'CMX', NULL
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {28 Mar 2023}		{mbote}		{Initial Created}}
* {12 Jan 2024}		{lwasini}	{Add TYR}
* {23 Jan 2024}     {lwasini}	{Add ABR}
*******************************************************************/ 
CREATE PROCEDURE [dbo].[Equipment_Other_Get] 
(	
	@SHIFT VARCHAR(4),
	@SITE VARCHAR(4),
	@STATUS NVARCHAR(MAX)
)
AS                        
BEGIN      
	
	IF @SITE = 'BAG'
	BEGIN
		SELECT 
			[SupportEquipmentId],
			ISNULL([SupportEquipment], 'Unknown') [SupportEquipment],
			[StatusCode],
			[StatusName],
			[ReasonId],
			[ReasonDesc],
			[StatusStart],
			[Location],
			[Region],
			[Operator],
			[OperatorImageURL],
			[Duration]
		FROM [bag].[CONOPS_BAG_EQMT_OTHER_V]
		WHERE shiftflag = @SHIFT
		AND (StatusName IN (SELECT TRIM(value) FROM STRING_SPLIT(UPPER(@STATUS), ',')) OR ISNULL(@STATUS, '') = '');

		/*
		SELECT DISTINCT
			ISNULL([SupportEquipment], 'Unknown') [SupportEquipment]
		FROM [bag].[CONOPS_BAG_EQMT_OTHER_V]
		WHERE shiftflag = @SHIFT;
		*/
	END

	ELSE IF @SITE = 'CVE'
	BEGIN
		SELECT 
			[SupportEquipmentId],
			ISNULL([SupportEquipment], 'Unknown') [SupportEquipment],
			[StatusCode],
			[StatusName],
			[ReasonId],
			[ReasonDesc],
			[StatusStart],
			[Location],
			[Region],
			[Operator],
			[OperatorImageURL],
			[Duration]
		FROM [cer].[CONOPS_CER_EQMT_OTHER_V]
		WHERE shiftflag = @SHIFT
		AND (StatusName IN (SELECT TRIM(value) FROM STRING_SPLIT(UPPER(@STATUS), ',')) OR ISNULL(@STATUS, '') = '');

		/*
		SELECT DISTINCT
			ISNULL([SupportEquipment], 'Unknown') [SupportEquipment]
		FROM [cer].[CONOPS_CER_EQMT_OTHER_V]
		WHERE shiftflag = @SHIFT;
		*/

	END

	ELSE IF @SITE = 'CHN'
	BEGIN
		SELECT 
			[SupportEquipmentId],
			ISNULL([SupportEquipment], 'Unknown') [SupportEquipment],
			[StatusCode],
			[StatusName],
			[ReasonId],
			[ReasonDesc],
			[StatusStart],
			[Location],
			[Region],
			[Operator],
			[OperatorImageURL],
			[Duration]
		FROM [chi].[CONOPS_CHI_EQMT_OTHER_V]
		WHERE shiftflag = @SHIFT
		AND (StatusName IN (SELECT TRIM(value) FROM STRING_SPLIT(UPPER(@STATUS), ',')) OR ISNULL(@STATUS, '') = '');

		/*
		SELECT DISTINCT
			ISNULL([SupportEquipment], 'Unknown') [SupportEquipment]
		FROM [chi].[CONOPS_CHI_EQMT_OTHER_V]
		WHERE shiftflag = @SHIFT;

		*/
	END

	ELSE IF @SITE = 'CMX'
	BEGIN
		SELECT 
			[SupportEquipmentId],
			ISNULL([SupportEquipment], 'Unknown') [SupportEquipment],
			[StatusCode],
			[StatusName],
			[ReasonId],
			[ReasonDesc],
			[StatusStart],
			[Location],
			[Region],
			[Operator],
			[OperatorImageURL],
			[Duration]
		FROM [cli].[CONOPS_CLI_EQMT_OTHER_V]
		WHERE shiftflag = @SHIFT
		AND (StatusName IN (SELECT TRIM(value) FROM STRING_SPLIT(UPPER(@STATUS), ',')) OR ISNULL(@STATUS, '') = '');

		/*
		SELECT DISTINCT
			ISNULL([SupportEquipment], 'Unknown') [SupportEquipment]
		FROM [cli].[CONOPS_CLI_EQMT_OTHER_V]
		WHERE shiftflag = @SHIFT;
		*/

	END

	ELSE IF @SITE = 'MOR'
	BEGIN
		SELECT 
			[SupportEquipmentId],
			ISNULL([SupportEquipment], 'Unknown') [SupportEquipment],
			[StatusCode],
			[StatusName],
			[ReasonId],
			[ReasonDesc],
			[StatusStart],
			[Location],
			[Region],
			[Operator],
			[OperatorImageURL],
			[Duration]
		FROM [mor].[CONOPS_MOR_EQMT_OTHER_V]
		WHERE shiftflag = @SHIFT
		AND (StatusName IN (SELECT TRIM(value) FROM STRING_SPLIT(UPPER(@STATUS), ',')) OR ISNULL(@STATUS, '') = '');

		/*
		SELECT DISTINCT
			ISNULL([SupportEquipment], 'Unknown') [SupportEquipment]
		FROM [mor].[CONOPS_MOR_EQMT_OTHER_V]
		WHERE shiftflag = @SHIFT;
		*/

