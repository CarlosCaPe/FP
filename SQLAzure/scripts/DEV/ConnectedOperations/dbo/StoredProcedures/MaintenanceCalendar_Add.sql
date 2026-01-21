


/******************************************************************  
* PROCEDURE	: dbo.MaintenanceCalendar_Add
* PURPOSE	: 
* NOTES		: 
* CREATED	: sxavier, 04 Aug 2023
* SAMPLE	: 
	1. EXEC dbo.MaintenanceCalendar_Add 'MOR', 'Sam 5 Check Trucks', '0', '0', 'T500', 'Check equipment trucks', 
		'2023-09-03 15:00:00.000', '2023-09-05 17:00:00.000', 0, 'M', NULL, '2023-09-02 10:00:00.000', '2023-12-16 16:00:00.000', '0061008723'

* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {04 Aug 2023}		{sxavier}		{Initial Created}
* {07 Aug 2023}		{ywibowo}		{Code review}
* {31 Aug 2023}		{sxavier}		{Support recurrence}
* {02 Nov 2023}		{sxavier}		{Support recurrence custom number}
* {16 May 2024}		{sxavier}		{Support change specific occurence}
* {21 May 2024}		{pananda}		{Code review}
*******************************************************************/ 
CREATE PROCEDURE [dbo].[MaintenanceCalendar_Add] 
(	
	@SiteCode CHAR(3),
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
	@UserId CHAR(10)
)
AS                        
BEGIN          
	SET NOCOUNT ON
	SET XACT_ABORT ON

		BEGIN TRANSACTION

		DECLARE @TempTable TABLE(Id INT)
		DECLARE @InsertedId INT

		INSERT INTO dbo.MAINTENANCE_CALENDAR
		(					
			SiteCode,
			EventTitle,
			EventTypeCode,
			EquipmentTypeCode,
			EquipmentName,
			[Description],
			StartDateTime,
			EndDateTime,
			IsRecurrence,
			RecurrenceTypeCode,
			RecurrenceCustomNumber,
			RecurrenceStartDateTime,
			RecurrenceEndDateTime,
			IsAnyRecurrenceUpdated,
			CreatedBy,
			UtcCreatedDate,
			LastModifiedBy,
			UtcModifiedDate
		)
		OUTPUT inserted.Id INTO @TempTable
		VALUES			
		( 				
			@SiteCode,
			@EventTitle,
			@EventTypeCode,
			@EquipmentTypeCode,
			@EquipmentName,
			@Description,
			@StartDateTime,
			@EndDateTime,
			@IsRecurrence,
			@RecurrenceTypeCode,
			@RecurrenceCustomNumber,
			@RecurrenceStartDateTime,
			@RecurrenceEndDateTime,
			CASE WHEN @IsRecurrence = 1 THEN 0 ELSE NULL END,
			@UserId,
			GETUTCDATE(),
			@UserId,
			GETUTCDATE()
		)

		SET @InsertedId = (SELECT Id FROM @TempTable)

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
						UtcCreatedDate,
						LastModifiedBy,
						UtcModifiedDate
					)
					VALUES
					(
						@InsertedId,
						@EventTitle,
						@EventTypeCode,
						@EquipmentTypeCode,
						@EquipmentName,
						@Description,
						@TempStartDateTime,
						@TempEndDateTime,
						@UserId,
						GETUTCDATE(),
						@UserId,
						GETUTCDATE()
					)
				END

				SET @Index = @Index + 1
				SET @TempStartDateTime = CASE 
											WHEN @RecurrenceTypeCode = 'C' THEN DATEADD(DAY, @RecurrenceCustomNumber, @TempStartDateTime)
											WHEN @RecurrenceTypeCode = 'W' THEN DATEADD(WEEK, 1, @TempStartDateTime)
											ELSE DATEADD(MONTH, @Index, @StartDateTime)
										END
				SET @TempEndDateTime =  CASE 
											WHEN @RecurrenceTypeC