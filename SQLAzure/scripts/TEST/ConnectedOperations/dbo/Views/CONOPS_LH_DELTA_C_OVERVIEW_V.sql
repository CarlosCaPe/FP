CREATE VIEW [dbo].[CONOPS_LH_DELTA_C_OVERVIEW_V] AS





--select * from [dbo].[CONOPS_LH_DELTA_C_OVERVIEW_V] where shiftflag = 'curr' order by deltac_ts asc
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

UNION ALL

select 
shiftflag,
siteflag,
shiftid,
deltac_ts,
delta_c,
ShiftStartDateTime,
ShiftEndDateTime
from [saf].[CONOPS_SAF_DELTA_C_V]
where siteflag = 'SAF'


UNION ALL

select 
shiftflag,
siteflag,
shiftid,
deltac_ts,
delta_c,
ShiftStartDateTime,
ShiftEndDateTime
from [sie].[CONOPS_SIE_DELTA_C_V]
where siteflag = 'SIE'

UNION ALL

select 
shiftflag,
siteflag,
shiftid,
deltac_ts,
delta_c,
ShiftStartDateTime,
ShiftEndDateTime
from [cli].[CONOPS_CLI_DELTA_C_V]
where siteflag = 'CMX'

UNION ALL

select 
shiftflag,
siteflag,
shiftid,
deltac_ts,
delta_c,
ShiftStartDateTime,
ShiftEndDateTime
from [chi].[CONOPS_CHI_DELTA_C_V]
where siteflag = 'CHI'

UNION ALL

select 
shiftflag,
siteflag,
shiftid,
deltac_ts,
delta_c,
ShiftStartDateTime,
ShiftEndDateTime
from [cer].[CONOPS_CER_DELTA_C_V]
where siteflag = 'CER'
