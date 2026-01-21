CREATE VIEW [dbo].[CONOPS_LH_DELTA_C_OVERVIEW_V] AS


CREATE VIEW [dbo].[CONOPS_LH_DELTA_C_OVERVIEW_V]
AS


select 
shiftflag,
siteflag,
shiftid,
deltac_ts,
delta_c,
ShiftStartDateTime,
ShiftEndDateTime
from [mor].[CONOPS_MOR_DELTA_C_V]
where siteflag = 'MOR'

UNION ALL

select 
shiftflag,
siteflag,
shiftid,
deltac_ts,
delta_c,
ShiftStartDateTime,
ShiftEndDateTime
from [bag].[CONOPS_BAG_DELTA_C_V]
where siteflag = 'BAG'



