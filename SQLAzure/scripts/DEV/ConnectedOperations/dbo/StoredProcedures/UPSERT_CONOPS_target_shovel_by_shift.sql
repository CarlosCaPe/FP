


/******************************************************************  
* PROCEDURE : dbo.[UPSERT_CONOPS_target_shovel_by_shift]
* PURPOSE	: Upsert [UPSERT_CONOPS_target_shovel_by_shift]
* NOTES     : 
* CREATED	: lwasini
* SAMPLE    : EXEC dbo.[UPSERT_CONOPS_target_shovel_by_shift] 
* MODIFIED DATE		AUTHOR				DESCRIPTION  
*------------------------------------------------------------------  
* {25 OCT 2022}		{lwasini}			{Initial Created}  
*******************************************************************/  
CREATE  PROCEDURE [dbo].[UPSERT_CONOPS_target_shovel_by_shift]
AS
BEGIN

MERGE dbo.target_shovel_by_shift AS T 
USING (SELECT 
Shiftid
,TotalMined
,L01Ore
,L01Waste
,L02Ore
,L02Waste
,S08Ore
,S08Waste
,S10Ore
,S10Waste
,S11Ore
,S11Waste
,S12Ore
,S12Waste
,S22Ore
,S22Waste
,S23Ore
,S23Waste
,Rehandle
,E1Tons
,E3Tons
,N1Tons
,N3Tons
,S4Tons
,TotalExpitTons
,EFH
,Chrusher2
,DumpingAtCrusher
,UTC_CREATED_DATE
 FROM dbo.target_shovel_by_shift_stg) AS S 
 ON (T.Shiftid = S.Shiftid ) 

 WHEN MATCHED 
 THEN UPDATE SET 
T.TotalMined = S.TotalMined
,T.L01Ore = S.L01Ore
,T.L01Waste = S.L01Waste
,T.L02Ore = S.L02Ore
,T.L02Waste = S.L02Waste
,T.S08Ore = S.S08Ore
,T.S08Waste = S.S08Waste
,T.S10Ore = S.S10Ore
,T.S10Waste = S.S10Waste
,T.S11Ore = S.S11Ore
,T.S11Waste = S.S11Waste
,T.S12Ore = S.S12Ore
,T.S12Waste = S.S12Waste
,T.S22Ore = S.S22Ore
,T.S22Waste = S.S22Waste
,T.S23Ore = S.S23Ore
,T.S23Waste = S.S23Waste
,T.Rehandle = S.Rehandle
,T.E1Tons = S.E1Tons
,T.E3Tons = S.E3Tons
,T.N1Tons = S.N1Tons
,T.N3Tons = S.N3Tons
,T.S4Tons = S.S4Tons
,T.TotalExpitTons = S.TotalExpitTons
,T.EFH = S.EFH
,T.Chrusher2 = S.Chrusher2
,T.DumpingAtCrusher = S.DumpingAtCrusher
,T.UTC_CREATED_DATE = S.UTC_CREATED_DATE
  
 WHEN NOT MATCHED 
 THEN INSERT ( 
Shiftid
,TotalMined
,L01Ore
,L01Waste
,L02Ore
,L02Waste
,S08Ore
,S08Waste
,S10Ore
,S10Waste
,S11Ore
,S11Waste
,S12Ore
,S12Waste
,S22Ore
,S22Waste
,S23Ore
,S23Waste
,Rehandle
,E1Tons
,E3Tons
,N1Tons
,N3Tons
,S4Tons
,TotalExpitTons
,EFH
,Chrusher2
,DumpingAtCrusher
,UTC_CREATED_DATE
  ) VALUES( 
S.Shiftid
,S.TotalMined
,S.L01Ore
,S.L01Waste
,S.L02Ore
,S.L02Waste
,S.S08Ore
,S.S08Waste
,S.S10Ore
,S.S10Waste
,S.S11Ore
,S.S11Waste
,S.S12Ore
,S.S12Waste
,S.S22Ore
,S.S22Waste
,S.S23Ore
,S.S23Waste
,S.Rehandle
,S.E1Tons
,S.E3Tons
,S.N1Tons
,S.N3Tons
,S.S4Tons
,S.TotalExpitTons
,S.EFH
,S.Chrusher2
,S.DumpingAtCrusher
,S.UTC_CREATED_DATE
 ); 
 
UPDATE T 
SET 
T.UTC_LOGICAL_DELETED_DATE = GETUTCDATE() 
FROM  dbo.target_shovel_by_shift AS T 
 LEFT JOIN  dbo.target_shovel_by_shift_stg AS S 
ON ( 
T.Shiftid = S.Shiftid) ;

 
END


