
/******************************************************************  
* PROCEDURE   : LoadAndHaulTP_TonsHauledPerHour_Get_Test
* PURPOSE     : Copy of dbo.CrushAndConvey_Throughput_Get for testing
* NOTES       : Identical logic; only the procedure name differs
* CREATED     : 29 Sep 2025
* SAMPLE      : 
    1. EXEC dbo.CrushAndConvey_Throughput_Get_Test 'CURR', 'TYR'
*******************************************************************/ 
CREATE PROCEDURE [dbo].[CrushAndConvey_Throughput_Get_Test] 
(
    @SHIFT VARCHAR(4),
    @SITE  VARCHAR(4)
)
AS
BEGIN
    BEGIN TRY

        IF @SITE = 'BAG'
        BEGIN
            SELECT ShiftFlag
                 , SiteFlag
                 , CrusherLoc AS Crusher
                 , ROUND(SensorValue,0) AS SensorValue
                 , Hr
                 , Hos
            FROM [bag].[CONOPS_BAG_CM_HOURLY_CRUSHER_THROUGHPUT_V] WITH (NOLOCK)
            WHERE ShiftFlag = @SHIFT
              AND Hr IS NOT NULL
              AND Hos > 0;

            SELECT ShiftFlag
                 , SiteFlag
                 , CrusherLoc AS Crusher
                 , ROUND(HrAvgThroughput,0)   AS HrAvgThroughput
                 , ROUND(ShfAvgThroughput,0)  AS ShfAvgThroughput
            FROM [bag].[CONOPS_BAG_CM_AVG_THROUGHPUT_V] WITH (NOLOCK)
            WHERE ShiftFlag = @SHIFT;

            SELECT
                Name,
                ((SUM(MillOreActual) + SUM(LeachActual)) * 1000.0 + 111) AS CumulativeThroughput
            FROM [bag].[CONOPS_BAG_MATERIAL_DELIVERED_TO_CHRUSHER_V] AS ca WITH (NOLOCK)
            WHERE ShiftFlag = @SHIFT
            GROUP BY Name;

            SELECT
                ShiftFlag
              , NULL AS RockBreakerUsage
              , NULL AS TonnageFines
            FROM [BAG].[CONOPS_BAG_SHIFT_INFO_V]
            WHERE ShiftFlag = @SHIFT;
        END

        ELSE IF @SITE = 'CVE'
        BEGIN
            SELECT ShiftFlag
                 , SiteFlag
                 , CrusherLoc AS Crusher
                 , ROUND(SensorValue,0) AS SensorValue
                 , Hr
                 , Hos
            FROM [cer].[CONOPS_CER_CM_HOURLY_CRUSHER_THROUGHPUT_V] WITH (NOLOCK)
            WHERE ShiftFlag = @SHIFT
              AND Hr IS NOT NULL
              AND Hos > 0;

            SELECT ShiftFlag
                 , SiteFlag
                 , CrusherLoc AS Crusher
                 , ROUND(HrAvgThroughput,0)   AS HrAvgThroughput
                 , ROUND(ShfAvgThroughput,0)  AS ShfAvgThroughput
            FROM [cer].[CONOPS_CER_CM_AVG_THROUGHPUT_V] WITH (NOLOCK)
            WHERE ShiftFlag = @SHIFT;

            SELECT
                CASE WHEN Name = 'MILLCHAN'   THEN 'C1 MillChan'
                     WHEN Name = 'MILLCRUSH1' THEN 'MillCrush 1'
                     WHEN Name = 'MILLCRUSH2' THEN 'MillCrush 2'
                     WHEN Name = 'HIDROCHAN'  THEN 'HidroChan'
                     ELSE Name END AS Name,
                ((SUM(MillOreActual) + SUM(LeachActual)) * 1000.0 + 111) AS CumulativeThroughput
            FROM [cer].[CONOPS_CER_MATERIAL_DELIVERED_TO_CHRUSHER_V] AS ca WITH (NOLOCK)
            WHERE ShiftFlag = @SHIFT
            GROUP BY Name;

            SELECT
                ShiftFlag
              , NULL AS RockBreakerUsage
              , NULL AS TonnageFines
            FROM [CER].[CONOPS_CER_SHIFT_INFO_V]
            WHERE ShiftFlag = @SHIFT;
        END

        ELSE IF @SITE = 'CHN'
        BEGIN
            SELECT ShiftFlag
                 , SiteFlag
                 , CrusherLoc AS Crusher
                 , ROUND(SensorValue,0) AS SensorValue
                 , Hr
                 , Hos
            FROM [chi].[CONOPS_CHI_CM_HOURLY_CRUSHER_THROUGHPUT_V] WITH (NOLOCK)
            WHERE ShiftFlag = @SHIFT
              AND Hr IS NOT NULL
              AND Hos > 0;

            SELECT ShiftFlag
                 , SiteFlag
             