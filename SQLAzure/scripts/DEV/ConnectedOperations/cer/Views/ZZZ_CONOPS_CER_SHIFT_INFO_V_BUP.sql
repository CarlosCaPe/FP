CREATE VIEW [cer].[ZZZ_CONOPS_CER_SHIFT_INFO_V_BUP] AS




--select * from [cer].[CONOPS_CER_SHIFT_INFO_V]

CREATE VIEW [cer].[CONOPS_CER_SHIFT_INFO_V_OLD]
AS

SELECT 
	a.siteflag,
	a.shiftflag,
	a.shiftid,
	--b.ShiftStartDateTime,
	CASE WHEN b.ShiftStartDateTime IS NULL THEN
	(CASE WHEN right(a.shiftid,1) = 1 THEN concat(cast(left(a.shiftid,6) as date),' 07:30:00.000')
	ELSE concat(cast(left(a.shiftid,6) as date),' 19:30:00.000') END)
	ELSE b.ShiftStartDateTime END AS ShiftStartDateTime,

	--b.ShiftEndDateTime,

	CASE WHEN b.ShiftEndDateTime IS NULL THEN 
	(CASE WHEN right(a.shiftid,1) = 1 THEN concat(cast(left(a.shiftid,6) as date),' 19:30:00.000')
	ELSE concat(dateadd(day,1,cast(left(a.shiftid,6) as date)),' 07:30:00.000') END)
	ELSE b.ShiftEndDateTime END AS ShiftEndDateTime,

	COALESCE(b.ShiftDuration, 0) [ShiftDuration]

FROM ( 
	SELECT 'CER' AS siteflag, 'PREV' AS shiftflag, max(prevshiftid) AS shiftid
	FROM  [cer].[shift_info] (nolock)

	UNION
	SELECT 'CER' AS siteflag,
	'CURR' AS shiftflag, 
	max(shiftid) AS shiftid 
	FROM  [cer].[shift_info] (nolock)

	UNION
	SELECT 'CER' AS siteflag,'NEXT' AS shiftflag, 

	CASE WHEN (select nextshiftid from (
		SELECT TOP 1 nextshiftid,
		ROW_NUMBER() OVER(PARTITION BY shiftid ORDER BY shiftid desc) AS row_num
		FROM [cer].[shift_info] (nolock)
		ORDER BY shiftid DESC) AS nextshiftid
	) IS NULL

	THEN ( CASE WHEN RIGHT(max(shiftid ), 1) = 2 THEN 
	RIGHT(concat(replace(cast(dateadd(day,1,cast(LEFT(max(shiftid),6) AS date)) AS varchar(10)),'-',''),'001'),9) 
	ELSE right(concat(replace(cast(dateadd(day,1,cast(LEFT(max(shiftid),6) AS date)) AS varchar(10)),'-',''),'002'),9) 
	END )

	ELSE max(nextshiftid)
	END AS shiftid
	FROM  [cer].[shift_info] (nolock)
) a
LEFT JOIN (
	SELECT shiftid, ShiftStartDateTime,LEAD(ShiftStartDateTime) OVER ( ORDER BY shiftid ) AS ShiftEndDateTime, ShiftDuration 
	FROM [cer].[shift_info] (nolock)
) b
ON a.shiftid = b.shiftid

