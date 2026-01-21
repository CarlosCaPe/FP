CREATE VIEW [dbo].[CONOPS_LH_OEE_V] AS


CREATE VIEW [dbo].[CONOPS_LH_OEE_V]
AS

SELECT
shiftflag,
siteflag,
shiftid,
OEE * 100 as OEE
from [mor].[CONOPS_MOR_OEE_V]
where siteflag = 'MOR'

UNION ALL


SELECT
shiftflag,
siteflag,
shiftid,
OEE * 100 as OEE
from [bag].[CONOPS_BAG_OEE_V]
where siteflag = 'BAG'

