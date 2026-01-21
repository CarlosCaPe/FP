CREATE VIEW [BAG].[CONOPS_BAG_TONS_LINE_SEQ_V] AS


--SELECT * FROM [bag].[CONOPS_BAG_TONS_LINE_SEQ_V] WHERE shiftflag = 'CURR'
CREATE VIEW [bag].[CONOPS_BAG_TONS_LINE_SEQ_V]
AS

WITH CTE AS (
    SELECT 
        a.shiftflag,
        a.siteflag,
        a.shiftid,
        a.ShiftStartDateTime,
        a.SHIFTENDDATETIME,
        current_utc_offset,
        DATEADD(hour, a.current_utc_offset, b.utc_created_date) AS LoadTime,
        b.shovelid,
        b.[TotalMaterialMined],
        b.TotalMaterialMoved,
        b.Mill,
        b.ROM,
        b.Waste,
        b.CrushLeach,
        DATEDIFF(second, a.ShiftStartDateTime, DATEADD(hour, a.current_utc_offset, b.utc_created_date)) AS TimeDiff
    FROM [bag].[CONOPS_BAG_SHIFT_INFO_V] a 
    LEFT JOIN [dbo].[Shift_Line_Graph] b WITH (NOLOCK)
        ON a.shiftid = b.shiftid AND b.siteflag = 'BAG'
    --WHERE SHIFTFLAG = 'CURR'
),

TimeSeq AS (
    SELECT 
        shiftflag,
        siteflag,
        shiftid,
        ShiftStartDateTime,
        SHIFTENDDATETIME,
        current_utc_offset,
        LoadTime,
        shovelid,
        TotalMaterialMined,
        TotalMaterialMoved,
        Mill,
        ROM,
        Waste,
        CrushLeach,
        CASE WHEN b.seq IS NULL THEN 720 ELSE b.seq END AS shiftseq
    FROM CTE a
    LEFT JOIN [dbo].[TIME_SEQ] b WITH (NOLOCK)
        ON TimeDiff BETWEEN b.starts AND b.ends
),

ShiftSeq AS (
    SELECT 
        shiftflag,
        siteflag,
        shiftid,
        ShiftStartDateTime,
        SHIFTENDDATETIME,
        current_utc_offset,
        CASE WHEN shiftseq = 720 THEN ShiftEndDateTime ELSE LoadTime END AS LoadTime,
        shovelid,
        TotalMaterialMined,
        TotalMaterialMoved,
        Mill,
        ROM,
        Waste,
        CrushLeach,
        shiftseq,
        ROW_NUMBER() OVER (PARTITION BY shiftid, shovelid, shiftseq ORDER BY LoadTime DESC) AS row_no
    FROM TimeSeq 
),

TonsFinal AS (
    SELECT 
        shiftflag,
        siteflag,
        shiftid,
        ShiftStartDateTime,
        SHIFTENDDATETIME,
        current_utc_offset,
        SUM(TotalMaterialMined) AS TotalMaterialMined,
        SUM(TotalMaterialMoved) AS TotalMaterialMoved,
        SUM(Mill) AS Mill,
        SUM(ROM) AS ROM,
        SUM(Waste) AS Waste,
        SUM(CrushLeach) AS CrushLeach,
        LoadTime,
        shiftseq
    FROM ShiftSeq
    WHERE row_no = 1
    GROUP BY 
        shiftflag,
        siteflag,
        shiftid,
        ShiftStartDateTime,
        SHIFTENDDATETIME,
        current_utc_offset,
        LoadTime,
        shiftseq
)

SELECT
    shiftflag,
    siteflag,
    shiftid,
    ShiftStartDateTime,
    SHIFTENDDATETIME,
    current_utc_offset,
    TotalMaterialMined,
    TotalMaterialMoved,
    Mill,
    ROM,
    Waste,
    CrushLeach,
    shiftseq
FROM TonsFinal;

