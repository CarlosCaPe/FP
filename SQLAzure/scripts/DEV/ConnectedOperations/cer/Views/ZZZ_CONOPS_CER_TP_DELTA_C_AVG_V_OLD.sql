CREATE VIEW [cer].[ZZZ_CONOPS_CER_TP_DELTA_C_AVG_V_OLD] AS





--SELECT * FROM [cer].[CONOPS_CER_TP_DELTA_C_AVG_V] WITH (NOLOCK)
CREATE VIEW [cer].[CONOPS_CER_TP_DELTA_C_AVG_V_OLD]
AS

SELECT 
a.site_code,
a.shiftindex,
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
shiftindex,
truck,
avg(delta_c) as deltac
FROM dbo.delta_c WITH (NOLOCK)
WHERE site_code = 'CER'
GROUP BY site_code,shiftindex,truck) a

LEFT JOIN (
SELECT 
shiftindex,
truck,
avg(idletime) as idletime
FROM dbo.delta_c WITH (NOLOCK)
WHERE site_code = 'CER'
GROUP BY site_code,shiftindex,truck) b
ON a.shiftindex = b.shiftindex AND a.truck = b.truck


LEFT JOIN (
SELECT 
shiftindex,
truck,
avg(spottime) as spottime
FROM dbo.delta_c WITH (NOLOCK)
WHERE site_code = 'CER'
GROUP BY site_code,shiftindex,truck) c
ON a.shiftindex = c.shiftindex AND a.truck = c.truck


LEFT JOIN (
SELECT 
shiftindex,
truck,
avg(loadtime) as loadtime
FROM dbo.delta_c WITH (NOLOCK)
WHERE site_code = 'CER'
GROUP BY site_code,shiftindex,truck) d
ON a.shiftindex = d.shiftindex AND a.truck = d.truck


LEFT JOIN (
SELECT 
shiftindex,
truck,
avg(DumpingTime) as DumpingTime
FROM dbo.delta_c WITH (NOLOCK)
WHERE site_code = 'CER'
GROUP BY site_code,shiftindex,truck) e
ON a.shiftindex = e.shiftindex AND a.truck = e.truck


LEFT JOIN (
SELECT 
shiftindex,
truck,
CASE WHEN unit = 'Stockpile' THEN COALESCE(avg([dumpdelta]), 0) END AS DumpingAtStockpile
FROM dbo.delta_c WITH (NOLOCK)
WHERE site_code = 'CER'
GROUP BY site_code,shiftindex,truck,unit) f
ON a.shiftindex = f.shiftindex AND a.truck = f.truck


LEFT JOIN (
SELECT 
shiftindex,
truck,
CASE WHEN unit = 'Crusher' THEN COALESCE(avg([dumpdelta]), 0) END AS DumpingAtCrusher
FROM dbo.delta_c WITH (NOLOCK)
WHERE site_code = 'CER'
GROUP BY site_code,shiftindex,truck,unit) g
ON a.shiftindex = g.shiftindex AND a.truck = g.truck


LEFT JOIN (
SELECT 
shiftindex,
truck,
avg(distloaded + (fliftup * 27.1428) + (fliftdown * 16)) as EFH
FROM dbo.delta_c WITH (NOLOCK)
WHERE site_code = 'CER'
GROUP BY site_code,shiftindex,truck) h
ON a.shiftindex = h.shiftindex AND a.truck = h.truck

WHERE a.site_code = 'CER'

GROUP BY 
 
a.site_code,
a.shiftindex,
a.truck,
h.efh


