CREATE VIEW [CER].[SHIFT_ROOT_SHIFT_DATE] AS



CREATE VIEW [cer].[SHIFT_ROOT_SHIFT_DATE]  
AS  

Select 
 shift_root_date_id
,FieldStart
,FieldTime
,FieldYear
,FieldMonth
,FieldDay
,FieldShift
,FieldCrew
,FieldHoliday
,FieldUtcstart
,FieldUtcend
,FieldDststate
,Shiftdate
,capture_ts_utc
,integrate_ts_utc
,logical_delete_flag
,orig_src_id
,site_code
from CERREferenceCache.[dbo].[lh2_shift_root_date_b] WITH(NOLOCK)
WHERE SHIFTDATE >= DATEADD(DAY, - 3,GETDATE())


