CREATE VIEW [Arch].[CONOPS_ARCH_SHOVEL_TARGET_V] AS



CREATE VIEW [Arch].[CONOPS_ARCH_SHOVEL_TARGET_V]
AS

WITH CTE AS (
select
FORMATSHIFTID,
CASE WHEN Shovelid Like '%L01%' THEN 'L01'
WHEN Shovelid Like '%L02%' THEN 'L02'
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
from [Arch].[plan_values]
unpivot
(
  Tons
  for ShovelId in (L01ORE,L01WASTE_OXIDE,L02ORE,L02WASTE_OXIDE,S08ORE,S08WASTE_OXIDE,S10ORE,S10WASTE_OXIDE,
  S11ORE,S11WASTE_OXIDE,S12ORE,S12WASTE_OXIDE,S22ORE,S22WASTE_OXIDE,S23ORE,S23WASTE_OXIDE)
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


