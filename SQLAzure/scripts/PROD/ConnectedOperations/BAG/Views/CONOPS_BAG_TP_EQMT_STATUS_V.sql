CREATE VIEW [BAG].[CONOPS_BAG_TP_EQMT_STATUS_V] AS

--select * from [bag].[CONOPS_BAG_TP_EQMT_STATUS_V] where shiftflag = 'curr'
CREATE VIEW [bag].[CONOPS_BAG_TP_EQMT_STATUS_V]
AS

SELECT a.shiftflag
	,a.siteflag
	,a.shiftid
	,a.ShiftStartDateTime
	,b.eqmt
	,b.eqmttype
	,b.startdatetime
	,b.enddatetime
	,b.duration
	,b.reasonidx
	,b.reasons
	,b.[status]
	,c.eqmtcurrstatus
	,d.avg_deltac
	,e.avg_payload
FROM [bag].[CONOPS_BAG_SHIFT_INFO_V] a(NOLOCK)
LEFT JOIN (
	SELECT shiftid
		,eqmt
		,eqmttype
		,startdatetime
		,enddatetime
		,duration
		,reasonidx
		,reasons
		,[status]
	FROM [bag].[asset_efficiency](NOLOCK)
	WHERE unittype = 'Truck'
	) b
	ON a.shiftid = b.shiftid
LEFT JOIN (
	SELECT shiftid
		,eqmt
		,startdatetime
		,enddatetime
		,[status] AS eqmtcurrstatus
		,ROW_NUMBER() OVER (PARTITION BY shiftid,eqmt ORDER BY startdatetime DESC) num
	FROM [bag].[asset_efficiency](NOLOCK)
	WHERE unittype = 'Truck'
	) c
	ON b.shiftid = c.shiftid
		AND b.eqmt = c.eqmt
		AND c.num = 1
LEFT JOIN (
	SELECT site_code
		,CONCAT (CONCAT (right(replace(cast(shiftdate AS VARCHAR(10)), '-', ''), 6),'00'),shift_code) AS shiftid
		,truck
		,avg(delta_c) AS avg_deltac
	FROM [dbo].[delta_c](NOLOCK)
	WHERE site_code = 'BAG'
	GROUP BY site_code
		,shiftdate
		,shift_code
		,truck
	) d
	ON b.shiftid = d.shiftid
		AND b.eqmt = d.truck
		AND a.siteflag = d.site_code
LEFT JOIN (
	SELECT shiftflag
		,truck
		,avg_payload
	FROM [bag].[CONOPS_BAG_TP_AVG_PAYLOAD_V](NOLOCK)
	) e
	ON a.shiftflag = e.shiftflag
		AND b.eqmt = e.truck
WHERE b.eqmt IS NOT NULL


