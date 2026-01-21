CREATE VIEW [BAG].[SHIFT_DUMP_V] AS


CREATE VIEW [bag].[SHIFT_DUMP_V]      
AS      

WITH CTE AS (     
SELECT       
DbPrevious      
,DbNext      
,DbVersion      
,CASE WHEN fieldtimedump >= 43200 THEN       
      
CASE WHEN RIGHT(shiftid,1) = 1       
THEN CONCAT(LEFT(shiftid,8),'2')            
ELSE CONCAT(RIGHT(CONVERT(VARCHAR(8), DATEADD(DAY, 1, CONVERT(DATETIME, CONCAT('20',LEFT(shiftid,6)), 112)), 112),6),'001')  END    
      
ELSE shiftid END AS shiftid
,shiftid [OrigShiftid]
,Id      
,DbName      
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
,FieldMeasuretime      
,FieldWeightst      
,UTC_CREATED_DATE      
,UTC_LOGICAL_DELETED_DATE      
FROM BAG.SHIFT_DUMP WITH (NOLOCK)    
WHERE UTC_LOGICAL_DELETED_DATE IS NULL    ) 

SELECT 
shiftid
,OrigShiftid
,Id  
,FieldLoc            
,FieldExcav 
,FieldGrade
,FieldLsizetons   
,FieldLoad     
,FieldTimedump   
,FieldLoadrec  
,FieldTimeempty    
,FieldTimearrive    
,FieldTruck 
FROM CTE ;

