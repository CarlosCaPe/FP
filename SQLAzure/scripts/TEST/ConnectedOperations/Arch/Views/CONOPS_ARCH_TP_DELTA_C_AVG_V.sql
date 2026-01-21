CREATE VIEW [Arch].[CONOPS_ARCH_TP_DELTA_C_AVG_V] AS



CREATE VIEW [Arch].[CONOPS_ARCH_TP_DELTA_C_AVG_V]
AS

SELECT 
a.site_code,
a.shiftid,
a.truck,
avg(a.deltac) as deltac,
avg(b.idletime) as idletime,
avg(c.spottime) as spottime,
avg(d.loadtime) as loadtime,
avg(e.dumpingtime) as dumpingtime,
avg(f.DumpingAtStockpile) as DumpingAtStockpile,
avg(g.DumpingAtCrusher) as DumpingAtCrusher,
h.EFH
FROM (
SELECT 
site_code,
concat(concat(right(replace(cast(shiftdate as varchar(10)),'-',''),6),'00'),shift_code) as shiftid,
truck,
avg(delta_c) as deltac
FROM dbo.delta_c WITH (NOLOCK)
--WHERE site_code = '<SITECODE>'
GROUP BY site_code,shiftdate,shift_code,truck) a

LEFT JOIN (
SELECT 
concat(concat(right(replace(cast(shiftdate as varchar(10)),'-',''),6),'00'),shift_code) as shiftid,
truck,
avg(idletime) as idletime
FROM dbo.delta_c WITH (NOLOCK)
--WHERE site_code = '<SITECODE>'
GROUP BY site_code,shiftdate,shift_code,truck) b
ON a.shiftid = b.shiftid AND a.truck = b.truck


LEFT JOIN (
SELECT 
concat(concat(right(replace(cast(shiftdate as varchar(10)),'-',''),6),'00'),shift_code) as shiftid,
truck,
avg(spottime) as spottime
FROM dbo.delta_c WITH (NOLOCK)
--WHERE site_code = '<SITECODE>'
GROUP BY site_code,shiftdate,shift_code,truck) c
ON a.shiftid = c.shiftid AND a.truck = c.truck


LEFT JOIN (
SELECT 
concat(concat(right(replace(cast(shiftdate as varchar(10)),'-',''),6),'00'),shift_code) as shiftid,
truck,
avg(loadtime) as loadtime
FROM dbo.delta_c WITH (NOLOCK)
--WHERE site_code = '<SITECODE>'
GROUP BY site_code,shiftdate,shift_code,truck) d
ON a.shiftid = d.shiftid AND a.truck = d.truck


LEFT JOIN (
SELECT 
concat(concat(right(replace(cast(shiftdate as varchar(10)),'-',''),6),'00'),shift_code) as shiftid,
truck,
avg(DumpingTime) as DumpingTime
FROM dbo.delta_c WITH (NOLOCK)
--WHERE site_code = '<SITECODE>'
GROUP BY site_code,shiftdate,shift_code,truck) e
ON a.shiftid = e.shiftid AND a.truck = e.truck


LEFT JOIN (
SELECT 
concat(concat(right(replace(cast(shiftdate as varchar(10)),'-',''),6),'00'),shift_code) as shiftid,
truck,
CASE WHEN unit = 'Stockpile' THEN COALESCE(avg([dumpdelta]), 0) END AS DumpingAtStockpile
FROM dbo.delta_c WITH (NOLOCK)
--WHERE site_code = '<SITECODE>'
GROUP BY site_code,shiftdate,shift_code,truck,unit) f
ON a.shiftid = f.shiftid AND a.truck = f.truck


LEFT JOIN (
SELECT 
concat(concat(right(replace(cast(shiftdate as varchar(10)),'-',''),6),'00'),shift_code) as shiftid,
truck,
CASE WHEN unit = 'Crusher' THEN COALESCE(avg([dumpdelta]), 0) END AS DumpingAtCrusher
FROM dbo.delta_c WITH (NOLOCK)
--WHERE site_code = '<SITECODE>'
GROUP BY site_code,shiftdate,shift_code,truck,unit) g
ON a.shiftid = g.shiftid AND a.truck = g.truck


LEFT JOIN (
SELECT 
concat(concat(right(replace(cast(shiftdate as varchar(10)),'-',''),6),'00'),shift_code) as shiftid,
truck,
avg(distloaded + (fliftup * 27.1428) + (fliftdown * 16)) as EFH
FROM dbo.delta_c WITH (NOLOCK)
--WHERE site_code = '<SITECODE>'
GROUP BY site_code,shiftdate,shift_code,truck) h
ON a.shiftid = h.shiftid AND a.truck = h.truck

WHERE a.site_code = '<SITECODE>'

GROUP BY 
 
a.site_code,
a.shiftid,
a.truck,
h.efh

