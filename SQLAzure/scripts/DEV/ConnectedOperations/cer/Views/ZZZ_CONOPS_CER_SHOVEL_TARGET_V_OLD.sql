CREATE VIEW [cer].[ZZZ_CONOPS_CER_SHOVEL_TARGET_V_OLD] AS




-- SELECT * FROM [cer].[CONOPS_CER_SHOVEL_TARGET_V] order by shiftid, shovel
CREATE VIEW [cer].[CONOPS_CER_SHOVEL_TARGET_V_OLD]
AS

WITH PLANV AS (
    SELECT SUBSTRING(TITLE, 1, 3) + '-' + RIGHT(TITLE, 2) AS ShiftDate
        ,ISNULL(SHOVEL06, 0) AS P06
        ,ISNULL(SHOVEL07, 0) AS P07
        ,ISNULL(SHOVEL09, 0) AS P09
        ,ISNULL(SHOVEL11, 0) AS P11
        ,ISNULL(SHOVEL12, 0) AS P12
        ,ISNULL(SHOVEL14, 0) AS P14
        ,ISNULL(SHOVEL15, 0) AS P15
        ,ISNULL(SHOVEL16, 0) AS P16
        ,ISNULL(SHOVEL17, 0) AS P17
        ,ISNULL(SHOVEL18, 0) AS P18
        ,ISNULL(SHOVEL19, 0) AS P19
        ,ISNULL(SHOVEL20, 0) AS P20
        ,ISNULL(SHOVEL21,0) AS P21
		,ISNULL(SHOVEL09,0) AS P22
        ,ISNULL(CV4, 0) AS CF24
        ,ISNULL(CV5, 0) AS CF25
        ,ISNULL(CV6, 0) AS CF26
    FROM [cer].[PLAN_VALUES] (NOLOCK)
), 

SHOVEL AS (
	SELECT ShiftId
		,ShovelId
			
	FROM [cer].[CONOPS_CER_SHIFT_INFO_V] [si]
	LEFT JOIN [PLANV] unpivot (Tons
                              		FOR ShovelId in (
                                    	P06, P07, P09, P11, P12, P14,
										P16, P17, P18, P19, P20, P21,
										P22, CF24, CF25, CF26
                                    )
                               ) unpiv 
	ON CAST( FORMAT( CAST( SUBSTRING( CAST( [si].ShiftId AS varchar(max)), 1, 6 ) AS date), 'MMM' ) AS VARCHAR(3)) + '-' + CAST( SUBSTRING( CAST( [si].ShiftId AS varchar(max)), 1, 2 ) AS VARCHAR(2)) = [unpiv].ShiftDate
	WHERE [si].[shiftflag] IN ('CURR', 'PREV')
) 


SELECT shiftid,
       shovel,
       COALESCE(sum(shovelshifttarget), 0) AS shovelshifttarget
FROM (
   SELECT shiftid,
          Shovelid AS shovel,
          cast(sum(Tons) AS int) AS shovelshifttarget
   FROM (
	  SELECT ShiftId,
            Shovelid,
            Tons
      FROM (
			SELECT [s].ShiftId,
				[s].ShovelId,
				[pv].[TONELADAS] as Tons
			FROM SHOVEL [s]
			LEFT JOIN [cer].[PLAN_VALUES_SHOVEL] as [pv]
				ON [s].ShiftId = CONCAT( FORMAT([pv].[FECHA], N'yyMMdd'), CASE WHEN [pv].[TURNO] = 'Dia' THEN '001' ELSE '002' END )
				AND CASE
					WHEN [s].ShovelId in ('CF24', 'CF25', 'CF26') then 'CF' 
					ELSE [s].ShovelId
					END = [pv].[PALA]
	  ) shovel
   ) dest
   GROUP BY shiftid, Shovelid
) x
GROUP BY shiftid, Shovel


