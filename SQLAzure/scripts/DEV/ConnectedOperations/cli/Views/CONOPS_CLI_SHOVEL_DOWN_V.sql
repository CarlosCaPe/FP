CREATE VIEW [cli].[CONOPS_CLI_SHOVEL_DOWN_V] AS


--select * from [cli].[CONOPS_CLI_SHOVEL_DOWN_V] where shiftflag = 'curr'
CREATE VIEW [cli].[CONOPS_CLI_SHOVEL_DOWN_V]
AS

WITH CTE AS (
SELECT 
shiftid,
Shovelid, 
sum(TotalMaterialMined) AS Actualvalue, 
ShiftTarget,
sum(shoveltarget) as shoveltarget
from [cli].[CONOPS_CLI_OVERVIEW_V] (NOLOCK)
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
FROM [cli].[CONOPS_CLI_SHOVEL_INFO_V] [s] WITH (NOLOCK)
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


