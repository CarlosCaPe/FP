CREATE VIEW [dbo].[CONOPS_LH_DELTA_C_V] AS


--select * from [dbo].[CONOPS_LH_DELTA_C_V]
CREATE VIEW [dbo].[CONOPS_LH_DELTA_C_V]
AS


select 
shiftflag,
siteflag,
shiftid,
excav,
truck,
soper,
toper,
Delta_C,
Delta_c_target,
deltac_ts,
eqmtcurrstatus
from [mor].[CONOPS_MOR_DELTA_C_OVERVIEW_V]
where siteflag = 'MOR'


