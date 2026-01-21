CREATE VIEW [bag].[ZZZ_PIT_LOC_TEMP] AS
  
CREATE VIEW [BAG].[PIT_LOC_TEMP]     
AS      
    
Select     
'BAG' AS siteflag  
,DbPrevious    
,DbNext    
,DbVersion    
,ID    
,DBNAME  
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
--,orig_src_id    
--,site_code    
,capture_ts_utc    
,integrate_ts_utc    
    
    
 
from [BAGReferenceCache].[dbo].[lh2_pit_loc_b]  