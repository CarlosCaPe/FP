
CREATE   PROCEDURE [dbo].[GetAutoDrillData_TEMP] (
    @site varchar(64),
    @SerialNumber varchar(100),
    @DrillPlanId varchar(100),
    @DrillPlanName varchar(200),
    @HoleId varchar(100),
    @StartHoleTime datetime

   
)
AS
BEGIN
    SELECT 
        CONCAT('MOR-', DrillPlanId, '.drill_type') as sensor_id ,

            CASE 
                WHEN AutoDrillSeconds > 0 THEN 'auto_drill' -- <drill_type>
                WHEN DrillStateSeconds > 0 THEN 'manual_drill'
                ELSE 'unknown'
            END
         AS value ,
         'SURFACEMANAGER' AS [data_source],
         DATEADD(HOUR, 7, StartHoleTime) AS [timestamp],

         NULL AS [uom],
         1 AS [quality],
        CONCAT(
            '{"operator_name": "', OperatorName, 
            '", "supervisor_name": "', COALESCE (Supervisor_Name, 'N/A'), '"}'
        ) AS annotations
    FROM [dbo].[AutoFunctionUsage_TEST] af
    left join [dbo].[Employee_Data_TEMP] e
        ON af.OperatorName = e.[employee_id]
    where Site          =   @site
    and SerialNumber    =   @SerialNumber
    and DrillPlanId     =   @DrillPlanId
    and DrillPlanName   =   @DrillPlanName
    and HoleId          =   @HoleId
    and StartHoleTime   =   @StartHoleTime
;
END;