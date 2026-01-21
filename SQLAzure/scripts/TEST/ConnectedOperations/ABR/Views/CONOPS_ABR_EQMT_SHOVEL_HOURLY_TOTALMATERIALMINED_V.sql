CREATE VIEW [ABR].[CONOPS_ABR_EQMT_SHOVEL_HOURLY_TOTALMATERIALMINED_V] AS

--select * from [abr].[CONOPS_ABR_EQMT_SHOVEL_HOURLY_TOTALMATERIALMINED_V] order by shiftseq
CREATE VIEW [ABR].[CONOPS_ABR_EQMT_SHOVEL_HOURLY_TOTALMATERIALMINED_V]
AS

WITH CTE AS (
SELECT 
	a.shiftflag,
	a.siteflag,
	a.shiftid,
	a.ShiftStartDateTime,
	a.ShiftEndDateTime, 
	a.current_utc_offset, 
	dateadd(hour,a.current_utc_offset,b.utc_created_date) AS LoadTime,
	b.ShovelId,
	b.TotalMaterialMined,
	b.TotalMaterialMoved,
	datediff(minute, a.ShiftStartDateTime,dateadd(hour,a.current_utc_offset,b.utc_created_date)) TimeDiff
FROM [ABR].[CONOPS_ABR_SHIFT_INFO_V] a 
INNER JOIN [dbo].[Material_Mined] b WITH (NOLOCK)
	ON a.shiftid = b.shiftid
	AND b.siteflag = 'ABR'
),

TimeSeq AS (
SELECT 
	shiftflag,
	siteflag,
	shiftid,
	ShiftStartDateTime,
	ShiftEndDateTime, 
	current_utc_offset, 
	--LoadTime,
	CASE WHEN LoadTime IS NULL THEN NULL ELSE 
	CAST(CONCAT(CAST(LoadTime AS DATE),' ',LEFT(CAST(LoadTime AS TIME),5),':00.000') AS DATETIME) END AS LoadTime,
	ShovelId,
	TotalMaterialMined,
	TotalMaterialMoved,
	b.seq AS shiftseq
FROM CTE a
INNER JOIN [dbo].[HOURLY_TIME_SEQ] b WITH (NOLOCK)
	ON TimeDiff >= b.STARTS
	AND TimeDiff <= b.ENDS
),

Final AS (
SELECT
	shiftflag,
	siteflag,
	shiftid,
	ShiftStartDateTime,
	ShiftEndDateTime, 
	current_utc_offset, 
	ShovelId,
	TotalMaterialMined,
	TotalMaterialMoved,
	shiftseq,
	LoadTime,
	ROW_NUMBER() OVER (PARTITION BY shiftid,ShovelId,shiftseq ORDER BY LoadTime DESC) num
FROM TimeSeq
WHERE shiftseq IS NOT NULL 
),

FinalSeq AS (
SELECT 
	shiftflag,
	siteflag,
	shiftid,
	ShiftStartDateTime,
	ShiftEndDateTime, 
	current_utc_offset, 
	ShovelId,
	TotalMaterialMined,
	TotalMaterialMoved,
	shiftseq
FROM Final
WHERE num = 1
),

FinalTotal AS (
SELECT
	Siteflag,
	Shiftflag,
	shiftid,
	ShiftStartDateTime,
	ShiftEndDateTime, 
	ShovelId AS Equipment,
	--TotalMaterialMined,
	TotalMaterialMined AS OrigTotalMaterialMined,
	ISNULL(LAG(TotalMaterialMined, 1) OVER(PARTITION BY shiftflag,ShovelId ORDER BY shiftseq ASC),0) AS NewTotalMaterialMined,
	TotalMaterialMoved AS OrigTotalMaterialMoved,
	ISNULL(LAG(TotalMaterialMoved, 1) OVER(PARTITION BY shiftflag,ShovelId ORDER BY shiftseq ASC),0) AS NewTotalMaterialMoved,
	ShiftSeq,
	DATEADD(hour,shiftseq-1,ShiftStartDateTime) as TimeinHour
FROM FinalSeq 
)

SELECT
	siteflag,
	shiftflag,
	shiftid,
	ShiftStartDateTime,
	ShiftEndDateTime,
	equipment,
	ISNULL((OrigTotalMaterialMined - NewTotalMaterialMined),0) TotalMaterialMined,
	ISNULL((OrigTotalMaterialMoved - NewTotalMaterialMoved),0) TotalMaterialMoved,
	TimeInHour,
	shiftseq
FROM FinalTotal

