

/******************************************************************  
* PROCEDURE	: dbo.Operator_SupportEquipment_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: ggosal1, 02 May 2023
* SAMPLE	: 
	1. EXEC dbo.Operator_SupportEquipment_Get 'CURR', 'BAG'
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {02 May 2023}		{ggosal1}		{Initial Created} 
* {22 Jan 2024}		{lwasini}		{Add TYR}  
* {24 Jan 2024}		{lwasini}		{Add ABR} 
*******************************************************************/ 
CREATE PROCEDURE [dbo].[Operator_SupportEquipment_Get] 
(	
	@SHIFT VARCHAR(4),
	@SITE VARCHAR(4)
)
AS                        
BEGIN  

BEGIN TRY

	IF @SITE = 'BAG'
	BEGIN

		SELECT
			OperatorId,
			Operator,
			OperatorImageURL,
			SupportEquipmentId,
			[StatusName] AS [Status],
			OperatorStatus
		FROM BAG.CONOPS_BAG_OPERATOR_SUPPORT_EQMT_V
		WHERE SHIFTFLAG = @SHIFT

	END

	ELSE IF @SITE = 'CVE'
	BEGIN

		SELECT
			OperatorId,
			Operator,
			OperatorImageURL,
			SupportEquipmentId,
			[StatusName] AS [Status],
			OperatorStatus
		FROM CER.CONOPS_CER_OPERATOR_SUPPORT_EQMT_V
		WHERE SHIFTFLAG = @SHIFT

	END

	ELSE IF @SITE = 'CHN'
	BEGIN

		SELECT
			OperatorId,
			Operator,
			OperatorImageURL,
			SupportEquipmentId,
			[StatusName] AS [Status],
			OperatorStatus
		FROM CHI.CONOPS_CHI_OPERATOR_SUPPORT_EQMT_V
		WHERE SHIFTFLAG = @SHIFT

	END

	ELSE IF @SITE = 'CMX'
	BEGIN

		SELECT
			OperatorId,
			Operator,
			OperatorImageURL,
			SupportEquipmentId,
			[StatusName] AS [Status],
			OperatorStatus
		FROM CLI.CONOPS_CLI_OPERATOR_SUPPORT_EQMT_V
		WHERE SHIFTFLAG = @SHIFT

	END

	ELSE IF @SITE = 'MOR'
	BEGIN

		SELECT
			OperatorId,
			Operator,
			OperatorImageURL,
			SupportEquipmentId,
			[StatusName] AS [Status],
			OperatorStatus
		FROM MOR.CONOPS_MOR_OPERATOR_SUPPORT_EQMT_V
		WHERE SHIFTFLAG = @SHIFT

	END

	ELSE IF @SITE = 'SAM'
	BEGIN

		SELECT
			OperatorId,
			Operator,
			OperatorImageURL,
			SupportEquipmentId,
			[StatusName] AS [Status],
			OperatorStatus
		FROM SAF.CONOPS_SAF_OPERATOR_SUPPORT_EQMT_V
		WHERE SHIFTFLAG = @SHIFT

	END

	ELSE IF @SITE = 'SIE'
	BEGIN

		SELECT
			OperatorId,
			Operator,
			OperatorImageURL,
			SupportEquipmentId,
			[StatusName] AS [Status],
			OperatorStatus
		FROM SIE.CONOPS_SIE_OPERATOR_SUPPORT_EQMT_V
		WHERE SHIFTFLAG = @SHIFT

	END


	ELSE IF @SITE = 'TYR'
	BEGIN

		SELECT
			OperatorId,
			Operator,
			OperatorImageURL,
			SupportEquipmentId,
			[StatusName] AS [Status],
			OperatorStatus
		FROM TYR.CONOPS_TYR_OPERATOR_SUPPORT_EQMT_V
		WHERE SHIFTFLAG = @SHIFT

	END


	ELSE IF @SITE = 'ABR'
	BEGIN

		SELECT
			OperatorId,
			Operator,
			OperatorImageURL,
			SupportEquipmentId,
			[StatusName] AS [Status],
			OperatorStatus
		FROM [ABR].CONOPS_ABR_OPERATOR_SUPPORT_EQMT_V
		WHERE SHIFTFLAG = @SHIFT

	END



END TRY
BEGIN CATCH
	PRINT ERROR_MESSAGE();
END CATCH

END




