CREATE VIEW [bag2].[MSMODEL_EQUIPMENT_CURRENT_STATUS] AS

 
--SELECT * FROM [bag2].[MSMODEL_EQUIPMENT_CURRENT_STATUS]
CREATE VIEW [bag2].[MSMODEL_EQUIPMENT_CURRENT_STATUS]
AS

WITH Last3Shift AS (
    SELECT TOP 3 
        OID,
        ROW_NUMBER() OVER (ORDER BY OID DESC) AS ROW_NO
    FROM [ConnectedOperations].[bag2].[SHIFT]
    ORDER BY OID DESC
),

Tally AS (
    SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
    FROM (VALUES (0), (0), (0), (0), (0), (0), (0), (0), (0), (0)) a(n)
    CROSS JOIN (VALUES (0), (0), (0), (0), (0), (0), (0), (0), (0), (0)) b(n)
    CROSS JOIN (VALUES (0), (0), (0), (0), (0), (0), (0), (0), (0), (0)) c(n)
    CROSS JOIN (VALUES (0), (0), (0), (0), (0), (0), (0), (0), (0), (0)) d(n)
    -- This will generate numbers from 1 to 10000. 
    -- This will help us to separate the timestamp of hours; it will be easily handled up to 1 year of the hour status
),

CAC_HOURLY AS (
    SELECT 
        OID,
        name,
        -- Tally.n,
        t.start_time_utc,
        t.END_TIME_UTC,
        CASE 
            WHEN Tally.n = 1 THEN t.start_time_utc
            ELSE DATEADD(HOUR, Tally.n - 1, DATEADD(HOUR, DATEDIFF(HOUR, 0, t.start_time_utc), 0)) 
        END AS HourStart,
        CASE 
            WHEN DATEADD(HOUR, Tally.n, DATEADD(HOUR, DATEDIFF(HOUR, 0, t.start_time_utc), 0)) > t.END_TIME_UTC 
            THEN t.END_TIME_UTC -- 1 second
            ELSE DATEADD(HOUR, Tally.n, DATEADD(HOUR, DATEDIFF(HOUR, 0, t.start_time_utc), 0)) 
        END AS HourEnd
    FROM [ConnectedOperations].[bag2].[CYCLEACTIVITYCOMPONENT] t WITH (NOLOCK)
    INNER JOIN Tally ON Tally.n <= 
        CASE 
            WHEN DATEPART(MINUTE, t.END_TIME_UTC) = 0 AND DATEPART(SECOND, t.END_TIME_UTC) = 0 
            THEN DATEDIFF(HOUR, t.start_time_utc, DATEADD(SECOND, -1, t.END_TIME_UTC))
            ELSE DATEDIFF(HOUR, t.start_time_utc, t.END_TIME_UTC) 
        END + 1
),

Delaystatus AS (
    SELECT 
        DCA.NAME AS NAME,
        DC.NAME AS DC_NAME,
        D.TARGET_MACHINE,
        D.START1_UTC,
        D.FINISH_UTC,
        DC.EXTERNALREF
    FROM [ConnectedOperations].[bag2].[DELAY] D WITH (NOLOCK)
    LEFT JOIN [ConnectedOperations].[bag2].[DELAYCLASS] DC WITH (NOLOCK)
        ON D.DELAYCLASS = DC.DELAYCLASS_OID
    LEFT JOIN [ConnectedOperations].[bag2].[DELAYCATEGORY] DCA WITH (NOLOCK)
        ON DC.DELAYCATEGORY = DCA.DELAYCATEGORY_OID
)

SELECT 
    'BAG' AS SITE_CODE,
    C.ECF_CLASS_ID,
    CONCAT(RIGHT(SUBSTRING(REPORTING_DATE, 1, 8), 6), '00', 
        CASE 
            WHEN shifttype = 0 THEN 1
            WHEN shifttype = 1 THEN 2 
            ELSE NULL
        END) AS SHIFT_ID,
    CAST(S.REPORTING_DATE AS DATE) AS SHIFT_DATE, -- ggosal1: added
    S.STARTTIME_UTC AS SHIFTSTARTTIMEUTC, -- ggosal1: added
    MC.NAME AS FIELDUNIT,
    MCA.NAME AS MACHINE_CATEGORY,
    M.NAME AS EQUIP_NAME,
    CASE 
        WHEN DS.EXTERNALREF IS NULL THEN 200
        ELSE DS.EXTERNALREF 
    END AS REASON_CODE, -- ggosal1: change column
    CASE 
        WHEN DS.DC_NAME IS NOT NULL THEN DS.DC_NAME 
        ELSE 'PRODUCTION' 
    END AS REASON_NAME,
    CASE 
        WHEN DS.NAME = 'Ready Production' THEN 1
        WHEN DS.NAME = 'Ready Non-Production' THEN 2
        WHEN DS.NAME = 'Operational Down' THEN 3
        WHEN DS.NAME = 'Scheduled Down' THEN 4
        WHEN DS.NAME = 'Unscheduled Down' THEN 5
        WHEN DS.NAME = 'Operational Delay' THEN 6
        WHEN DS.NAME = 'Spare' THEN 7
        WHEN DS.NAME = 'Non Guarantee' THEN 8
        WHEN DS.NAME = 'ShiftChange' THEN 9
        ELSE 1
    END AS CATEGORY_CODE,
    CASE 
        WHEN DS.NAME IS NOT NULL THEN DS.NAME
        ELSE 'Ready Production' 
    END AS CATEGORY, 
    CASE 
        WHEN DS.NAME = 'Ready Production' THEN 2
        WHEN DS.NAME = 'Ready Non-Production' THEN 2
        WHEN DS.NAME = 'Operational Down' THEN 1
        WHEN DS.NAME = 'Scheduled Down' THEN 1
        WHEN DS.NAME = 'Unscheduled Down' 