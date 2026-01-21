

/******************************************************************  
* PROCEDURE : dbo.[UPSERT_CONOPS_PLAN_HOLE]
* PURPOSE	: Upsert [UPSERT_CONOPS_PLAN_HOLE]
* NOTES     : 
* CREATED	: lwasini
* SAMPLE    : EXEC dbo.[UPSERT_CONOPS_PLAN_HOLE] 
* MODIFIED DATE		AUTHOR				DESCRIPTION  
*------------------------------------------------------------------  
* {25 OCT 2022}		{lwasini}			{Initial Created}  
*******************************************************************/  
CREATE  PROCEDURE [dbo].[UPSERT_CONOPS_PLAN_HOLE]
AS
BEGIN

MERGE mor.plan_hole AS T 
USING (SELECT 
	 Id
	,DrillPlanId
	,HoleId
	,OriginalHoleId
	,RigSerialNumber
	,StartPointX
	,StartPointY
	,StartPointZ
	,EndPointX
	,EndPointY
	,EndPointZ
	,TypeOfHole
	,HoleStatus
	,DrillBitDiameter
	,DrillBitType
	,MeasureWhileDrilling
	,DrillBitChange
	,IsDeleted
	,HoleName
	,RawStartPointX
	,RawStartPointY
	,RawStartPointZ
	,RawEndPointX
	,RawEndPointY
	,RawEndPointZ
	,UTC_CREATED_DATE 
	,UTC_LOGICAL_DELETED_DATE
 FROM mor.plan_hole_stg
 WHERE CHANGE_TYPE IN ('U','I')) AS S 
 ON (T.Id = S.Id ) 
 WHEN MATCHED 
 THEN UPDATE SET 
	T.DrillPlanId = S.DrillPlanId
	,T.HoleId = S.HoleId
	,T.OriginalHoleId = S.OriginalHoleId
	,T.RigSerialNumber = S.RigSerialNumber
	,T.StartPointX = S.StartPointX
	,T.StartPointY = S.StartPointY
	,T.StartPointZ = S.StartPointZ
	,T.EndPointX = S.EndPointX
	,T.EndPointY = S.EndPointY
	,T.EndPointZ = S.EndPointZ
	,T.TypeOfHole = S.TypeOfHole
	,T.HoleStatus = S.HoleStatus
	,T.DrillBitDiameter = S.DrillBitDiameter
	,T.DrillBitType = S.DrillBitType
	,T.MeasureWhileDrilling = S.MeasureWhileDrilling
	,T.DrillBitChange = S.DrillBitChange
	,T.IsDeleted = S.IsDeleted
	,T.HoleName = S.HoleName
	,T.RawStartPointX = S.RawStartPointX
	,T.RawStartPointY = S.RawStartPointY
	,T.RawStartPointZ = S.RawStartPointZ
	,T.RawEndPointX = S.RawEndPointX
	,T.RawEndPointY = S.RawEndPointY
	,T.RawEndPointZ = S.RawEndPointZ
	,T.UTC_CREATED_DATE = S.UTC_CREATED_DATE 
	,T.UTC_LOGICAL_DELETED_DATE = S.UTC_LOGICAL_DELETED_DATE 
 WHEN NOT MATCHED 
 THEN INSERT ( 
	 Id
	,DrillPlanId
	,HoleId
	,OriginalHoleId
	,RigSerialNumber
	,StartPointX
	,StartPointY
	,StartPointZ
	,EndPointX
	,EndPointY
	,EndPointZ
	,TypeOfHole
	,HoleStatus
	,DrillBitDiameter
	,DrillBitType
	,MeasureWhileDrilling
	,DrillBitChange
	,IsDeleted
	,HoleName
	,RawStartPointX
	,RawStartPointY
	,RawStartPointZ
	,RawEndPointX
	,RawEndPointY
	,RawEndPointZ
	,UTC_CREATED_DATE 
	,UTC_LOGICAL_DELETED_DATE 
  ) VALUES( 
	 S.Id
	,S.DrillPlanId
	,S.HoleId
	,S.OriginalHoleId
	,S.RigSerialNumber
	,S.StartPointX
	,S.StartPointY
	,S.StartPointZ
	,S.EndPointX
	,S.EndPointY
	,S.EndPointZ
	,S.TypeOfHole
	,S.HoleStatus
	,S.DrillBitDiameter
	,S.DrillBitType
	,S.MeasureWhileDrilling
	,S.DrillBitChange
	,S.IsDeleted
	,S.HoleName
	,S.RawStartPointX
	,S.RawStartPointY
	,S.RawStartPointZ
	,S.RawEndPointX
	,S.RawEndPointY
	,S.RawEndPointZ
	,S.UTC_CREATED_DATE 
	,S.UTC_LOGICAL_DELETED_DATE 
 ); 
  UPDATE T 
 SET 
 T.UTC_LOGICAL_DELETED_DATE = GETUTCDATE() 
 FROM mor.plan_hole AS T 
 LEFT JOIN mor.plan_hole_stg AS S 
 ON ( 
 T.Id = S.Id) 
 WHERE S.CHANGE_TYPE IN ('D'); 
 
END


