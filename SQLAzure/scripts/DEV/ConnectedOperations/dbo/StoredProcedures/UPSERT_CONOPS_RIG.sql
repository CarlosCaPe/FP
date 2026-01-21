

/******************************************************************  
* PROCEDURE : dbo.[UPSERT_CONOPS_RIG]
* PURPOSE	: Upsert [UPSERT_CONOPS_RIG]
* NOTES     : 
* CREATED	: lwasini
* SAMPLE    : EXEC dbo.[UPSERT_CONOPS_RIG] 
* MODIFIED DATE		AUTHOR				DESCRIPTION  
*------------------------------------------------------------------  
* {25 OCT 2022}		{lwasini}			{Initial Created}  
*******************************************************************/  
CREATE  PROCEDURE [dbo].[UPSERT_CONOPS_RIG]
AS
BEGIN

MERGE mor.rig AS T 
USING (SELECT 
	 Id
	,Name
	,SerialNumber
	,RigInformationDate
	,ExportPath
	,RRAStatusId
	,HasGps
	,EquipmentType
	,IsArchived
	,UTC_CREATED_DATE 
	,UTC_LOGICAL_DELETED_DATE
 FROM mor.rig_stg
 WHERE CHANGE_TYPE IN ('U','I')) AS S 
 ON (T.Id = S.Id ) 
 WHEN MATCHED 
 THEN UPDATE SET 
	T.Name = S.Name
	,T.SerialNumber = S.SerialNumber
	,T.RigInformationDate = S.RigInformationDate
	,T.ExportPath = S.ExportPath
	,T.RRAStatusId = S.RRAStatusId
	,T.HasGps = S.HasGps
	,T.EquipmentType = S.EquipmentType
	,T.IsArchived = S.IsArchived
	,T.UTC_CREATED_DATE = S.UTC_CREATED_DATE 
	,T.UTC_LOGICAL_DELETED_DATE = S.UTC_LOGICAL_DELETED_DATE 
 WHEN NOT MATCHED 
 THEN INSERT ( 
	 Id
	,Name
	,SerialNumber
	,RigInformationDate
	,ExportPath
	,RRAStatusId
	,HasGps
	,EquipmentType
	,IsArchived
	,UTC_CREATED_DATE 
	,UTC_LOGICAL_DELETED_DATE 
  ) VALUES( 
	 S.Id
	,S.Name
	,S.SerialNumber
	,S.RigInformationDate
	,S.ExportPath
	,S.RRAStatusId
	,S.HasGps
	,S.EquipmentType
	,S.IsArchived
	,S.UTC_CREATED_DATE 
	,S.UTC_LOGICAL_DELETED_DATE 
 ); 
  UPDATE T 
 SET 
 T.UTC_LOGICAL_DELETED_DATE = GETUTCDATE() 
 FROM mor.rig AS T 
 LEFT JOIN mor.rig_stg AS S 
 ON ( 
 T.Id = S.Id) 
 WHERE S.CHANGE_TYPE IN ('D'); 
 
END


