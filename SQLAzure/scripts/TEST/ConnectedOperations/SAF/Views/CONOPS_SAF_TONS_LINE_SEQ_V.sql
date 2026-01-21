CREATE VIEW [SAF].[CONOPS_SAF_TONS_LINE_SEQ_V] AS

--SELECT * FROM [saf].[CONOPS_SAF_TONS_LINE_SEQ_V]
CREATE VIEW [saf].[CONOPS_SAF_TONS_LINE_SEQ_V]
AS

WITH CTE AS (
SELECT 
	a.shiftflag,
	a.siteflag,
	a.shiftid,
	a.ShiftStartDateTime,
	a.ShiftEndDateTime,
	current_utc_offset,
	dateadd(hour,a.current_utc_offset,b.utc_created_date) AS LoadTime,
	b.shovelid,
	b.[TotalMaterialMined],
	b.TotalMaterialMoved,
	b.Mill,
	b.ROM,
	b.Waste,
	b.CrushLeach,
	datediff(second, a.ShiftStartDateTime,dateadd(hour,a.current_utc_offset,b.utc_created_date)) TimeDiff
FROM [saf].[CONOPS_SAF_SHIFT_INFO_V] a WITH (NOLOCK)
INNER JOIN [dbo].[Shift_Line_Graph] b WITH (NOLOCK)
	ON a.shiftid = b.shiftid
	AND b.siteflag = 'SAM'
),

TimeSeq AS (
SELECT 
	shiftflag,
	siteflag,
	shiftid,
	ShiftStartDateTime,
	ShiftEndDateTime,
	current_utc_offset,
	LoadTime,
	TotalMaterialMined,
	TotalMaterialMoved,
	Mill,
	ROM,
	Waste,
	CrushLeach,
	b.seq AS shiftseq
FROM CTE a
INNER JOIN [dbo].[TIME_SEQ] b WITH (NOLOCK)
	ON TimeDiff >= b.STARTS
	AND TimeDiff < b.ENDS
)

SELECT 
	shiftflag,
	siteflag,
	shiftid,
	ShiftStartDateTime,
	ShiftEndDateTime,
	current_utc_offset,
	SUM(TotalMaterialMined) TotalMaterialMined,
	SUM(TotalMaterialMoved) TotalMaterialMoved,
	SUM(Mill) Mill,
	SUM(ROM) ROM,
	SUM(Waste) Waste,
	SUM(CrushLeach) CrushLeach,
	shiftseq
FROM TimeSeq 
GROUP BY shiftflag, siteflag, shiftid, ShiftStartDateTime, ShiftEndDateTime, current_utc_offset, shiftseq