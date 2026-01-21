



  
/******************************************************************    
* PROCEDURE : [MOR].[UPSERT_CONOPS_XECUTE_PLAN_VALUES]   
* PURPOSE : UPSERT [UPSERT_CONOPS_XECUTE_PLAN_VALUES]  
* NOTES     :   
* CREATED : GGOSAL1  
* SAMPLE    : EXEC MOR.[UPSERT_CONOPS_XECUTE_PLAN_VALUES]  
* MODIFIED DATE  AUTHOR    DESCRIPTION    
*------------------------------------------------------------------    
* {16 JAN 2025}  {GGOSAL1}   {INITIAL CREATED}  
*******************************************************************/    

CREATE PROCEDURE [MOR].[UPSERT_CONOPS_XECUTE_PLAN_VALUES]  
AS  
BEGIN  

MERGE MOR.XECUTE_PLAN_VALUES AS T
USING (
    SELECT
        Pit,
        Bench,
        Destination,
        Material,
        Shovel,
        PeriodStart,
        PeriodFinish,
        PeriodName,
        CASE 
            WHEN RIGHT(PeriodName, 1) = '1' THEN CONCAT(RIGHT(REPLACE(CAST(LEFT(PeriodName, CHARINDEX('-', PeriodName) - 1) AS DATE), '-', ''), 6), '001')
            ELSE CONCAT(RIGHT(REPLACE(CAST(LEFT(PeriodName, CHARINDEX('-', PeriodName) - 1) AS DATE), '-', ''), 6), '002')
        END AS Formatshiftid,
        PolygonType,
        PolygonName,
        Ton,
        DTCUxTon,
        MKSxTon,
        MLTxTon,
        PYRxTon,
        RDTCUxTon,
        TCUxTon,
        TMOxTon,
        XCUxTon,
        XDIVTxTon,
        TruckHours,
        EFHxTon,
        CycleTimexTon,
        NetVal_Mill,
        NetVal_MFL,
        NetVal_MillReh,
        NetVal_MFLReh,
        NetVal_HG,
        NetVal_LG,
        NetVal_OX,
        NetVal_MEH,
        NetVal_AcidConsume,
        NetVal_Waste,
        GETUTCDATE() AS dw_load_ts
    FROM MOR.XECUTE_PLAN_VALUES_STG
) AS S
ON (
    T.Pit = S.Pit AND
    T.Bench = S.Bench AND
    T.Destination = S.Destination AND
    T.Material = S.Material AND
    T.Shovel = S.Shovel AND
    T.PeriodStart = S.PeriodStart AND
    T.PeriodFinish = S.PeriodFinish AND
    T.PeriodName = S.PeriodName AND
    T.PolygonType = S.PolygonType AND
    T.PolygonName = S.PolygonName
)
WHEN MATCHED THEN
    UPDATE SET
        T.Formatshiftid = S.Formatshiftid,
        T.Ton = S.Ton,
        T.DTCUxTon = S.DTCUxTon,
        T.MKSxTon = S.MKSxTon,
        T.MLTxTon = S.MLTxTon,
        T.PYRxTon = S.PYRxTon,
        T.RDTCUxTon = S.RDTCUxTon,
        T.TCUxTon = S.TCUxTon,
        T.TMOxTon = S.TMOxTon,
        T.XCUxTon = S.XCUxTon,
        T.XDIVTxTon = S.XDIVTxTon,
        T.TruckHours = S.TruckHours,
        T.EFHxTon = S.EFHxTon,
        T.CycleTimexTon = S.CycleTimexTon,
        T.NetVal_Mill = S.NetVal_Mill,
        T.NetVal_MFL = S.NetVal_MFL,
        T.NetVal_MillReh = S.NetVal_MillReh,
        T.NetVal_MFLReh = S.NetVal_MFLReh,
        T.NetVal_HG = S.NetVal_HG,
        T.NetVal_LG = S.NetVal_LG,
        T.NetVal_OX = S.NetVal_OX,
        T.NetVal_MEH = S.NetVal_MEH,
        T.NetVal_AcidConsume = S.NetVal_AcidConsume,
        T.NetVal_Waste = S.NetVal_Waste,
        T.dw_load_ts = S.dw_load_ts
WHEN NOT MATCHED THEN
    INSERT (
        Pit,
        Bench,
        Destination,
        Material,
        Shovel,
        PeriodStart,
        PeriodFinish,
        PeriodName,
        Formatshiftid,
        PolygonType,
        PolygonName,
        Ton,
        DTCUxTon,
        MKSxTon,
        MLTxTon,
        PYRxTon,
        RDTCUxTon,
        TCUxTon,
        TMOxTon,
        XCUxTon,
        XDIVTxTon,
        TruckHours,
        EFHxTon,
        CycleTimexTon,
        NetVal_Mill,
        NetVal_MFL,
        NetVal_MillReh,
        NetVal_MFLReh,
        NetVal_HG,
        NetVal_LG,
        NetVal_OX,
        NetVal_MEH,
        NetVal_AcidConsume,
        NetVal_Waste,
        dw_load_ts
    ) VALUES (
        S.Pit,
        S.Bench,
        S.Destination,
        S.Material,
        S.Shovel,
        S.PeriodStart,
        S.PeriodFinish,
        S.PeriodName,