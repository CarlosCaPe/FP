CREATE VIEW [chi].[ZZZ_CONOPS_CHI_SHIFT_INFO_V_BUP] AS






--select * from [chi].[CONOPS_CHI_SHIFT_INFO_V]

CREATE VIEW [chi].[CONOPS_CHI_SHIFT_INFO_V] WITH SCHEMABINDING 
AS

SELECT 
	a.siteflag,
	a.shiftflag,
	a.shiftid,
	--b.ShiftStartDateTime,
	CASE WHEN b.ShiftStartDateTime IS NULL THEN
	(CASE WHEN right(a.shiftid,1) = 1 THEN concat(cast(left(a.shiftid,6) as date),' 07:00:00.000')
	ELSE concat(cast(left(a.shiftid,6) as date),' 19:00:00.000') END)
	ELSE b.ShiftStartDateTime END AS ShiftStartDateTime,

	--b.ShiftEndDateTime,

	CASE WHEN b.ShiftEndDateTime IS NULL THEN 
	(CASE WHEN right(a.shiftid,1) = 1 THEN concat(cast(left(a.shiftid,6) as date),' 19:00:00.000')
	ELSE concat(dateadd(day,1,cast(left(a.shiftid,6) as date)),' 07:00:00.000') END)
	ELSE b.ShiftEndDateTime END AS ShiftEndDateTime,

	COALESCE(b.ShiftDuration, 0) [ShiftDuration]

FROM (
	SELECT siteflag,
	'PREV' AS shiftflag, 
	max(prevshiftid) AS shiftid
	FROM  [chi].[shift_info] (NOLOCK)
	GROUP BY siteflag

	UNION
	SELECT siteflag,
	'CURR' AS shiftflag, 
	max(shiftid) AS shiftid 
	FROM  [chi].[shift_info] (NOLOCK)
	GROUP BY siteflag

	UNION
	SELECT siteflag,'NEXT' AS shiftflag, 

	CASE WHEN (select nextshiftid 
	FROM (
		SELECT  TOP 1 nextshiftid,
			ROW_NUMBER() OVER(PARTITION BY shiftid ORDER BY shiftid desc) AS row_num
		FROM [chi].[shift_info] (NOLOCK)
		ORDER BY shiftid DESC) AS nextshiftid
	) IS NULL

	THEN ( CASE WHEN RIGHT(max(shiftid),1) = 2 THEN 
	right(concat(replace(cast(dateadd(day,1,cast(LEFT(max(shiftid),6) as date)) AS varchar(10)),'-',''),'001'),9) 
	ELSE right(concat(replace(cast(dateadd(day,1,cast(LEFT(max(shiftid),6) as date)) AS varchar(10)),'-',''),'002'),9) END)

	ELSE max(nextshiftid)
	END AS shiftid
	FROM  [chi].[shift_info] (nolock)
	GROUP BY siteflag
) a
LEFT JOIN (
	SELECT shiftid, ShiftStartDateTime,LEAD(ShiftStartDateTime) OVER ( ORDER BY shiftid ) AS ShiftEndDateTime, ShiftDuration 
	FROM [chi].[shift_info] (NOLOCK)
) b
ON a.shiftid = b.shiftid

