CREATE VIEW [chi].[CONOPS_CHI_SHOVEL_TARGET_V] AS





--select * from [chi].[CONOPS_CHI_SHOVEL_TARGET_V]
CREATE VIEW [chi].[CONOPS_CHI_SHOVEL_TARGET_V]
AS


SELECT a.shiftid,
       shovel,
       sum(shovelshifttarget)/2.0 AS shovelshifttarget,
	   (sum(shovelshifttarget)/2.0) * ((a.ShiftDuration / 3600.00) / 12) AS shoveltarget
FROM [chi].[CONOPS_CHI_SHIFT_INFO_V] a
LEFT JOIN 
  (
   SELECT shiftid,
          Shovelid AS shovel,
          cast(sum(tons) AS int) AS shovelshifttarget
   FROM (
	  SELECT Right([Year], 2) + FORMAT(CAST([Month] AS numeric), '00') [ShiftId],
  			 DATEEFFECTIVE,
			 --siteflag,
			 SUBSTRING(ShovelId, 3, 2) ShovelId,
			 Tons
	  FROM (
		 SELECT DATEEFFECTIVE,
				REVERSE(PARSENAME(REPLACE(REVERSE(DATEEFFECTIVE), '-', '.'), 1)) AS [Year],
				REVERSE(PARSENAME(REPLACE(REVERSE(DATEEFFECTIVE), '-', '.'), 2)) AS [Month],
				--'CHI' AS siteflag,
				ShovelId,
				Tons
		 FROM [chi].[PLAN_VALUES] WITH (NOLOCK) unpivot (Tons
			FOR ShovelId in ([C_35TPD], [C_12TPD], [C_44TPD], [C_46TPD])
			) unpiv
		 INNER JOIN (
			SELECT MAX(DATEEFFECTIVE) MaxDateEffective
			FROM [chi].[PLAN_VALUES] WITH (NOLOCK)
			WHERE GETDATE() >= DateEffective 
		 ) [maxdate] ON unpiv.DateEffective = [maxdate].MaxDateEffective
	  ) [a]
   ) dest
   GROUP BY shiftid,
            Shovelid
) x
ON LEFT(a.shiftid, 4) >= x.shiftid
GROUP BY 
a.shiftid,
Shovel,
SHIFTDURATION




