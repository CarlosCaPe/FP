CREATE VIEW [bag].[ZZZ_ENUM_TEMP] AS
  
CREATE VIEW [bag].[ENUM_TEMP]
AS        
      
Select       
'BAG' AS siteflag  
,ID AS enum_id      
--,enum_id     
,EnumTypeId      
,Idx      
,Description      
,Abbreviation      
,Flags        
, logical_delete_flag      
--, orig_src_id      
--, site_code      
, capture_ts_utc      
, integrate_ts_utc    
from BAGREferenceCache.[dbo].[lh2_enum_b]  
    

	 