CREATE VIEW [bag].[ZZZ_SHIFT_LOAD_TEMP] AS
  
  
CREATE VIEW [BAG].[SHIFT_LOAD_TEMP]    
AS    
  
Select   
'BAG' AS siteflag  
,DbPrevious  
,DbNext  
,DbVersion  
,ShiftId  
,ID AS shift_load_id  
,DBNAME AS shift_dbname  
,DbKey  
,FieldId  
,FieldTruck  
,FieldExcav  
,FieldGrade  
,FieldLoc  
,FieldDumprec  
,FieldTons  
,FieldTimearrive  
,FieldTimeload  
,FieldTimefull  
,FieldCalctravtime  
,FieldLoad  
,FieldExtraload  
,FieldLoadtype  
,FieldDist  
,FieldEfh  
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
,FieldFirstdipper  
,FieldLastdipper  
,FieldBktcnt  
,FieldPandhbucketloads  
,FieldAudit  
,FieldWeightst  
,NULL AS FieldWeightmeas  
,FieldMeasuretime  
,FieldGpsxtkl  
,FieldGpsytkl  
,FieldGpsxex  
,FieldGpsyex  
,FieldGpsstatex  
,FieldGpsstattk  
,FieldGpsheadtk  
,FieldGpsveltk  
,FieldPvs3id  
,FieldBktsum  
,FieldDumpasn  
,FieldLsizetons  
,FieldLsizeid  
,FieldLsizeversion  
,FieldLsizedb  
,FieldFuelremain  
,FieldFactapply  
,FieldDlock  
,FieldElock  
,FieldEdlock  
,FieldRlock  
,FieldReconstat  
,FieldTimearrivemobile  
,FieldTimeloadmobile  
,FieldTimefullmobile  
,logical_delete_flag  
--,orig_src_id  
--,site_code  
--,Shiftdate  
,capture_ts_utc  
,integrate_ts_utc  

from BAGREferenceCache.[dbo].[lh2_shift_load_b]  
WHERE SHIFTID >= CONCAT(CONVERT(VARCHAR(8), DATEADD(DAY, - 2,GETDATE()), 12), '001')  