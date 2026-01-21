



/******************************************************************  
* PROCEDURE	: dbo.MaintenanceCalendar_Update
* PURPOSE	: 
* NOTES		: 
* CREATED	: sxavier, 07 Aug 2023
* SAMPLE	: 
	1. EXEC dbo.MaintenanceCalendar_Update 67, 'Sam 6 Check Trucks', '0', '0', 'T500', 'Sam 6 Check Trucks', '2023-09-06 15:00:00.000', '2023-09-06 16:00:00.000', 1, 'C', 1, 
		'2023-09-02 15:00:00.000', '2023-09-09 15:00:00.000', '0061008723'

* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {07 Aug 2023}		{sxavier}		{Initial Created}
* {07 Aug 2023}		{ywibowo}		{Code review}
* {31 Aug 2023}		{sxavier}		{Support recurrence}
* {02 Nov 2023}		{sxavier}		{Support recurrence custom number}
* {21 May 2024}		{pananda}		{Code review}
*******************************************************************/ 
CREATE PROCEDURE [dbo].[MaintenanceCalendar_Update] 
(	
	@Id INT,
	@EventTitle VARCHAR(512),
	@EventTypeCode VARCHAR(8),
	@EquipmentTypeCode VARCHAR(8),
	@EquipmentName VARCHAR(512),
	@Description VARCHAR(MAX),
	@StartDateTime DATETIME,
	@EndDateTime DATETIME,
	@IsRecurrence BIT,
	@RecurrenceTypeCode CHAR(1),
	@RecurrenceCustomNumber INT,
	@RecurrenceStartDateTime DATETIME,
	@RecurrenceEndDateTime DATETIME,
	@IsUpdateEntireSeries BIT = 1,
	@UserId CHAR(10)
)
AS                        
BEGIN          
	SET NOCOUNT ON
	SET XACT_ABORT ON

		BEGIN TRANSACTION

		IF(@IsUpdateEntireSeries = 0)
		BEGIN
			
			DECLARE @EventId INT
			SET @EventId = (SELECT TOP 1 EventId FROM dbo.CONOPS_MAINTENANCE_CALENDAR_RECURRENCES_V WHERE Id = @Id)

			UPDATE
				dbo.MAINTENANCE_CALENDAR_RECURRENCES
			SET
				EventTitle = @EventTitle,
				EventTypeCode = @EventTypeCode,
				EquipmentTypeCode = @EquipmentTypeCode,
				EquipmentName = @EquipmentName,
				[Description] = @Description,
				StartDateTime = @StartDateTime,
				EndDateTime = @EndDateTime,
				LastModifiedBy = @UserId,
				UtcModifiedDate = GETUTCDATE()
			WHERE
				Id = @Id

			UPDATE
				dbo.MAINTENANCE_CALENDAR
			SET
				IsAnyRecurrenceUpdated = 1
			WHERE
				Id = @EventId
		END
		ELSE
		BEGIN

			UPDATE
				dbo.MAINTENANCE_CALENDAR
			SET
				EventTitle = @EventTitle,
				EventTypeCode = @EventTypeCode,
				EquipmentTypeCode = @EquipmentTypeCode,
				EquipmentName = @EquipmentName,
				[Description] = @Description,
				StartDateTime = @StartDateTime,
				EndDateTime = @EndDateTime,
				IsRecurrence = @IsRecurrence,
				RecurrenceTypeCode = CASE WHEN @IsRecurrence = 0 THEN NULL ELSE @RecurrenceTypeCode END,
				RecurrenceCustomNumber = CASE WHEN @IsRecurrence = 0 THEN NULL ELSE @RecurrenceCustomNumber END,
				RecurrenceStartDateTime = CASE WHEN @IsRecurrence = 0 THEN NULL ELSE @RecurrenceStartDateTime END,
				RecurrenceEndDateTime = CASE WHEN @IsRecurrence = 0 THEN NULL ELSE @RecurrenceEndDateTime END,
				IsAnyRecurrenceUpdated = 0,
				LastModifiedBy = @UserId,
				UtcModifiedDate = GETUTCDATE()
			WHERE
				Id = @Id

			UPDATE
				dbo.MAINTENANCE_CALENDAR
			SET
				IsAnyRecurrenceUpdated = 0
			WHERE
				Id = @Id

			DELETE FROM
				dbo.MAINTENANCE_CALENDAR_RECURRENCES
			WHERE
				EventId = @Id

			IF(@IsRecurrence = 1)
			BEGIN
				DECLARE @TempStartDateTime DATETIME, @TempEndDateTime DATETIME, @Index INT, @IntervalStartAndEndTime INT
				SET @TempStartDateTime = @StartDateTime
				SET @TempEndDateTime = @EndDateTime
				SET @Index = 0
				SET @IntervalStartAndEndTime = DATEDIFF(SECOND, @StartDateTime, @EndDateTime)

				WHILE @TempStartDateTime <= @RecurrenceEndDateTime
				BEGIN
					IF(@TempStartDateTime >= @RecurrenceStartDateTime)
					BEGIN
						INSERT INTO dbo.MAINTENANCE_CALENDAR_RECURRENCES
						(
							EventId,
							EventTitle,
							EventTypeCode,
							EquipmentTypeCode,
							EquipmentName,
							[Description],
							StartDateTime,
							EndDateTime,
							CreatedBy,
							UtcCre