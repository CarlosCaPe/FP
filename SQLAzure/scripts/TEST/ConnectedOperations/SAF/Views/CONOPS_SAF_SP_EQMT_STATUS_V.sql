CREATE VIEW [SAF].[CONOPS_SAF_SP_EQMT_STATUS_V] AS






--select * from [saf].[CONOPS_SAF_SP_EQMT_STATUS_V] where shiftflag = 'curr'

CREATE VIEW [saf].[CONOPS_SAF_SP_EQMT_STATUS_V]
AS

SELECT a.shiftflag,
       a.siteflag,
       a.shiftid,
       a.ShiftStartDateTime,
       a.ShiftEndDateTime,
       b.eqmt,
	   f.eqmttype,
       b.startdatetime,
       b.enddatetime,
       b.duration,
       b.reasonidx,
       b.reasons,
       b.[status],
       c.eqmtcurrstatus,
       d.EFH,
       e.tprh
FROM [saf].[CONOPS_SAF_SHIFT_INFO_V] a (NOLOCK)
LEFT JOIN (
	 SELECT shiftid,
            eqmt,
            startdatetime,
            enddatetime,
            duration,
            reasonidx,
            reasons,
            [status]
     FROM [saf].[asset_efficiency] (NOLOCK)
     WHERE unittype = 'shovel'
) b ON a.shiftid = b.shiftid 
LEFT JOIN (
	 SELECT shiftid,
            eqmt,
            startdatetime,
            enddatetime,
            [status] AS eqmtcurrstatus,
            ROW_NUMBER() OVER (PARTITION BY shiftid, eqmt
                               ORDER BY startdatetime DESC) num
     FROM [saf].[asset_efficiency] (NOLOCK)
     WHERE unittype = 'shovel'
) c ON b.shiftid = c.shiftid AND b.eqmt = c.eqmt AND c.num = 1
LEFT JOIN (
	 SELECT site_code,
            concat(concat(right(replace(cast(shiftdate AS varchar(10)), '-', ''), 6), '00'), shift_code) AS shiftid,
            excav,
            avg(distloaded + (fliftup * 27.1428) + (fliftdown * 16)) AS EFH
     FROM dbo.delta_c (NOLOCK)
     WHERE site_code = 'SAF'
     GROUP BY shiftdate, shift_code, site_code, excav
) d ON b.shiftid = d.shiftid AND b.eqmt = d.excav AND a.shiftflag = d.site_code
LEFT JOIN (
	 SELECT shiftindex,
            site_code,
            eqmt,
            tprh
     FROM [saf].[CONOPS_SAF_SHOVEL_TPRH_V] (NOLOCK)
) e ON a.ShiftIndex = e.shiftindex AND b.eqmt = e.eqmt AND a.siteflag = e.site_code


LEFT JOIN (
SELECT
shiftindex,
eqmtid,
eqmttype
FROM [dbo].[LH_EQUIP_LIST] WITH (NOLOCK)
WHERE SITE_CODE = 'SAF'
AND UNIT = 'Shovel') f
ON a.shiftindex = f.shiftindex
AND b.eqmt = f.eqmtid

WHERE b.eqmt IS NOT NULL



