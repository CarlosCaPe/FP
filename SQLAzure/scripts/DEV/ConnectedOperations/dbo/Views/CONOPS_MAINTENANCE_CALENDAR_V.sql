CREATE VIEW [dbo].[CONOPS_MAINTENANCE_CALENDAR_V] AS


/******************************************************************  
* VIEW	    : dbo.CONOPS_MAINTENANCE_CALENDAR_V
* PURPOSE	: 
* NOTES		: 
* CREATED	: sxavier, 7 Jul 2023
* SAMPLE	: 
	1. SELECT * FROM dbo.CONOPS_MAINTENANCE_CALENDAR_V
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {4 Aug 2023}		{sxavier}		{Initial Created}
* {7 Aug 2023}		{ywibowo}		{Code review}
* {31 Aug 2023}		{sxavier}		{Support recurrence}
* {02 Nov 2023}		{sxavier}		{Add RecurrenceCustomeNumber}
* {16 May 2024}		{sxavier}		{Support change specific occurence}
* {21 May 2024}		{pananda}		{Code review}
*******************************************************************/ 


CREATE VIEW [dbo].[CONOPS_MAINTENANCE_CALENDAR_V]
AS
	SELECT
		A.Id,
		A.SiteCode,
		A.EventTitle,
		A.EventTypeCode,
		C.[Value] AS EventTypeValue,
		C.LanguageCode AS EventTypeLanguageCode,
		A.EquipmentTypeCode,
		B.[Value] AS EquipmentTypeValue,
		B.LanguageCode AS EquipmentTypeLanguageCode,
		A.EquipmentName,
		A.[Description],
		A.StartDatetime,
		A.EndDateTime,
		A.IsRecurrence,
		A.RecurrenceTypeCode,
		A.RecurrenceCustomNumber,
		A.RecurrenceStartDateTime,
		A.RecurrenceEndDateTime,
		A.IsAnyRecurrenceUpdated,
		A.CreatedBy,
		A.UtcCreatedDate,
		A.LastModifiedBy,
		A.UtcModifiedDate
	FROM [dbo].[MAINTENANCE_CALENDAR] A (NOLOCK)
	INNER JOIN [dbo].[CONOPS_LOOKUPS_V] B ON B.TableType = 'EQMT' AND A.EquipmentTypeCode = B.TableCode
	INNER JOIN [dbo].[CONOPS_LOOKUPS_V] C ON C.TableType = 'EVNT' AND A.EventTypeCode = C.TableCode

