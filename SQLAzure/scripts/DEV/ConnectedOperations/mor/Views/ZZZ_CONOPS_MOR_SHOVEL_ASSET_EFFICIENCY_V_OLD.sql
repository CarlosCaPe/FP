CREATE VIEW [mor].[ZZZ_CONOPS_MOR_SHOVEL_ASSET_EFFICIENCY_V_OLD] AS





--select * from [mor].[CONOPS_MOR_SHOVEL_ASSET_EFFICIENCY_V] WITH (NOLOCK)
CREATE VIEW [mor].[CONOPS_MOR_SHOVEL_ASSET_EFFICIENCY_V_OLD]
AS


select shiftid,unittype
, ((ready_time + ready_nonprod_time +delay_time + spare_time + shiftchange_time) / alltime) * 100 as availability_pct
, ((ready_time + ready_nonprod_time + delay_time ) / alltime) * 100 as use_of_availability_pct
, ((ready_time + ready_nonprod_time) / alltime) * 100 as Ops_efficient_pct
from
(
	select shiftid,unittype,
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
	from [mor].[asset_efficiency] WITH (NOLOCK)
	group by shiftid,unittype
) calc
where unittype = 'shovel'
--order by shiftid,unittype

