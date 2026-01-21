CREATE VIEW [cer].[ZZZ_CONOPS_CER_SHOVEL_SHIFT_TARGET_V_OLD] AS










--select * from [cer].[CONOPS_CER_SHOVEL_SHIFT_TARGET_V] where shiftflag = 'curr'
CREATE VIEW [cer].[CONOPS_CER_SHOVEL_SHIFT_TARGET_V_OLD]
AS

WITH SINFO AS (
	SELECT 
		shiftid,
		ShiftStartDateTime,
		CASE WHEN LEAD( CAST(ShiftStartDateTime AS datetime2) ) OVER ( ORDER BY shiftid ) IS NULL THEN

		CASE WHEN RIGHT( shiftid, 1) = 2 
		THEN CONCAT( DATEADD( day, 1, CAST( LEFT(  CAST(ShiftStartDateTime AS datetime2), 10 )AS date) ),' 07:30:00.000')
		ELSE CONCAT( DATEADD( day ,0, CAST( LEFT(  CAST(ShiftStartDateTime AS datetime2), 10 )AS date) ),' 19:30:00.000') END

		ELSE LEAD(ShiftStartDateTime) OVER ( ORDER BY shiftid ) END AS ShiftEndDateTime
	FROM [cer].[SHIFT_INFO] (NOLOCK)
),

TGT AS (
	SELECT 
		shiftid,
		shovel,
		sum(shovelshifttarget) AS shovelshifttarget
	FROM [cer].[CONOPS_CER_SHOVEL_TARGET_V]
	GROUP BY shiftid, shovel
),

STGT AS (
	SELECT
		a.shiftflag,
		a.siteflag,
		a.shiftid,
		tg.shovel,
		tg.shovelshifttarget,
		si.ShiftStartDateTime,
		si.ShiftEndDateTime,
		dateadd(hour,-7,GETUTCDATE()) as current_local_time,
		CASE WHEN a.shiftflag = 'PREV' 
		THEN datediff(hour,si.ShiftStartDateTime,si.ShiftEndDateTime) 
		WHEN a.shiftflag = 'CURR' 
		THEN datediff(hour,si.ShiftStartDateTime,dateadd(hour,-7,GETUTCDATE()))
		ELSE NULL END as ShiftCompleteHour
	FROM cer.CONOPS_CER_SHIFT_INFO_V a
	LEFT JOIN SINFO si on a.shiftid = si.shiftid AND a.siteflag = 'CER'
	LEFT JOIN TGT tg on CAST(a.shiftid AS VARCHAR(20)) = tg.shiftid AND a.siteflag = 'CER'
	WHERE a.siteflag = 'CER'
)


SELECT 
	siteflag,
	shiftflag,
	shiftid,
	shovel as shovelid,
	shovelshifttarget,
	ShiftCompleteHour,

	CASE WHEN ShiftCompleteHour IS NULL 
	THEN shovelshifttarget ELSE cast((ShiftCompleteHour/12.0)*shovelshifttarget as integer) END as shoveltarget
FROM STGT
WHERE siteflag = 'CER'

