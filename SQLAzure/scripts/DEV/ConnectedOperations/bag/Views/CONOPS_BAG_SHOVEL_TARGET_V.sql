CREATE VIEW [bag].[CONOPS_BAG_SHOVEL_TARGET_V] AS


--select * from [bag].[CONOPS_BAG_SHOVEL_TARGET_V] where FORMATSHIFTID = '230130001'
CREATE VIEW [BAG].[CONOPS_BAG_SHOVEL_TARGET_V]
AS

WITH CTE AS (
select
FORMATSHIFTID,
CASE WHEN Shovelid Like '%L01%' THEN 'L01'
WHEN Shovelid Like '%L05%' THEN 'L05'
WHEN Shovelid Like '%S08%' THEN 'S08'
WHEN Shovelid Like '%S10%' THEN 'S10'
WHEN Shovelid Like '%S11%' THEN 'S11'
WHEN Shovelid Like '%S12%' THEN 'S12'
WHEN Shovelid Like '%S22%' THEN 'S22'
WHEN Shovelid Like '%S23%' THEN 'S23'
END AS Shovelid,

CASE WHEN Shovelid Like '%ORE%' THEN 'MillOre'
WHEN Shovelid Like '%WASTE%' THEN 'Waste'
END AS Destination,
Tons

from (
select FORMATSHIFTID, ShovelId,Tons
from [bag].[plan_values] WITH (NOLOCK)
unpivot
(
  Tons
  for ShovelId in (L01ORE,L01WASTEOXIDE,L05ORE,L05WASTEOXIDE,S08ORE,S08WASTEOXIDE,S10ORE,S10WASTEOXIDE,
  S11ORE,S11WASTEOXIDE,S12ORE,S12WASTEOXIDE,S22ORE,S22WASTEOXIDE,S23ORE,S23WASTEOXIDE)
) unpiv
) shovel),

TGT AS (
SELECT 
FORMATSHIFTID,
Shovelid as shovel,
cast(sum(tons) as int) as shovelshifttarget,
Destination
from CTE
group by FORMATSHIFTID,Shovelid,Destination)


SELECT
FORMATSHIFTID,
shovel,
sum(shovelshifttarget) as shovelshifttarget,
Destination
FROM TGT 
GROUP BY 
FORMATSHIFTID,
shovel,
Destination


