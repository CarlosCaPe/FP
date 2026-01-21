CREATE VIEW [bag].[ZZZ_SHIFT_DUMP_TEMP] AS
  
  
CREATE VIEW [BAG].[SHIFT_DUMP_TEMP]    
AS    
  
Select   
'BAG' AS siteflag  
,DbPrevious  
,DbNext  
,DbVersion  
,ShiftId  
,ID as shift_dump_id  
,DBNAME as shift_dbname  
,DbKey  
,FieldId  
,FieldTruck  
,FieldLoc  
,FieldGrade  
,FieldLoadrec  
,FieldExcav  
,FieldBlast  
,FieldBay  
,FieldTons  
,FieldTimearrive  
,FieldTimedump  
,FieldTimeempty  
,FieldTimedigest  
,FieldCalctravtime  
,FieldLoad  
,FieldExtraload  
,FieldDist  
,FieldEfh  
,FieldLoadtype  
,FieldToper  
,FieldEoper  
,FieldOrigasn  
,FieldReasnby  
,FieldPathtravtime  
,FieldExptraveltime  
,FieldExptraveldist  
,FieldGpstraveldist  
,FieldLocactlc  
,FieldLocacttp  
,FieldLocactrl  
,FieldAudit  
,FieldGpsxtkd  
,FieldGpsytkd  
,FieldGpsstat  
,FieldGpshead  
,FieldGpsvel  
,FieldLsizetons  
,FieldLsizeid  
,FieldLsizeversion  
,FieldLsizedb  
,FieldFactapply  
,FieldDlock  
,FieldElock  
,FieldEdlock  
,FieldRlock  
,FieldReconstat  
,FieldTimearrivemobile  
,FieldTimedumpmobile  
,FieldTimeemptymobile  
,capture_ts_utc  
,integrate_ts_utc  
,logical_delete_flag  
--,orig_src_id  
--,site_code  
--,Shiftdate  
  
from BAGREferenceCache.[dbo].[lh2_shift_dump_b]  
WHERE SHIFTID >= CONCAT(CONVERT(VARCHAR(8), DATEADD(DAY, - 2,GETDATE()), 12), '001')  