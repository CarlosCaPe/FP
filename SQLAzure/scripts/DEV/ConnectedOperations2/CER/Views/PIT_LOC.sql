CREATE VIEW [CER].[PIT_LOC] AS



CREATE VIEW [cer].[PIT_LOC]   
AS    
  
Select   
site_code AS siteflag
,DbPrevious  
,DbNext  
,DbVersion  
,pit_loc_id as ID  
,pit_dbname  as DBNAME
,DbKey  
,FieldId  
,FieldPit  
,FieldRegion  
,FieldBlendrec  
,FieldPath  
,FieldBean  
,FieldInvbean  
,FieldHaul  
,FieldOre  
,FieldDumpfeed  
,FieldDumpcapy  
,FieldBinsize  
,FieldXloc  
,FieldYloc  
,FieldPathix  
,FieldTimedump  
,FieldZloc  
,FieldSignid  
,FieldUnit  
,FieldLoad  
,FieldIstiedown  
,FieldStatus  
,FieldLinestat  
,FieldSpillage  
,FieldSignpost  
,FieldShoptype  
,FieldDumpqueue  
,FieldPctcapy  
,FieldBays  
,FieldNopenalty  
,FieldTimelast  
,FieldRadius  
,FieldGpstype  
,FieldReason  
,FieldIvtrec  
,FieldTdset  
,FieldPrior  
,FieldAvailbays  
,FieldParkqueue  
,FieldLaststattime  
,FieldBcntime  
,FieldTagdate  
,FieldTageqmt  
,FieldTrucksenroute  
,FieldLastassign  
,FieldLastarrive  
,FieldSpeedtrap  
,FieldLvsproxcnt  
,FieldIgnunexarr  
,FieldMetadata  
,FieldDisablearrchk  
,FieldIntf_data1  
,FieldIntf_data2  
,FieldIntf_data3  
,logical_delete_flag  
,orig_src_id  
,site_code  
,capture_ts_utc  
,integrate_ts_utc  
from [CERReferenceCache].[dbo].[lh2_pit_loc_b] WITH(NOLOCK)


