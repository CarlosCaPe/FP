CREATE VIEW [mor].[ZZZ_CONOPS_MOR_SP_DELTA_C_AVG_V_OLD] AS





--SELECT excav,deltac FROM [mor].[CONOPS_MOR_SP_DELTA_C_AVG_V] WHERE shiftid = '221217002' and excav = 'T591' group by excav
CREATE VIEW [mor].[CONOPS_MOR_SP_DELTA_C_AVG_V_OLD] 
AS

SELECT 
a.site_code,
a.shiftid,
a.excav,
--a.soper,
--a.soperid,
avg(a.deltac) as deltac,
avg(b.idletime) as idletime,
avg(c.spottime) as spottime,
avg(d.loadtime) as loadtime,
avg(e.dumpingtime) as dumpingtime,
avg(f.DumpingAtStockpile) as DumpingAtStockpile,
avg(g.DumpingAtCrusher) as DumpingAtCrusher,
h.EFH,
avg(i.TRAVELEMPTY) as EmptyTravel,
avg(j.TRAVELLOADED) as LoadedTravel
FROM (
SELECT 
site_code,
concat(concat(right(replace(cast(shiftdate as varchar(10)),'-',''),6),'00'),shift_code) as shiftid,
excav,
avg(delta_c) as deltac
--upper(soper) as soper,
--RIGHT('00000'+ CONVERT(VARCHAR,soperid),10) as soperid
FROM dbo.delta_c WITH (NOLOCK)
WHERE site_code = 'MOR'
GROUP BY site_code,shiftdate,shift_code,excav) a

LEFT JOIN (
SELECT 
concat(concat(right(replace(cast(shiftdate as varchar(10)),'-',''),6),'00'),shift_code) as shiftid,
excav,
avg(idletime) as idletime
FROM dbo.delta_c WITH (NOLOCK)
WHERE site_code = 'MOR'
GROUP BY site_code,shiftdate,shift_code,excav) b
ON a.shiftid = b.shiftid AND a.excav = b.excav


LEFT JOIN (
SELECT 
concat(concat(right(replace(cast(shiftdate as varchar(10)),'-',''),6),'00'),shift_code) as shiftid,
excav,
avg(spottime) as spottime
FROM dbo.delta_c WITH (NOLOCK)
WHERE site_code = 'MOR'
GROUP BY site_code,shiftdate,shift_code,excav) c
ON a.shiftid = c.shiftid AND a.excav = c.excav


LEFT JOIN (
SELECT 
concat(concat(right(replace(cast(shiftdate as varchar(10)),'-',''),6),'00'),shift_code) as shiftid,
excav,
avg(loadtime) as loadtime
FROM dbo.delta_c WITH (NOLOCK)
WHERE site_code = 'MOR'
GROUP BY site_code,shiftdate,shift_code,excav) d
ON a.shiftid = d.shiftid AND a.excav = d.excav


LEFT JOIN (
SELECT 
concat(concat(right(replace(cast(shiftdate as varchar(10)),'-',''),6),'00'),shift_code) as shiftid,
excav,
avg(DumpingTime) as DumpingTime
FROM dbo.delta_c WITH (NOLOCK)
WHERE site_code = 'MOR'
GROUP BY site_code,shiftdate,shift_code,excav) e
ON a.shiftid = e.shiftid AND a.excav = e.excav


LEFT JOIN (
SELECT 
concat(concat(right(replace(cast(shiftdate as varchar(10)),'-',''),6),'00'),shift_code) as shiftid,
excav,
CASE WHEN unit = 'Stockpile' THEN COALESCE(avg([dumpdelta]), 0) END AS DumpingAtStockpile
FROM dbo.delta_c WITH (NOLOCK)
WHERE site_code = 'MOR'
GROUP BY site_code,shiftdate,shift_code,excav,unit) f
ON a.shiftid = f.shiftid AND a.excav = f.excav


LEFT JOIN (
SELECT 
concat(concat(right(replace(cast(shiftdate as varchar(10)),'-',''),6),'00'),shift_code) as shiftid,
excav,
CASE WHEN unit = 'Crusher' THEN COALESCE(avg([dumpdelta]), 0) END AS DumpingAtCrusher
FROM dbo.delta_c WITH (NOLOCK)
WHERE site_code = 'MOR'
GROUP BY site_code,shiftdate,shift_code,excav,unit) g
ON a.shiftid = g.shiftid AND a.excav = g.excav


LEFT JOIN (
SELECT 
concat(concat(right(replace(cast(shiftdate as varchar(10)),'-',''),6),'00'),shift_code) as shiftid,
excav,
avg(distloaded + (fliftup * 27.1428) + (fliftdown * 16)) as EFH
FROM dbo.delta_c WITH (NOLOCK)
WHERE site_code = 'MOR'
GROUP BY site_code,shiftdate,shift_code,excav) h
ON a.shiftid = h.shiftid AND a.excav = h.excav

LEFT JOIN (
SELECT 
concat(concat(right(replace(cast(shiftdate as varchar(10)),'-',''),6),'00'),shift_code) as shiftid,
excav,
avg(TRAVELEMPTY) as TRAVELEMPTY
FROM dbo.delta_c WITH (NOLOCK)
WHERE site_code = 'MOR'
GROUP BY site_code,shiftdate,shift_code,excav) i
ON a.shiftid = i.shiftid AND a.excav = i.excav

LEFT JOIN (
SELECT 
concat(concat(right(replace(cast(shiftdate as varchar(10)),'-',''),6),'00'),shift_code) as shiftid,
excav,
avg(TRAVELLOADED) as TRAVELLOADED
FROM dbo.delta_c WITH (NOLOCK)
WHERE site_code = 'MOR'
GROUP BY site_code,shiftdate,shift_code,excav) j
ON a.shiftid = j.shiftid AND a.excav = j.excav

WHERE a.si