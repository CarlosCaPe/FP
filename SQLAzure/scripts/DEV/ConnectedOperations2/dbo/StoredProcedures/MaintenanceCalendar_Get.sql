


/******************************************************************  
* PROCEDURE	: dbo.MaintenanceCalendar_Get
* PURPOSE	: 
* NOTES		: 
* CREATED	: sxavier, 04 Aug 2023
* SAMPLE	: 
	1. EXEC dbo.MaintenanceCalendar_Get 'MOR', '2024-05-19 01:29:02.453', '2024-05-29 15:30:02.453', 'EN'

* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {04 Aug 2023}		{sxavier}		{Initial Created}
* {07 Aug 2023}		{ywibowo}		{Code review}
* {31 Aug 2023}		{sxavier}		{Support recurrence}
* {02 Nov 2023}		{sxavier}		{Add RecurrenceCustomNumber}
* {16 May 2024}		{sxavier}		{Support change specific occurence}
* {21 May 2024}		{pananda}		{Code review}
*******************************************************************/ 
CREATE PROCEDURE [dbo].[MaintenanceCalendar_Get] 
(	
	@SiteCode CHAR(3),
	@DateFrom DATETIME,
	@DateTo DATETIME,
	@LanguageCode CHAR(2),
	@Version INT
)
AS                        
BEGIN          
	SET NOCOUNT ON
		
		SELECT
			A.Id,
			A.SiteCode,
			RecurrenceId = NULL,
			A.EventTitle,
			A.EventTypeCode,
			A.EventTypeValue,
			A.EventTypeLanguageCode,
			A.EquipmentTypeCode,
			A.EquipmentTypeValue,
			A.EquipmentTypeLanguageCode,
			A.EquipmentName,
			A.[Description],
			A.StartDatetime,
			A.EndDateTime,
			A.IsRecurrence,
			A.RecurrenceTypeCode,
			A.RecurrenceCustomNumber,
			A.StartDatetime AS EventStartDateTime,
			A.EndDateTime AS EventEndDateTime,
			A.RecurrenceStartDateTime,
			A.RecurrenceEndDateTime,
			A.IsAnyRecurrenceUpdated
		FROM 
			[dbo].[CONOPS_MAINTENANCE_CALENDAR_V] A
		WHERE
			A.SiteCode = @SiteCode AND
			A.EventTypeLanguageCode = @LanguageCode AND
			A.EquipmentTypeLanguageCode = @LanguageCode AND
			(
				(@DateFrom BETWEEN A.StartDatetime AND A.EndDateTime) OR
				(A.StartDatetime BETWEEN @DateFrom AND @DateTo)
			)
			AND A.IsRecurrence = 0

		UNION

		SELECT
			A.Id,
			A.SiteCode,
			RecurrenceId = B.Id,
			B.EventTitle,
			B.EventTypeCode,
			B.EventTypeValue,
			B.EventTypeLanguageCode,
			B.EquipmentTypeCode,
			B.EquipmentTypeValue,
			B.EquipmentTypeLanguageCode,
			B.EquipmentName,
			B.[Description],
			CASE WHEN @Version = 1 THEN B.StartDatetime ELSE A.StartDatetime END,
			CASE WHEN @Version = 1 THEN B.EndDateTime ELSE A.EndDateTime END,
			A.IsRecurrence,
			A.RecurrenceTypeCode,
			A.RecurrenceCustomNumber,
			B.StartDatetime AS EventStartDateTime,
			B.EndDateTime AS EventEndDateTime,
			A.RecurrenceStartDateTime,
			A.RecurrenceEndDateTime,
			A.IsAnyRecurrenceUpdated
		FROM 
			[dbo].[CONOPS_MAINTENANCE_CALENDAR_V] A
			RIGHT JOIN [dbo].[CONOPS_MAINTENANCE_CALENDAR_RECURRENCES_V] B ON A.Id = B.EventId
		WHERE
			A.SiteCode = @SiteCode AND
			B.EventTypeLanguageCode = @LanguageCode AND
			B.EquipmentTypeLanguageCode = @LanguageCode AND
			(
				(@DateFrom BETWEEN B.StartDatetime AND B.EndDateTime) OR
				(B.StartDatetime BETWEEN @DateFrom AND @DateTo)
			)

	SET NOCOUNT OFF
END
