CREATE VIEW [saf].[CONOPS_SAF_SHOVEL_TARGET_V] AS



--select * from [saf].[CONOPS_SAF_SHOVEL_TARGET_V]
CREATE VIEW [saf].[CONOPS_SAF_SHOVEL_TARGET_V]
AS


SELECT shiftid,
       shovel,
       sum(shovelshifttarget) AS shovelshifttarget,
       Destination
FROM (
   SELECT shiftid,
          Shovelid AS shovel,
          cast(sum(tons) AS int) AS shovelshifttarget,
          Destination
   FROM
     (
	  SELECT CAST(Right([Year], 2) + FORMAT(CAST([Month] AS numeric), '00') +
				  FORMAT(CAST([Day] AS numeric), '00') + FORMAT(CAST(SHIFT_CODE AS numeric), '000') AS numeric) [ShiftId],
             CASE
                 WHEN Shovelid Like '%L002%' THEN 'LD002'
                 WHEN Shovelid Like '%L008%' THEN 'LD008'
                 WHEN Shovelid Like '%L013%' THEN 'LD013'
                 WHEN Shovelid Like '%S1%' THEN 'S001'
                 WHEN Shovelid Like '%S2%' THEN 'S002'
                 WHEN Shovelid Like '%S3%' THEN 'S003'
                 WHEN Shovelid Like '%S4%' THEN 'S004'
                 WHEN Shovelid Like '%S5%' THEN 'S005'
                 WHEN Shovelid Like '%S6%' THEN 'S006'
                 WHEN Shovelid Like '%S7%' THEN 'S007'
                 WHEN Shovelid Like '%S8%' THEN 'S008'
             END AS Shovelid,
             CASE
                 WHEN Shovelid Like '%WASTE%' THEN 'Waste'
				 WHEN Shovelid Like '%ORE%' THEN 'CrushLeach'
                 ELSE NULL
             END AS Destination,
             Tons
      FROM (
		 SELECT REVERSE(PARSENAME(REPLACE(REVERSE(DATEEFFECTIVE), '-', '.'), 1)) AS [Year],
				REVERSE(PARSENAME(REPLACE(REVERSE(DATEEFFECTIVE), '-', '.'), 2)) AS [Month],
				REVERSE(PARSENAME(REPLACE(REVERSE(DATEEFFECTIVE), '-', '.'), 3)) AS [Day],
				Shiftindex AS [SHIFT_CODE],
                ShovelId,
                Tons
         FROM [saf].[PLAN_VALUES] unpivot (Tons
                                           FOR ShovelId in (S1ORE, S1WASTE, S1STK, S2ORE, S2WASTE, S2STK, S3ORE, S3WASTE, S3STK, S4ORE, S4WASTE, S4STK, S5ORE, S5WASTE, S5STK, S6ORE, S6WASTE, S6STK, S7ORE, S7WASTE, S7STK, S8ORE, S8WASTE, S8STK,
 L002ORE, L002WASTE, L002STK, L008ORE, L008WASTE, L008STK, L013ORE, L013WASTE, L013STK)
										   ) unpiv
		 ) shovel
   ) dest
   GROUP BY shiftid,
            Shovelid,
            Destination
) x
GROUP BY shiftid,
         Shovel,
         Destination


