CREATE VIEW [dbo].[CONOPS_LH_OEE_V] AS





--select * from [dbo].[CONOPS_LH_OEE_V]

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

UNION ALL

SELECT
shiftflag,
siteflag,
shiftid,
OEE * 100 as OEE
from [saf].[CONOPS_SAF_OEE_V]
where siteflag = 'SAF'

UNION ALL


SELECT
shiftflag,
siteflag,
shiftid,
OEE * 100 as OEE
from [sie].[CONOPS_SIE_OEE_V]
where siteflag = 'SIE'


UNION ALL


SELECT
shiftflag,
siteflag,
shiftid,
OEE * 100 as OEE
from [cli].[CONOPS_CLI_OEE_V]
where siteflag = 'CMX'


UNION ALL


SELECT
shiftflag,
siteflag,
shiftid,
OEE * 100 as OEE
from [chi].[CONOPS_CHI_OEE_V]
where siteflag = 'CHI'


