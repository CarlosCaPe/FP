CREATE VIEW [chi].[CONOPS_CHI_TP_EQMT_STATUS_V] AS




--select * from [chi].[CONOPS_CHI_TP_EQMT_STATUS_V] where shiftflag = 'curr'

CREATE VIEW [chi].[CONOPS_CHI_TP_EQMT_STATUS_V] 
AS

SELECT a.shiftflag,
       a.siteflag,
       a.shiftid,
       a.ShiftStartDateTime,
       b.eqmt,
	   f.eqmttype,
       b.startdatetime,
       b.enddatetime,
       b.duration,
       b.reasonidx,
       b.reasons,
       b.[status],
       c.eqmtcurrstatus,
       d.avg_deltac,
       e.avg_payload
FROM [chi].[CONOPS_CHI_SHIFT_INFO_V] a (NOLOCK)
LEFT JOIN
  (SELECT shiftid,
          eqmt,
          startdatetime,
          enddatetime,
          duration,
          reasonidx,
          reasons,
          [status]
   FROM [chi].[asset_efficiency] (NOLOCK)
   WHERE unittype = 'truck'
   AND eqmt NOT IN ('897','898')) b ON a.shiftid = b.shiftid
LEFT JOIN
  (SELECT shiftid,
          eqmt,
          startdatetime,
          enddatetime,
          [status] AS eqmtcurrstatus,
          ROW_NUMBER() OVER (PARTITION BY shiftid,
                                          eqmt
                             ORDER BY startdatetime DESC) num
   FROM [chi].[asset_efficiency] (NOLOCK)
   WHERE unittype = 'truck') c ON b.shiftid = c.shiftid
AND b.eqmt = c.eqmt AND c.num = 1
LEFT JOIN
  (SELECT site_code,
          concat(concat(right(replace(cast(shiftdate AS varchar(10)), '-', ''), 6), '00'), shift_code) AS shiftid,
          truck,
          avg(delta_c) AS avg_deltac
   FROM [dbo].[delta_c] (NOLOCK)
   WHERE site_code = 'CHI'
   GROUP BY site_code,
            shiftdate,
            shift_code,
            truck) d ON b.shiftid = d.shiftid
AND b.eqmt = d.truck
AND a.siteflag = d.site_code
LEFT JOIN
  (SELECT shiftflag,
          truck,
          avg_payload
   FROM [chi].[CONOPS_CHI_TP_AVG_PAYLOAD_V] (NOLOCK)
   WHERE siteflag = 'CHI' ) e ON a.shiftflag = e.shiftflag
AND b.eqmt = e.truck


LEFT JOIN (
SELECT
shiftindex,
eqmtid,
eqmttype
FROM [dbo].[LH_EQUIP_LIST] WITH (NOLOCK)
WHERE SITE_CODE = 'CHI'
AND UNIT = 'Truck') f
ON a.shiftindex = f.shiftindex
AND b.eqmt = f.eqmtid

WHERE b.eqmt IS NOT NULL


