

/******************************************************************  
* PROCEDURE : dbo.[UPSERT_CONOPS_DRILL_HOLE]
* PURPOSE	: Upsert [UPSERT_CONOPS_DRILL_HOLE]
* NOTES     : 
* CREATED	: lwasini
* SAMPLE    : EXEC dbo.[UPSERT_CONOPS_DRILL_HOLE] 
* MODIFIED DATE		AUTHOR				DESCRIPTION  
*------------------------------------------------------------------  
* {25 OCT 2022}		{lwasini}			{Initial Created}  
*******************************************************************/  
CREATE  PROCEDURE [dbo].[UPSERT_CONOPS_DRILL_HOLE]
AS
BEGIN

MERGE mor.drill_hole AS T 
USING (SELECT 
	 Id
	,DrillPlanId
	,HoleId
	,RigSerialNumber
	,StartPointX
	,StartPointY
	,StartPointZ
	,EndPointX
	,EndPointY
	,EndPointZ
	,TypeOfHole
	,DrillBitDiameter
	,DrillBitType
	,MeasureWhileDrilling
	,DrillBitChange
	,StartHoleTime
	,EndHoleTime
	,AveragePenetrationRateInMetersPerMinute
	,SequenceNumber
	,NumberOfStops
	,Status
	,PositioningMode
	,AnchoringMode
	,CollaringMode
	,DrillMode
	,ActivationMode
	,StartLogTime
	,OperatorName
	,GpsQuality
	,TowerAngle
	,DrillBitId
	,DrilledInRock
	,HoleName
	,RawStartPointX
	,RawStartPointY
	,RawStartPointZ
	,RawEndPointX
	,RawEndPointY
	,RawEndPointZ
	,IsEdited
	,Comment
	,UTC_CREATED_DATE 
	,UTC_LOGICAL_DELETED_DATE
 FROM mor.drill_hole_stg
 WHERE CHANGE_TYPE IN ('U','I')) AS S 
 ON (T.Id = S.Id ) 
 WHEN MATCHED 
 THEN UPDATE SET 
	T.DrillPlanId = S.DrillPlanId
	,T.HoleId = S.HoleId
	,T.RigSerialNumber = S.RigSerialNumber
	,T.StartPointX = S.StartPointX
	,T.StartPointY = S.StartPointY
	,T.StartPointZ = S.StartPointZ
	,T.EndPointX = S.EndPointX
	,T.EndPointY = S.EndPointY
	,T.EndPointZ = S.EndPointZ
	,T.TypeOfHole = S.TypeOfHole
	,T.DrillBitDiameter = S.DrillBitDiameter
	,T.DrillBitType = S.DrillBitType
	,T.MeasureWhileDrilling = S.MeasureWhileDrilling
	,T.DrillBitChange = S.DrillBitChange
	,T.StartHoleTime = S.StartHoleTime
	,T.EndHoleTime = S.EndHoleTime
	,T.AveragePenetrationRateInMetersPerMinute = S.AveragePenetrationRateInMetersPerMinute
	,T.SequenceNumber = S.SequenceNumber
	,T.NumberOfStops = S.NumberOfStops
	,T.Status = S.Status
	,T.PositioningMode = S.PositioningMode
	,T.AnchoringMode = S.AnchoringMode
	,T.CollaringMode = S.CollaringMode
	,T.DrillMode = S.DrillMode
	,T.ActivationMode = S.ActivationMode
	,T.StartLogTime = S.StartLogTime
	,T.OperatorName = S.OperatorName
	,T.GpsQuality = S.GpsQuality
	,T.TowerAngle = S.TowerAngle
	,T.DrillBitId = S.DrillBitId
	,T.DrilledInRock = S.DrilledInRock
	,T.HoleName = S.HoleName
	,T.RawStartPointX = S.RawStartPointX
	,T.RawStartPointY = S.RawStartPointY
	,T.RawStartPointZ = S.RawStartPointZ
	,T.RawEndPointX = S.RawEndPointX
	,T.RawEndPointY = S.RawEndPointY
	,T.RawEndPointZ = S.RawEndPointZ
	,T.IsEdited = S.IsEdited
	,T.Comment = S.Comment
	,T.UTC_CREATED_DATE = S.UTC_CREATED_DATE 
	,T.UTC_LOGICAL_DELETED_DATE = S.UTC_LOGICAL_DELETED_DATE 
 WHEN NOT MATCHED 
 THEN INSERT ( 
	 Id
	,DrillPlanId
	,HoleId
	,RigSerialNumber
	,StartPointX
	,StartPointY
	,StartPointZ
	,EndPointX
	,EndPointY
	,EndPointZ
	,TypeOfHole
	,DrillBitDiameter
	,DrillBitType
	,MeasureWhileDrilling
	,DrillBitChange
	,StartHoleTime
	,EndHoleTime
	,AveragePenetrationRateInMetersPerMinute
	,SequenceNumber
	,NumberOfStops
	,Status
	,PositioningMode
	,AnchoringMode
	,CollaringMode
	,DrillMode
	,ActivationMode
	,StartLogTime
	,OperatorName
	,GpsQuality
	,TowerAngle
	,DrillBitId
	,DrilledInRock
	,HoleName
	,RawStartPointX
	,RawStartPointY
	,RawStartPointZ
	,RawEndPointX
	,RawEndPointY
	,RawEndPointZ
	,IsEdited
	,Comment
	,UTC_CREATED_DATE 
	,UTC_LOGICAL_DELETED_DATE 
  ) VALUES( 
	 S.Id
	,S.DrillPlanId
	,S.HoleId
	,S.RigSerialNumber
	,S.StartPointX
	,S.StartPointY
	,S.StartPointZ
	,S.EndPointX
	,S.EndPointY
	,S.EndPointZ
	,S.TypeOfHole
	,S.DrillBitDiameter
	,S.DrillBitType
	,S.MeasureWhileDrilling
	,S.DrillBitChange
	,S.StartHoleTime
	,S.EndHo