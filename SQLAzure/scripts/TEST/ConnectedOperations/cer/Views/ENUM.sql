CREATE VIEW [cer].[ENUM] AS



CREATE VIEW [cer].[ENUM]      
AS      
    
Select     
site_code AS siteflag
--ID AS enum_id    
,enum_id   
,EnumTypeId    
,Idx    
,Description    
,Abbreviation    
,Flags    
--,NULL AS logical_delete_flag    
--,140 AS orig_src_id    
--,'CER' AS site_code    
--,NULL AS capture_ts_utc    
--,NULL AS integrate_ts_utc     
, logical_delete_flag    
, orig_src_id    
, site_code    
, capture_ts_utc    
, integrate_ts_utc  
from CERREferenceCache.[dbo].[lh2_enum_b] WITH(NOLOCK) --[cer].[ENUM_OLD] 
  


