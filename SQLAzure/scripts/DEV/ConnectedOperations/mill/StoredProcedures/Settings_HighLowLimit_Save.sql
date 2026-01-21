


/****************************************************************************  
* PROCEDURE	: mill.Settings_HighLowLimit_Save
* PURPOSE	: 
* NOTES		: 
* CREATED	: sxavier, 28 Oct 2024
* SAMPLE	: 
	1. 
		DECLARE @List AS[mill].[HighLowLimitKpiList]
		INSERT INTO @List VALUES 
			('CRSH1CSS', 400, 450), 
			('CRSH1PWR', 300, 600)
		EXEC mill.Settings_HighLowLimit_Save @List, '0060092257'

* MODIFIED DATE     AUTHOR			DESCRIPTION  
*----------------------------------------------------------------------------  
* {28 Oct 2024}		{sxavier}		{Initial Created}
*****************************************************************************/ 
CREATE PROCEDURE mill.Settings_HighLowLimit_Save 
(
	@HighLowLimitKpiList AS [mill].[HighLowLimitKpiList] READONLY,
	@User CHAR(10)
)
AS                        
BEGIN          
	SET NOCOUNT ON
	SET XACT_ABORT ON
		
		BEGIN TRANSACTION

		MERGE INTO mill.KpisRange AS target
		USING @HighLowLimitKpiList AS source
			ON  source.KpiId = target.KpiId AND target.IsTarget = 1
		WHEN MATCHED THEN
			UPDATE SET
				target.MinValue = source.MinValue,
				target.MaxValue = source.MaxValue,
				target.ModifiedBy = @User,
				target.UtcModifiedDate = GETUTCDATE()
		WHEN NOT MATCHED BY target THEN
			INSERT (KpiId, MinValue, MaxValue, IsTarget, CreatedBy, UtcCreatedDate, ModifiedBy, UtcModifiedDate)
			VALUES (source.KpiId, source.MinValue, source.MaxValue, 1, @User, GETUTCDATE(), @User, GETUTCDATE());

		COMMIT TRANSACTION

	SET NOCOUNT OFF
END

