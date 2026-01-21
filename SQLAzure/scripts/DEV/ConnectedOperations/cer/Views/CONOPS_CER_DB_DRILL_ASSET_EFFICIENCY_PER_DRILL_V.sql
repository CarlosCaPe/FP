CREATE VIEW [cer].[CONOPS_CER_DB_DRILL_ASSET_EFFICIENCY_PER_DRILL_V] AS



--select * from [cer].[CONOPS_CER_DB_DRILL_ASSET_EFFICIENCY_PER_DRILL_V]
CREATE VIEW [cer].[CONOPS_CER_DB_DRILL_ASSET_EFFICIENCY_PER_DRILL_V]
AS

	WITH AE AS (
		SELECT shiftid,
			   eqmt,
			   availability_pct AS Avail,
			   use_of_availability_pct,
			   Ops_efficient_pct AS AE
		FROM (
			select shiftid,eqmt
			, ((ready_time + ready_nonprod_time +delay_time + spare_time) / alltime) * 100 as availability_pct
			, ((ready_time + ready_nonprod_time + delay_time ) / alltime) * 100 as use_of_availability_pct
			, ((ready_time + ready_nonprod_time) / alltime) * 100 as Ops_efficient_pct
			from
			(
				select shiftid,unittype, eqmt,
				sum( case when categoryidx = 1 then duration else  0 end ) /3600.0000 as ready_time,
				sum( case when categoryidx = 2 then duration else  0 end ) /3600.0000 as ready_nonprod_time, --Ready Non-Production
				sum( case when categoryidx = 3 then duration else  0 end ) /3600.0000 as oper_down_time, --Operational Down
				sum( case when categoryidx = 4 then duration else  0 end ) /3600.0000 as planned_down_time, --Unscheduled Down
				sum( case when categoryidx = 5 then duration else  0 end ) /3600.0000 as unplanned_down_time, --Unscheduled Down
				sum( case when categoryidx = 6 then duration else  0 end ) /3600.0000 as delay_time, --Operational Delay
				sum( case when categoryidx = 7 then duration else  0 end ) /3600.0000 as spare_time,
				sum( case when categoryidx = 8 then duration else  0 end ) /3600.0000 as non_guarantee_time, --Non Guarantee
				sum( case when categoryidx = 9 then duration else  0 end ) /3600.0000 as shiftchange_time,
				sum(duration)/3600.0000 as alltime
				from [cer].[asset_efficiency] WITH (NOLOCK)
				group by shiftid,unittype, eqmt
			) calc
			where unittype = 'Drill'
		) [ta]
	)

	SELECT [shift].shiftflag,
		   [shift].[siteflag],
		   [shift].ShiftIndex,
		   [shift].shiftid,
		   [shift].ShiftStartDateTime,
		   eqmt AS Equipment,
		   AE,
		   Avail,
		   CASE WHEN [Avail] = 0
				THEN 0
				ELSE ROUND(([AE]/[Avail]) * 100, 0)
		   END AS [UofA],
		   [t].DRILLASSETEFFICIENCY [AETarget],
		   [t].DRILLAVAILABILITY [AvailTarget],
		   [t].DRILLUTILIZATION [UofATarget]
	FROM [cer].[CONOPS_CER_SHIFT_INFO_V] [shift] WITH (NOLOCK)
	LEFT JOIN AE
	on AE.shiftid = [shift].SHIFTID
	LEFT JOIN [cer].[CONOPS_CER_DB_DRILL_ASSET_EFFICIENCY_TARGET_V] [t]
	ON LEFT([shift].shiftid, 4) = [t].ShiftId
	WHERE AE.eqmt IS NOT NULL


