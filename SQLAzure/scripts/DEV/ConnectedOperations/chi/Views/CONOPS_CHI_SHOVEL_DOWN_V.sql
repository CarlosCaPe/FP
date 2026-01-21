CREATE VIEW [chi].[CONOPS_CHI_SHOVEL_DOWN_V] AS





--select * from [chi].[CONOPS_CHI_SHOVEL_DOWN_V] where shiftflag = 'curr'
CREATE VIEW [chi].[CONOPS_CHI_SHOVEL_DOWN_V]
AS

WITH CTE AS (
SELECT 
shiftid,
Shovelid, 
sum(TotalMaterialMined) AS Actualvalue, 
ShiftTarget,
sum(shoveltarget) as shoveltarget
from [chi].[CONOPS_CHI_OVERVIEW_V] (NOLOCK)
group by Shovelid,shiftid,ShiftTarget),

ShovelDown AS (
SELECT 
[s].siteflag,
[s].shiftflag,
[s].ShovelID,
Actualvalue,
ShiftTarget,
ShiftTarget - Actualvalue [OffTarget],
StatusCode,
StatusName
FROM [chi].[CONOPS_CHI_SHOVEL_INFO_V] [s] WITH (NOLOCK)
LEFT JOIN CTE [sd] WITH (NOLOCK)
ON [sd].shiftid = [s].shiftid AND [sd].Shovelid = [s].ShovelID
WHERE StatusCode = 1)

SELECT 
shiftflag,
siteflag,
ShovelID,
Actualvalue,
ShiftTarget,
[OffTarget],
StatusCode,
StatusName
FROM ShovelDown [sd] WITH (NOLOCK)


