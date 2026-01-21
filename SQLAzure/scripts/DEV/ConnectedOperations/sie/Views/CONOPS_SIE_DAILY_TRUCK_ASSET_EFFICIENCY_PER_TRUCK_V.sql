CREATE VIEW [sie].[CONOPS_SIE_DAILY_TRUCK_ASSET_EFFICIENCY_PER_TRUCK_V] AS
  
--select * from [sie].[CONOPS_SIE_DAILY_TRUCK_ASSET_EFFICIENCY_PER_TRUCK_V] WITH (NOLOCK)  
CREATE VIEW [sie].[CONOPS_SIE_DAILY_TRUCK_ASSET_EFFICIENCY_PER_TRUCK_V]   
AS  
  
SELECT [shift].shiftflag,  
    [shift].[siteflag],  
    [shift].[shiftid],  
    eqmt,  
    availability_pct,  
    use_of_availability_pct,  
    Ops_efficient_pct  
FROM [sie].[CONOPS_SIE_EOS_SHIFT_INFO_V] [shift] WITH (NOLOCK)  
LEFT JOIN (  
 select shiftid,eqmt  
 , ((ready_time + ready_nonprod_time +delay_time + spare_time) / alltime) * 100 as availability_pct  
 , ((ready_time + ready_nonprod_time + delay_time ) / alltime) * 100 as use_of_availability_pct  
 , ((ready_time + ready_nonprod_time) / alltime) * 100 as Ops_efficient_pct  
 from  
 (  
  select shiftid,eqmt,unittype,   
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
  from [sie].[asset_efficiency] WITH (NOLOCK)  
  group by shiftid,eqmt,unittype  
 ) calc  
 where unittype = 'truck'  
) [ta]  
ON [ta].shiftid = [shift].shiftid  
     
  
  
