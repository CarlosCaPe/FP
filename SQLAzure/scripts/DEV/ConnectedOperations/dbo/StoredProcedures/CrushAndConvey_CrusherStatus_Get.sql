

/******************************************************************  
* PROCEDURE	: dbo.CrushAndConvey_CrusherStatus_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: ggosal1, 03 Oct 2024
* SAMPLE	: 
	1. EXEC dbo.CrushAndConvey_CrusherStatus_Get 'CURR', 'MOR'
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {03 Oct 2024}     {ggosal1}		{Initial Created}
*******************************************************************/ 
CREATE PROCEDURE [dbo].[CrushAndConvey_CrusherStatus_Get] 
(	
	@SHIFT VARCHAR(4),
	@SITE VARCHAR(4)
)
AS                        
BEGIN        

BEGIN TRY

	IF @SITE = 'BAG'
	BEGIN

		SELECT DISTINCT
			c.Crusher,
			c.CurrentStatus,
			d.Delta_C
		FROM [BAG].[CONOPS_BAG_CRUSHER_STATUS_DETAIL_V] c
		LEFT JOIN [BAG].[CONOPS_BAG_CRUSHER_DELTA_C_V] d
			ON c.CRUSHER = d.CRUSHER
			AND c.SHIFTFLAG = d.SHIFTFLAG
		WHERE c.shiftflag = @SHIFT;

		SELECT
			c.Crusher,
			c.START_TS,
			c.STOP_TS,
			c.TimeInState,
			c.STATUS_TYPE,
			c.STATUS,
			c.REASON,
			c.DESCRIPTION,
			c.COMMENT
		FROM [BAG].[CONOPS_BAG_EQMT_SHIFT_INFO_V] s
		LEFT JOIN [BAG].[CONOPS_BAG_CRUSHER_STATUS_DETAIL_V] c
			ON s.shiftid = c.ShiftId
		WHERE s.shiftflag = @SHIFT
		ORDER BY Crusher, START_TS;

		SELECT TOP 1
			ShiftStartDateTime,
			ShiftEndDateTime
		FROM [BAG].[CONOPS_BAG_CRUSHER_STATUS_DETAIL_V]
		WHERE shiftflag = @SHIFT

	END

	ELSE IF @SITE = 'CVE'
	BEGIN

		SELECT
			NULL AS Crusher,
			NULL AS CurrentStatus,
			NULL AS Delta_C
		WHERE 1 <> 1
	

		SELECT
			NULL AS Crusher,
			NULL AS START_TS,
			NULL AS STOP_TS,
			NULL AS TimeInState,
			NULL AS STATUS_TYPE,
			NULL AS STATUS,
			NULL AS REASON,
			NULL AS DESCRIPTION,
			NULL AS COMMENT
		WHERE 1 <> 1

		SELECT 
			NULL AS ShiftStartDateTime,
			NULL AS ShiftEndDateTime
		WHERE 1 <> 1

	END

	ELSE IF @SITE = 'CHN'
	BEGIN

		SELECT DISTINCT
			c.Crusher,
			c.CurrentStatus,
			d.Delta_C
		FROM [CHI].[CONOPS_CHI_CRUSHER_STATUS_DETAIL_V] c
		LEFT JOIN [CHI].[CONOPS_CHI_CRUSHER_DELTA_C_V] d
			ON c.CRUSHER = d.CRUSHER
			AND c.SHIFTFLAG = d.SHIFTFLAG
		WHERE c.shiftflag = @SHIFT;

		SELECT
			c.Crusher,
			c.START_TS,
			c.STOP_TS,
			c.TimeInState,
			c.STATUS_TYPE,
			c.STATUS,
			c.REASON,
			c.DESCRIPTION,
			c.COMMENT
		FROM [CHI].[CONOPS_CHI_EQMT_SHIFT_INFO_V] s
		LEFT JOIN [CHI].[CONOPS_CHI_CRUSHER_STATUS_DETAIL_V] c
			ON s.shiftid = c.ShiftId
		WHERE s.shiftflag = @SHIFT
		ORDER BY Crusher, START_TS;

		SELECT TOP 1
			ShiftStartDateTime,
			ShiftEndDateTime
		FROM [CHI].[CONOPS_CHI_CRUSHER_STATUS_DETAIL_V]
		WHERE shiftflag = @SHIFT

	END

	ELSE IF @SITE = 'CMX'
	BEGIN

		SELECT DISTINCT
			c.Crusher,
			c.CurrentStatus,
			d.Delta_C
		FROM [CLI].[CONOPS_CLI_CRUSHER_STATUS_DETAIL_V] c
		LEFT JOIN [CLI].[CONOPS_CLI_CRUSHER_DELTA_C_V] d
			ON c.CRUSHER = d.CRUSHER
			AND c.SHIFTFLAG = d.SHIFTFLAG
		WHERE c.shiftflag = @SHIFT;

		SELECT
			c.Crusher,
			c.START_TS,
			c.STOP_TS,
			c.TimeInState,
			c.STATUS_TYPE,
			c.STATUS,
			c.REASON,
			c.DESCRIPTION,
			c.COMMENT
		FROM [CLI].[CONOPS_CLI_EQMT_SHIFT_INFO_V] s
		LEFT JOIN [CLI].[CONOPS_CLI_CRUSHER_STATUS_DETAIL_V] c
			ON s.shiftid = c.ShiftId
		WHERE s.shiftflag = @SHIFT
		ORDER BY Crusher, START_TS;

		SELECT TOP 1
			ShiftStartDateTime,
			ShiftEndDateTime
		FROM [CLI].[CONOPS_CLI_CRUSHER_STATUS_DETAIL_V]
		WHERE shiftflag = @SHIFT

	END

	ELSE IF @SITE = 'MOR'
	BEGIN

		SELECT DISTINCT
			c.Crusher,
			c.CurrentStatus,
			d.Delta_C
		FROM [mor].[CONOPS_MOR_CRUSHER_STATUS_DETAIL_V] c
		LEFT JOIN [mor].[CONOPS_MOR_CRUSHER_DELTA_C_V] d
			ON c.CRUSHER = d.CRUSHER
			AND c.SHIFTFLAG = d.SHIFTFLAG
		WHERE c.shiftflag = @SHIFT;

		SELECT
			c.Crusher,
			c.START_TS,
			c.STOP_TS,
			c.TimeInState,
			c.STATUS_TYPE,
			c.STATUS,
			c.REASON,
			c.DESCRIPTION,
			c.COMMENT
		FR