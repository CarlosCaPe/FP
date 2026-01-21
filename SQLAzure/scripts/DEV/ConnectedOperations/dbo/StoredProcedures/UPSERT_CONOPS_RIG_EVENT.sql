

/******************************************************************  
* PROCEDURE : dbo.[UPSERT_CONOPS_RIG_EVENT]
* PURPOSE	: Upsert [UPSERT_CONOPS_RIG_EVENT]
* NOTES     : 
* CREATED	: lwasini
* SAMPLE    : EXEC dbo.[UPSERT_CONOPS_RIG_EVENT] 
* MODIFIED DATE		AUTHOR				DESCRIPTION  
*------------------------------------------------------------------  
* {25 OCT 2022}		{lwasini}			{Initial Created}  
*******************************************************************/  
CREATE  PROCEDURE [dbo].[UPSERT_CONOPS_RIG_EVENT]
AS
BEGIN

MERGE mor.rig_event AS T 
USING (SELECT 
	 Id
	,RigId
	,Time
	,Data
	,TypeOfEventId
	,EndTime
	,IsEdited
	,Comment
	,TumCodeId
	,IsTumCode
	,UTC_CREATED_DATE 
	,UTC_LOGICAL_DELETED_DATE
 FROM mor.rig_event_stg
 WHERE CHANGE_TYPE IN ('U','I')) AS S 
 ON (T.Id = S.Id ) 
 WHEN MATCHED 
 THEN UPDATE SET 
	T.RigId = S.RigId
	,T.Time = S.Time
	,T.Data = S.Data
	,T.TypeOfEventId = S.TypeOfEventId
	,T.EndTime = S.EndTime
	,T.IsEdited = S.IsEdited
	,T.Comment = S.Comment
	,T.TumCodeId = S.TumCodeId
	,T.IsTumCode = S.IsTumCode
	,T.UTC_CREATED_DATE = S.UTC_CREATED_DATE 
	,T.UTC_LOGICAL_DELETED_DATE = S.UTC_LOGICAL_DELETED_DATE 
 WHEN NOT MATCHED 
 THEN INSERT ( 
	 Id
	,RigId
	,Time
	,Data
	,TypeOfEventId
	,EndTime
	,IsEdited
	,Comment
	,TumCodeId
	,IsTumCode
	,UTC_CREATED_DATE 
	,UTC_LOGICAL_DELETED_DATE 
  ) VALUES( 
	 S.Id
	,S.RigId
	,S.Time
	,S.Data
	,S.TypeOfEventId
	,S.EndTime
	,S.IsEdited
	,S.Comment
	,S.TumCodeId
	,S.IsTumCode
	,S.UTC_CREATED_DATE 
	,S.UTC_LOGICAL_DELETED_DATE 
 ); 
  UPDATE T 
 SET 
 T.UTC_LOGICAL_DELETED_DATE = GETUTCDATE() 
 FROM mor.rig_event AS T 
 LEFT JOIN mor.rig_event_stg AS S 
 ON ( 
 T.Id = S.Id) 
 WHERE S.CHANGE_TYPE IN ('D'); 
 
END


