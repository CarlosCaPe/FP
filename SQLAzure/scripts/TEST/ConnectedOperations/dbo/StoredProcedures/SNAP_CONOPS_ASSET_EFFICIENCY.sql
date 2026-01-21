
/******************************************************************
* PROCEDURE	: DBO.[SNAP_CONOPS_ASSET_EFFICIENCY]
* PURPOSE	: UPSERT [SNAP_CONOPS_ASSET_EFFICIENCY]
* NOTES		: 
* CREATED	: GGOSAL1
* SAMPLE	: EXEC DBO.[SNAP_CONOPS_ASSET_EFFICIENCY] 'BAG2'
* MODIFIED DATE		AUTHOR		DESCRIPTION
*------------------------------------------------------------------
* {23 JUN 2025}		{GGOSAL1}	{INITIAL CREATED}
* {10 OCT 2025}		{GGOSAL1}	{ADD BAG 2}
* {16 OCT 2025}		{GGOSAL1}	{ADD VALIDATION}
* {17 OCT 2025}		{GGOSAL1}	{ADD Insert to temp table}
* {11 NOV 2025}		{GGOSAL1}	{BAG2: Insert into temp table first before Stage for data delay alert
								 Add validation for @G_SITE to eliminate SQL Injection Risk}
*******************************************************************/

CREATE PROCEDURE [dbo].[SNAP_CONOPS_ASSET_EFFICIENCY]
(
@G_SITE VARCHAR(5)
)

AS
BEGIN

--Validation
IF @G_SITE NOT IN ('BAG','BAG2','CLI','CER','CHI','MOR','SAF','SIE','ABR','TYR')
	THROW 50000, 'Invalid site', 1;

DECLARE @G_SITE_ALIAS VARCHAR(5);
DECLARE @G_SITE_JCONTROL VARCHAR(5);

SET @G_SITE_ALIAS = CASE WHEN @G_SITE = 'CLI' THEN 'CMX'
							WHEN @G_SITE = 'BAG2' THEN 'BAG' ELSE @G_SITE END;

SET @G_SITE_JCONTROL = CASE WHEN @G_SITE = 'BAG2' THEN 'BAG' ELSE @G_SITE END;

DECLARE @ROW_COUNT INT;
DECLARE @SQL NVARCHAR(MAX);

IF @G_SITE = 'BAG2'
BEGIN
	EXEC 
	(
	' DELETE FROM ' +@G_SITE+ '.ASSET_EFFICIENCY_STG_TEMP ; '

	+' INSERT INTO ' +@G_SITE+ '.ASSET_EFFICIENCY_STG_TEMP '
	+' SELECT '
	+' SHIFTID,'
	+' EQMT,'
	+' FIELDEQMTTYPE,'
	+' EQMTTYPE,'
	+' UNITTYPE,'
	+' STARTDATETIME,'
	+' ENDDATETIME,'
	+' DURATION,'
	+' STATUSIDX,'
	+' STATUS,'
	+' CATEGORYIDX,'
	+' CATEGORY,'
	+' REASONIDX,'
	+' REASONS,'
	+' COMMENTS,'
	+' GETUTCDATE() AS UTC_CREATED_DATE FROM ' +@G_SITE+ '.ASSET_EFFICIENCY_V; '

	+' DELETE FROM ' +@G_SITE+ '.ASSET_EFFICIENCY_STG ; '

	+' INSERT INTO ' +@G_SITE+ '.ASSET_EFFICIENCY_STG '
	+' SELECT * FROM ' +@G_SITE+ '.ASSET_EFFICIENCY_STG_TEMP; '

	);
END;

IF @G_SITE <> 'BAG2'
BEGIN
	EXEC 
	(
	' DELETE FROM ' +@G_SITE+ '.ASSET_EFFICIENCY_STG ; '

	+' INSERT INTO ' +@G_SITE+ '.ASSET_EFFICIENCY_STG '
	+' SELECT '
	+' SHIFTID,'
	+' EQMT,'
	+' FIELDEQMTTYPE,'
	+' EQMTTYPE,'
	+' UNITTYPE,'
	+' STARTDATETIME,'
	+' ENDDATETIME,'
	+' DURATION,'
	+' STATUSIDX,'
	+' STATUS,'
	+' CATEGORYIDX,'
	+' CATEGORY,'
	+' REASONIDX,'
	+' REASONS,'
	+' COMMENTS,'
	+' GETUTCDATE() AS UTC_CREATED_DATE FROM ' +@G_SITE+ '.ASSET_EFFICIENCY_V; '
	);

END

-- Build the dynamic SQL to get the row count
SET @SQL = 'SELECT @RC_OUT = COUNT(*) FROM ' + QUOTENAME(@G_SITE) + '.ASSET_EFFICIENCY_STG';

-- Execute the dynamic SQL and assign the result to @ROW_COUNT
EXEC sp_executesql @SQL, N'@RC_OUT INT OUTPUT', @RC_OUT = @ROW_COUNT OUTPUT;

IF @ROW_COUNT <> 0
BEGIN
	EXEC(
	' MERGE ' +@G_SITE+ '.ASSET_EFFICIENCY AS T '
	+' USING (SELECT '
	+' ''' +@G_SITE_ALIAS+ ''' AS SITEFLAG,' 
	+' SHIFTID,'
	+' EQMT,'
	+' FIELDEQMTTYPE,'
	+' EQMTTYPE,'
	+' UNITTYPE,'
	+' STARTDATETIME,'
	+' ENDDATETIME,'
	+' DURATION,'
	+' STATUSIDX,'
	+' STATUS,'
	+' CATEGORYIDX,'
	+' CATEGORY,'
	+' REASONIDX,'
	+' REASONS,'
	+' COMMENTS,'
	+' UTC_CREATED_DATE'
	+' FROM ' +@G_SITE+ '.ASSET_EFFICIENCY_STG) AS S '
	+' ON (T.SHIFTID = S.SHIFTID AND T.EQMT = S.EQMT AND T.STARTDATETIME = S.STARTDATETIME AND T.SITEFLAG = S.SITEFLAG) ' 
	+' WHEN MATCHED ' 
	+' THEN UPDATE SET ' 
	+' T.FIELDEQMTTYPE = S.FIELDEQMTTYPE,'
	+' T.EQMTTYPE = S.EQMTTYPE,'
	+' T.UNITTYPE = S.UNITTYPE,'
	+' T.ENDDATETIME = S.ENDDATETIME,'
	+' T.DURATION = S.DURATION,'
	+' T.STATUSIDX = S.STATUSIDX,'
	+' T.STATUS = S.STATUS,'
	+' T.CATEGORYIDX = S.CATEGORYIDX,'
	+' T.CATEGORY = S.CATEGORY,'
	+' T.REASONIDX = S.REASONIDX,'
	+' T.REASONS = S.REASONS,'
	+' T.COMMENTS = S.COMMENTS,'
	+' T.UTC_CREATED_DATE = S.UTC_CREATED_DATE'
	+' WHEN NOT MATCHED ' 
	+' THEN INSERT ( '
	+' SITEFLAG,' 
	+' SHIFTI