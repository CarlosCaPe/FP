CREATE VIEW [dbo].[CONOPS_LOGBOOK_V] AS





/******************************************************************  
* VIEW	    : dbo.CONOPS_LOGBOOK_V
* PURPOSE	: 
* NOTES		: 
* CREATED	: sxavier, 7 Jul 2023
* SAMPLE	: 
	1. SELECT * FROM dbo.CONOPS_LOGBOOK_V
	
* MODIFIED DATE     AUTHOR			DESCRIPTION  
*------------------------------------------------------------------  
* {7 Jul 2023}		{sxavier}		{Initial Created}
* {7 Jul 2023}		{ywibowo}		{Code Review}
* {11 Jul 2023}		{pananda}		{Join with GER to get employee name}
* {4 Aug 2023}		{sxavier}		{Add column OrderByImportanceCreatedDate}
* {05 Sep 2023}		{sxavier}		{Support new adjustment for CO Logbook}
* {29 Sep 2023}		{ywibowo}		{Code Review}
* {11 Oct 2024}		{sxavier}		{Remove join to GER}
* {21 Oct 2024}		{sxavier}		{Add Process and SubProcess}
* {17 Apr 2025}		{sxavier}		{Adjust new logbook}
* {09 May 2025}		{npratama}		{Added TaskAreaCode}
*******************************************************************/ 


CREATE VIEW [dbo].[CONOPS_LOGBOOK_V]
AS
	SELECT
		A.Id,
		A.LogbookTypeCode,
		A.SiteCode,
		A.ProcessId,
		A.SubProcessId,
		A.ShiftId,
		A.Title,
		A.[Description],
		A.ImportanceCode,
		A.AreaCode,
		A.EmployeeId,
		A.DateCreated,
		A.TaskArea,
		A.TaskAreaCode,
		A.EwsTaskId,
		A.EwsTransactionId,
		A.AssignedTo,
		A.DueDate,
		A.TaskStatusCode,
		A.TaskStatusDescription,
		A.WorkOrder,
		D.[Value] + A.AssignedTo + '.jpg' AS TaskEmployeePhotoUrlAssignedTo,
		A.ExtendedProperty1,
		A.ExtendedProperty2,
		A.ExtendedProperty3,
		A.ExtendedProperties,
		A.IsActive,
		A.OrderByAreaCreatedDate,
		A.OrderByImportanceCreatedDate,
		D.[Value] + A.CreatedBy + '.jpg' AS EmployeePhotoUrlCreatedBy,
		D.[Value] + A.ModifiedBy + '.jpg' AS EmployeePhotoUrlModifiedBy,
		A.CreatedBy,
		A.UtcCreatedDate,
		A.ModifiedBy,
		A.UtcModifiedDate
	FROM [dbo].[LOGBOOK] A (NOLOCK)
		INNER JOIN [dbo].[CONOPS_LOOKUPS_V] D ON D.TableType = 'CONF' AND D.TableCode = 'IMGURL'

