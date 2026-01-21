















/******************************************************************  
* PROCEDURE	: dbo.EOS_ShiftNotesLineUpEquipments_Save
* PURPOSE	: 
* NOTES		: 
* CREATED	: sxavier, 26 Jun 2023
* SAMPLE	: 
	1. EXEC dbo.EOS_ShiftNotesLineUpEquipments_Save 'Shovels', 'MOR', 'NIGHT SHIFT', '2023-06-25 00:00:00.000', 3, 'notes abcd', '0060092257'
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {26 Jun 2023}		{sxavier}		{Initial Created} 
*******************************************************************/ 
CREATE PROCEDURE [dbo].[EOS_ShiftNotesLineUpEquipments_Save] 
(	
	@Equipment VARCHAR (16),
	@SiteCode CHAR(3),
	@Shift VARCHAR(16),
	@ShiftDate DATETIME,
	@EquipmentAvailableShiftStart INT,
	@ShiftNotes VARCHAR(MAX),
	@EmployeeId CHAR(10)
)
AS                        
BEGIN    
	SET NOCOUNT ON
	SET XACT_ABORT ON

	BEGIN TRANSACTION

	IF EXISTS (SELECT Equipment 
				FROM [dbo].[CONOPS_EOS_SHIFTNOTES_LINEUPEQUIPMENTS_V]
				WHERE Equipment = @Equipment
					AND SiteCode = @SiteCode 
					AND [Shift] = @Shift 
					AND ShiftDate = @ShiftDate)
	BEGIN
		UPDATE 
			dbo.ShiftNotesLineUpEquipments
		SET
			EquipmentAvailableShiftStart = @EquipmentAvailableShiftStart,
			ShiftNotes = @ShiftNotes,
			ModifiedBy = @EmployeeId,
			UtcModifiedDate = GETUTCDATE()
		WHERE
			Equipment = @Equipment
			AND SiteCode = @SiteCode 
			AND [Shift] = @Shift 
			AND ShiftDate = @ShiftDate
	END
	ELSE
	BEGIN
		INSERT INTO dbo.ShiftNotesLineUpEquipments
		(
			Equipment,
			SiteCode,
			[Shift],
			ShiftDate,
			EquipmentAvailableShiftStart,
			ShiftNotes,
			CreatedBy,
			UtcCreatedDate,
			ModifiedBy,
			UtcModifiedDate
		)
		VALUES
		(
			@Equipment,
			@SiteCode,
			@Shift,
			@ShiftDate,
			@EquipmentAvailableShiftStart,
			@ShiftNotes,
			@EmployeeId,
			GETUTCDATE(),
			@EmployeeId,
			GETUTCDATE()
		)
	END

	COMMIT TRANSACTION

	SET NOCOUNT OFF

END


