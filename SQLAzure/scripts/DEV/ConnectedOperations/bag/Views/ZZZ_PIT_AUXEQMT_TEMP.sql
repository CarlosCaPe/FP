CREATE VIEW [bag].[ZZZ_PIT_AUXEQMT_TEMP] AS
  
    
CREATE VIEW [bag].[PIT_AUXEQMT_TEMP]        
AS        
      
Select  
'BAG' AS siteflag  
,DbPrevious  
,DbNext  
,DbVersion  
,Id AS Id  
,dbname AS DbName  
,DbKey  
,FieldId  
,FieldLoc  
,FieldExcav  
,FieldAux  
,FieldVan  
,FieldReglock  
,FieldBaysplit  
,FieldSendcount  
,FieldRcvcount  
,FieldTimelate  
,FieldClock  
,FieldTimeassign  
,FieldTimelast  
,FieldTimenext  
,FieldPanelid  
,FieldLinereason  
,FieldReason  
,FieldUnit  
,FieldUnitloc  
,FieldStatus  
,FieldLogin  
,FieldPort  
,FieldLinestat  
,FieldEqmttype  
,FieldComment  
,FieldLinecmt  
,FieldActsim  
,FieldActlast  
,FieldVsmstbl  
,FieldXloc  
,FieldYloc  
,FieldRadius  
,FieldVelocity  
,FieldHeading  
,FieldDirection  
,FieldTiedownaccepted  
,FieldZ  
,FieldLaststatustime  
,FieldLaststatreason  
,FieldTiedownproposed  
,FieldLastbreak  
,FieldCuroper  
,FieldCurscope  
,FieldCurbreak  
,FieldFsgroup  
,FieldHpgps  
,FieldPv3sup  
,FieldLastrftagtime  
,FieldPrestartdone  
,FieldPresunit  
,FieldLvsproxcnt  
,FieldLastgpsupdate  
,FieldGpsok  
,FieldFueltank  
,FieldFuelremain  
,FieldLastfuelcalc  
,FieldFueltime  
,FieldFuelfact  
,FieldOemfueltime  
,FieldHdwtype  
,FieldVansize  
,FieldVanoccupied  
,FieldMaintdate  
,FieldLastservicedate  
,FieldMainthours  
,FieldEnghr  
,FieldEnghrtime  
,FieldEqreq  
,FieldTanksize  
,FieldTankremain  
,FieldSpray  
,FieldGrade  
,FieldAuxsched  
,FieldAuxtask  
,FieldLocnext  
,FieldLoclast  
,FieldExpected  
,FieldActnext  
,FieldPmid  
,FieldTdbar  
,FieldTdrelease  
,FieldDevver  
,FieldDevhw  
,FieldDevbc  
,FieldDevop  
,FieldRuntime  
,FieldFuelenghr  
,FieldIntf_data  
,FieldRulelasttime  
,capture_ts_utc  
,integrate_ts_utc  
,logical_delete_flag  
--,orig_src_id  
--,site_code  
     
from [BAGReferenceCache].[dbo].[lh2_pit_aux_b]   
    
 