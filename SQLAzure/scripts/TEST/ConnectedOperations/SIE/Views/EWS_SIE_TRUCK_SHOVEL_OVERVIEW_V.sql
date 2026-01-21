CREATE VIEW [SIE].[EWS_SIE_TRUCK_SHOVEL_OVERVIEW_V] AS



CREATE VIEW [sie].[EWS_SIE_TRUCK_SHOVEL_OVERVIEW_V] 
AS


WITH TPHPayload AS (

SELECT 
'truck' as equip_row,
siteflag,
shiftflag,
ROUND(sum(tph),0) tons_hr_avg_payload
FROM [sie].[CONOPS_SIE_TP_TONS_HAUL_V]  WITH (NOLOCK)
group by siteflag,shiftflag

UNION ALL

SELECT 
'shovel' as equip_row,
[siteflag]
,[shiftflag]
,ROUND([AVG_Payload],0) as tons_hr_avg_payload
FROM [sie].[CONOPS_SIE_OVERALL_AVG_PAYLOAD_V] WITH (NOLOCK)),

EquipStatus AS (
SELECT
'truck' as equip_row,
siteflag,
shiftflag,
[Delay],
[Down],
[Ready],
[Spare]
FROM (
SELECT 
[siteflag],
[shiftflag],
[eqmtcurrstatus],
count(distinct([eqmt])) countEquip
FROM [sie].[CONOPS_SIE_TP_EQMT_STATUS_V] WITH (NOLOCK)
group by [siteflag],[shiftflag],[eqmtcurrstatus]
) d
PIVOT  
(  
MAX(countEquip)
FOR [eqmtcurrstatus] IN  
( [Delay], [Down], [Ready], [Spare] )  
) AS pvt  

UNION ALL

SELECT
'shovel' as equip_row,
siteflag,
shiftflag,
[Delay],
[Down],
[Ready],
[Spare]
FROM (
SELECT 
[siteflag],
[shiftflag],
[eqmtcurrstatus],
count(distinct([eqmt])) countEquip
FROM [sie].[CONOPS_SIE_SP_EQMT_STATUS_V] WITH (NOLOCK)
group by [siteflag],[shiftflag],[eqmtcurrstatus]
) d
PIVOT  
(  
MAX(countEquip)
FOR [eqmtcurrstatus] IN  
( [Delay], [Down], [Ready], [Spare] )  
) AS pvt  ),

AE AS (
SELECT
'truck' as equip_row,
[shiftflag]
,[siteflag]
,ROUND([efficiency],0) AS efficiency
,ROUND([availability],0) AS [availability]
,ROUND([use_of_availability],0) AS use_of_availability
FROM [sie].[CONOPS_SIE_TRUCK_ASSET_EFFICIENCY_V] WITH (NOLOCK)

UNION ALL

SELECT
'shovel' as equip_row,
[shiftflag]
,[siteflag]
,ROUND([efficiency],0) AS efficiency
,ROUND([availability],0) AS [availability]
,ROUND([use_of_availability],0) AS use_of_availability
FROM [sie].[CONOPS_SIE_SHOVEL_ASSET_EFFICIENCY_V] WITH (NOLOCK))

SELECT 
UPPER(C.equip_row) AS Equipment,
A.shiftflag,
A.siteflag,
A.tons_hr_avg_payload AS TPHPayload,
B.[Delay],
B.[Down],
B.[Ready],
B.[Spare],
C.[efficiency],
C.[availability],
C.[use_of_availability] AS UseOfAvailability
FROM TPHPayload a
LEFT JOIN EquipStatus b 
ON A.siteflag = B.siteflag
AND A.shiftflag = B.shiftflag
AND A.equip_row = B.equip_row
LEFT JOIN AE c
ON A.siteflag = C.siteflag
AND A.shiftflag = C.shiftflag
AND A.equip_row = C.equip_row

