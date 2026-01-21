CREATE VIEW [BAG].[asset_efficiency] AS


--SELECT * FROM [bag].[asset_efficiency] WITH (NOLOCK)  
CREATE   VIEW [BAG].[asset_efficiency]     
AS

SELECT 
[SITEFLAG]
          ,[SHIFTID]
          ,[EQMT]
          ,[FIELDEQMTTYPE]
          ,[EQMTTYPE]
          ,[UNITTYPE]
          ,[STARTDATETIME]
          ,[ENDDATETIME]
          ,[DURATION]
          ,[STATUSIDX]
          ,[STATUS]
          ,[CATEGORYIDX]
          ,[CATEGORY]
          ,[REASONIDX]
          ,[REASONS]
          ,[COMMENTS]
          ,[UTC_CREATED_DATE]
FROM bag2.asset_efficiency ae WITH(NOLOCK)

