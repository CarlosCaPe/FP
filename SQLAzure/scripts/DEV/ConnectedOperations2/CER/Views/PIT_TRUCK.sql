CREATE VIEW [CER].[PIT_TRUCK] AS



CREATE VIEW [cer].[PIT_TRUCK]   
AS    
  
Select   
site_code AS siteflag
,DbPrevious  
,DbNext  
,DbVersion  
,pit_truck_id AS ID 
,pit_dbname  AS DBNAME
,DbKey  
,FieldId  
,FieldQueue  
,FieldExcavnext  
,FieldLoc  
,FieldLocnext  
,FieldExcavlock  
,FieldDumplock  
,FieldExcav  
,FieldDumpasn  
,FieldLocstart  
,FieldLastloc  
,FieldVan  
,FieldRegionlock  
,FieldLastexcav  
,FieldBay  
,FieldLunchbreak  
,FieldBean  
,FieldSize  
,FieldFuelamt  
,FieldTons  
,FieldSimcode  
,FieldSendcount  
,FieldRcvcount  
,FieldTime1  
,FieldTime2  
,FieldBeans  
,FieldTimelate  
,FieldTimelast  
,FieldTimenext  
,FieldRateload  
,FieldTimespot  
,FieldClock  
,FieldAsntime  
,FieldTimebreak  
,FieldTimepanel  
,FieldCalctime  
,FieldMaxrateload  
,FieldPanelid  
,FieldFueltank  
,FieldSignid  
,FieldReason  
,FieldLinereason  
,FieldUnit  
,FieldUnitloc  
,FieldUnitlocnext  
,FieldActlast  
,FieldActnext  
,FieldActsim  
,FieldStatus  
,FieldLoad  
,FieldPort  
,FieldPrior  
,FieldLinestat  
,FieldLogin  
,FieldPriorore  
,FieldPriorwaste  
,FieldRetorque  
,FieldEqmttype  
,FieldNoassign  
,FieldTram  
,FieldLastload  
,FieldSignpost  
,FieldDoublespot  
,FieldVsmstbl  
,FieldComment  
,FieldLinecmt  
,FieldIrbeacon  
,FieldTramload  
,FieldFreearrive  
,FieldSaveprior  
,FieldDist  
,FieldEfh  
,FieldXloc  
,FieldYloc  
,FieldRadius  
,FieldGpstype  
,FieldLpeqmt  
,FieldTramschedule  
,FieldDiglock  
,FieldVelocity  
,FieldHeading  
,FieldDirection  
,FieldTiedownaccepted  
,FieldPropfeed  
,FieldZ  
,FieldShoveldist  
,FieldDumpdist  
,FieldLaststatustime  
,FieldLaststatreason  
,FieldTiedownproposed  
,FieldThreshold  
,FieldMinout  
,FieldTiretime  
,FieldTirectrl  
,FieldDumpasntime  
,FieldShovelfulltime  
,FieldLastbreak  
,FieldCuroper  
,FieldCurscope  
,FieldCurbreak  
,FieldOrigasnexcav  
,FieldOrigasnloc  
,FieldReasnby  
,FieldPathtime  
,FieldQueuesize  
,FieldTimequeue  
,FieldPantoready  
,FieldExptraveldist  
,FieldExptraveltime  
,FieldGpstraveldist  
,FieldFsgroup  
,FieldGloc  
,FieldHpgps  
,FieldPv3sup  
,FieldLastrftagtime  
,FieldActpoly  
,FieldPrestartdone  
,FieldPresunit  
,FieldPandh  
,FieldFirstdipper  
,FieldLastdipper  
,FieldBktcnt  
,FieldCnt  
,FieldPantoid  
,FieldPantouploc  
,FieldPantoupdist  
,FieldPantoupvel  
,FieldPantotime  
,FieldPantoerror  
,FieldWstation  
,FieldLocaction  
,FieldLvsproxcnt  
,FieldTdowntime  
,FieldGpsok  
,FieldStart  
,FieldLastgps  
,FieldGpstime  
,FieldLastgpsupdate  
,FieldTdbar  
,FieldTdrelease  
,FieldIgnunexarr  
,FieldFueled  
,FieldFueltime  
,FieldFuelfact  
,FieldOemfueltime  
,FieldHdwtype  
,FieldServiceshop  
,FieldMaintdate  
,FieldLastservicedate  
,FieldMainthours  
,FieldEnghr  
,FieldEnghr2  
,FieldEnghrtime  
,FieldEnghrtime2  
,FieldEqreq  
,FieldIsauxil  
,FieldDumping  
,FieldPmid  
,FieldDevver  
,FieldDevhw  
,FieldDevbc  
,FieldDevop  
,FieldLoadside  
,FieldLoadsidelk  
,FieldRuntime  
,FieldFuelenghr  
,FieldFuelenghr2  
,FieldIntf_data  
,logical_delete_flag  
,orig_src_id  
,site_code  
,capture_ts_utc  
,integrate_ts_utc  
,NULL AS FIELDLOADTYPE        
,NULL AS FIELDRULELASTTIME        
,NULL AS FIELDSHVBKTCNT        
,NULL AS FIELDSHVFIRSTBKT        
,NULL AS FIELDSHVLASTBKT   
from [CERReferenceCache].[dbo].[lh2_pit_truck_b] WITH(NOLOCK)


