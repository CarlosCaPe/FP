CREATE VIEW [bag].[ZZZ_SHIFT_ROOT_SHIFT_DATE_TEMP] AS
  
CREATE VIEW [BAG].[SHIFT_ROOT_SHIFT_DATE_TEMP]    
AS    
  
Select   
 ID AS shift_root_date_id  
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
--,Shiftdate  
,capture_ts_utc  
,integrate_ts_utc  
--,logical_delete_flag  
--,orig_src_id  
 ,'BAG' AS site_code  


from BAGREferenceCache.[dbo].[lh2_shift_root_date_b]  
