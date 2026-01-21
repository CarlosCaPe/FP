CREATE VIEW [cer].[PIT_WORKER] AS



CREATE VIEW [cer].[PIT_WORKER]   
AS    
  
Select 
site_code AS siteflag
,DbPrevious  
,DbNext  
,DbVersion  
,pit_worker_id AS ID 
,pit_dbname  AS DBNAME
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
,orig_src_id  
,site_code  
,capture_ts_utc  
,integrate_ts_utc  
,NULL AS FIELDLCOMMENT  
from [CERReferenceCache].[dbo].[lh2_pit_worker_b] WITH(NOLOCK)


