CREATE VIEW [TYR].[CONOPS_TYR_SP_DELTA_C_AVG_V] AS

   
--SELECT * FROM [saf].[CONOPS_TYR_SP_DELTA_C_AVG_V]    
CREATE VIEW [TYR].[CONOPS_TYR_SP_DELTA_C_AVG_V]     
AS    
    
SELECT a.site_code,    
       a.shiftindex,    
       a.excav,    
       avg(a.deltac) AS deltac,    
       avg(a.idletime) AS idletime,    
       avg(a.spottime) AS spottime,    
       avg(a.loadtime) AS loadtime,    
       avg(a.dumpingtime) AS dumpingtime,  
    (AVG(hangtime)/60.0) AS hangtime,  
       avg(b.DumpingAtStockpile) AS DumpingAtStockpile,    
       avg(c.DumpingAtCrusher) AS DumpingAtCrusher,    
       a.EFH,    
       avg(a.TRAVELEMPTY) AS EmptyTravel,    
       avg(a.TRAVELLOADED) AS LoadedTravel    
FROM    
    (SELECT site_code,    
      shiftindex,    
            excav,    
            avg(delta_c) AS deltac,    
            avg(idletime) AS idletime,    
            avg(spottime) AS spottime,    
            avg(loadtime) AS loadtime,    
            avg(DumpingTime) AS DumpingTime,   
   AVG(hangtime) AS hangtime,  
   avg(distloaded + (fliftup * 27.1428) + (fliftdown * 16)) AS EFH,    
            avg(TRAVELEMPTY) AS TRAVELEMPTY,    
            avg(TRAVELLOADED) AS TRAVELLOADED    
     FROM dbo.delta_c WITH (NOLOCK)    
     WHERE site_code = 'TYR'    
     GROUP BY site_code, shiftindex, excav    
) a    
LEFT JOIN (    
  SELECT shiftindex,    
            excav,    
            CASE    
                WHEN unit = 'Stockpile' THEN COALESCE(avg([dumpdelta]), 0)    
            END AS DumpingAtStockpile    
     FROM dbo.delta_c WITH (NOLOCK)    
     WHERE site_code = 'TYR'    
     GROUP BY site_code, shiftindex, excav, unit    
) b ON a.shiftindex = b.shiftindex AND a.excav = b.excav    
LEFT JOIN (    
  SELECT shiftindex,    
            excav,    
            CASE    
                WHEN unit = 'Crusher' THEN COALESCE(avg([dumpdelta]), 0)    
            END AS DumpingAtCrusher    
     FROM dbo.delta_c WITH (NOLOCK)    
     WHERE site_code = 'TYR'    
     GROUP BY site_code, shiftindex, excav,  unit    
) c ON a.shiftindex = c.shiftindex AND a.excav = c.excav    
WHERE a.site_code = 'TYR'    
GROUP BY a.site_code, a.shiftindex, a.excav, a.efh    
    
    
  
