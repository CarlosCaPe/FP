CREATE VIEW [bag].[ZZZ_PIT_WORKER_TEMP] AS
  
CREATE VIEW [BAG].[PIT_WORKER_TEMP]     
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
,FieldNumer    
,FieldShifts    
,FieldStatus    
,FieldLineupcrew    
,FieldCrew    
,FieldDept    
,FieldName    
,FieldSeniority    
,FieldRegionlock    
,FieldLoc    
,FieldLoctime    
,FieldRoster    
,FieldRosterhist    
,FieldLogincrew    
,FieldFatgmode    
,FieldFatgwarntype    
,FieldFatgwarnpassed    
,FieldNextfatgwarndue    
,FieldFatgwarnsent    
,FieldFatgrespexptd    
,FieldFatgddblink    
,FieldArea    
,logical_delete_flag    
--,orig_src_id    
--,site_code    
,capture_ts_utc    
,integrate_ts_utc    
,FIELDLCOMMENT    
from [BAGReferenceCache].[dbo].[lh2_pit_worker_b]  


 