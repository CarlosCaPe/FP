
-- ==================================================================================
-- Author:        David Purba
-- Create date:   2025-11-17
-- Description:   Returns a hardcoded dummy CO alert item
--                for a given SiteCode. No table access yet.
-- ==================================================================================
CREATE     PROCEDURE [dbo].[MyAction_Alerts_Get]
(
    @SITE varchar(4)
)
AS
BEGIN
BEGIN TRY

    SET NOCOUNT ON;

    DECLARE @UtcNow datetime2 = SYSUTCDATETIME();
    
    WITH Destinations AS
    (
        /*SELECT DestinationID
        FROM (VALUES
            ('0061036114'),
            ('0060092254'),
            ('0060092258'),
            ('0000275624'),
            ('0060083868'),
            ('0060024330'),
            ('0061016384')
        )AS V (DestinationID)*/
        SELECT DestinationID
        FROM (VALUES
            ('0061036114')
        )AS V (DestinationID)
    )


    SELECT
        CAST(NULL AS int)              AS ItemID,
        'Auto Drill Alert'             AS ItemTitle,
        'Drill:S15 - Location:7019863410 - Operator:COKER DALLAS' AS ItemBody,
        CAST(NULL AS nvarchar(max))    AS ItemDetail,
        CAST(NULL AS nvarchar(200))    AS ItemIcon, 
        'https://conops.apps-dev.fmi.com/#/sites/' + @SITE + '/drillAndBlast' AS ItemUrl,
        CAST(NULL AS nvarchar(50))     AS AlertDateText,
        @UtcNow     AS UtcAlertDate,
        @UtcNow    AS UtcStartDate,
        DATEADD( day,1,@UtcNow)   AS UtcEndDate,
        CAST(NULL AS nvarchar(50))     AS MobilePageDetailType,
        'ALE00001'                     AS AlertID,
        D.DestinationID                AS DestinationID
    FROM Destinations AS D;

END TRY
BEGIN CATCH
	PRINT ERROR_MESSAGE();
END CATCH
END
