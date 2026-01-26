"""
Business rules and metric definitions for the Video Wall Dashboard.
Implements the standards from the IROC requirements document.
"""
from dataclasses import dataclass, field
from typing import Dict, List, Optional, Tuple
from enum import Enum
from datetime import datetime, timedelta


class Section(Enum):
    """Dashboard sections."""
    LOADING = "Loading"
    HAULAGE = "Haulage"
    LBS_ON_GROUND = "Lbs on Ground"
    PROCESSING = "Processing"


class MetricStatus(Enum):
    """Metric status based on thresholds."""
    GREEN = "green"
    ORANGE = "orange"
    RED = "red"
    UNKNOWN = "unknown"


class TrendDirection(Enum):
    """Trend direction indicators."""
    UP = "↑"
    DOWN = "↓"
    STABLE = "→"


@dataclass
class Thresholds:
    """Color coding thresholds per requirements."""
    green_min: float = 90.0   # >= 90%
    orange_min: float = 80.0  # >= 80% and < 90%
    # Red is < 80%
    
    def get_status(self, ratio: float) -> MetricStatus:
        """Determine status based on actual/target ratio percentage."""
        if ratio >= self.green_min:
            return MetricStatus.GREEN
        elif ratio >= self.orange_min:
            return MetricStatus.ORANGE
        else:
            return MetricStatus.RED


@dataclass
class TrendThresholds:
    """Trend color coding thresholds."""
    decrease_orange: float = -10.0  # Decrease < 10%
    
    def get_status(self, change_pct: float) -> MetricStatus:
        """Determine trend status based on change percentage."""
        if change_pct >= 0:
            return MetricStatus.GREEN
        elif change_pct >= self.decrease_orange:
            return MetricStatus.ORANGE
        else:
            return MetricStatus.RED
    
    def get_direction(self, current: float, previous: float) -> TrendDirection:
        """Determine trend direction."""
        if current > previous:
            return TrendDirection.UP
        elif current < previous:
            return TrendDirection.DOWN
        return TrendDirection.STABLE


@dataclass
class MetricValue:
    """Represents a calculated metric value with all display components."""
    actual: float
    target: float
    projected: float
    trend_value: float
    trend_direction: TrendDirection
    actual_status: MetricStatus
    projected_status: MetricStatus
    trend_status: MetricStatus
    timestamp: datetime
    unit: str = ""
    
    @property
    def actual_ratio(self) -> float:
        """Ratio of actual to target as percentage."""
        if self.target == 0:
            return 0.0
        return (self.actual / self.target) * 100
    
    @property
    def formatted_trend(self) -> str:
        """Format trend with sign as required."""
        sign = "+" if self.trend_value >= 0 else ""
        return f"{sign}{self.trend_value:.2f}%"


@dataclass
class MetricDefinition:
    """Definition of a metric per requirements document."""
    id: str
    label: str
    section: Section
    description: str
    unit: str
    min_value: float
    max_value: float
    target_value: Optional[float] = None
    time_window_minutes: int = 60
    source: str = "SNOWFLAKE"
    
    # Query information
    table: Optional[str] = None
    columns: List[str] = field(default_factory=list)
    pi_tag: Optional[str] = None


# =============================================================================
# METRIC DEFINITIONS - Per Requirements Document
# =============================================================================

LOADING_METRICS = {
    "dig_compliance": MetricDefinition(
        id="01",
        label="Dig Compliance (%)",
        section=Section.LOADING,
        description="Spatial compliance of shovel dig points relative to defined dig zones",
        unit="%",
        min_value=0,
        max_value=100,
        target_value=100,
        source="SNOWFLAKE",
        table="PROD_WG.LOAD_HAUL.LH_LOADING_CYCLE",
    ),
    "dig_rate": MetricDefinition(
        id="02",
        label="Dig Rate (TPRH)",
        section=Section.LOADING,
        description="Total amount of material loaded by entire shovel fleet each hour",
        unit="TPH",
        min_value=0,
        max_value=99000,
        source="SNOWFLAKE",
        table="PROD_WG.LOAD_HAUL.LH_LOADING_CYCLE",
        columns=["MEASURED_PAYLOAD_METRIC_TONS"],
    ),
    "priority_shovels": MetricDefinition(
        id="03",
        label="Priority Shovels",
        section=Section.LOADING,
        description="Top 5 priority shovels with dig compliance and dig rate",
        unit="tons",
        min_value=0,
        max_value=10000,
        source="SNOWFLAKE",
        table="PROD_WG.LOAD_HAUL.LH_LOADING_CYCLE",
    ),
}

HAULAGE_METRICS = {
    "truck_count": MetricDefinition(
        id="04",
        label="# of Trucks (Qty)",
        section=Section.HAULAGE,
        description="Number of mechanically available trucks",
        unit="count",
        min_value=20,
        max_value=150,
        source="SNOWFLAKE",
        table="PROD_WG.LOAD_HAUL.LH_HAUL_CYCLE",
    ),
    "cycle_time": MetricDefinition(
        id="05",
        label="Cycle Time (min)",
        section=Section.HAULAGE,
        description="Average round trip time across entire truck fleet",
        unit="min",
        min_value=35,
        max_value=45,
        source="SNOWFLAKE",
        table="PROD_WG.LOAD_HAUL.LH_HAUL_CYCLE",
        columns=["TOTAL_CYCLE_DURATION_CALENDAR_MINS"],
    ),
    "asset_efficiency": MetricDefinition(
        id="06",
        label="Asset Efficiency (%)",
        section=Section.HAULAGE,
        description="Truck utilization measured by cycles per truck",
        unit="%",
        min_value=0,
        max_value=100,
        source="SNOWFLAKE",
        table="PROD_WG.LOAD_HAUL.LH_HAUL_CYCLE",
    ),
    "dump_compliance": MetricDefinition(
        id="07",
        label="Dump Plan Compliance (%)",
        section=Section.HAULAGE,
        description="Proportion of material dumped at designated location",
        unit="%",
        min_value=0,
        max_value=100,
        target_value=100,
        source="SNOWFLAKE",
        table="PROD_WG.LOAD_HAUL.LH_HAUL_CYCLE",
        columns=["DUMP_LOC_NAME", "REPORT_PAYLOAD_SHORT_TONS"],
    ),
}

LBS_ON_GROUND_METRICS = {
    "mill_tons": MetricDefinition(
        id="08",
        label="Mill Material Delivered (tons)",
        section=Section.LBS_ON_GROUND,
        description="Total tons of material dumped at Mill location",
        unit="tons",
        min_value=0,
        max_value=200000,
        time_window_minutes=720,  # 12 hours
        source="SNOWFLAKE",
        table="PROD_WG.LOAD_HAUL.LH_HAUL_CYCLE",
    ),
    "mill_crusher": MetricDefinition(
        id="09",
        label="Mill Crusher (TPOH)",
        section=Section.LBS_ON_GROUND,
        description="Mill crusher throughput rate",
        unit="TPH",
        min_value=0,
        max_value=9000,
        source="ADX",
        pi_tag="MOR-CR03_WI00317_PV",
    ),
    "mill_rate": MetricDefinition(
        id="10",
        label="Mill Feed (TPOH)",
        section=Section.LBS_ON_GROUND,
        description="Mill feed throughput rate",
        unit="TPH",
        min_value=7000,
        max_value=9000,
        source="ADX",
        pi_tag="MOR-CR03_WI00317_PV",
    ),
    "mill_ios": MetricDefinition(
        id="11",
        label="Mill IOS Level",
        section=Section.LBS_ON_GROUND,
        description="In-Ore Stockpile level and direction - HIGHEST PRIORITY",
        unit="%",
        min_value=0,
        max_value=100,
        source="ADX",
        pi_tag="MOR-CC06_LI00601_PV",
    ),
    "mfl_tons": MetricDefinition(
        id="12",
        label="MFL Material Delivered (tons)",
        section=Section.LBS_ON_GROUND,
        description="Total tons of material dumped at MFL location",
        unit="tons",
        min_value=0,
        max_value=100000,
        time_window_minutes=720,
        source="SNOWFLAKE",
        table="PROD_WG.LOAD_HAUL.LH_HAUL_CYCLE",
    ),
    "mfl_crusher": MetricDefinition(
        id="13",
        label="MFL Crusher (TPOH)",
        section=Section.LBS_ON_GROUND,
        description="MFL crusher throughput rate",
        unit="TPH",
        min_value=0,
        max_value=5000,
        source="ADX",
        pi_tag="MOR-CR02_WI01203_PV",
    ),
    "mfl_fos": MetricDefinition(
        id="14",
        label="FCP (TPOH)",
        section=Section.LBS_ON_GROUND,
        description="FCP/FOS rate at MFL operations",
        unit="TPH",
        min_value=4000,
        max_value=5000,
        source="ADX",
    ),
    "mfl_ios": MetricDefinition(
        id="15",
        label="MFL IOS Level",
        section=Section.LBS_ON_GROUND,
        description="MFL stockpile level and operational compliance",
        unit="%",
        min_value=0,
        max_value=100,
        source="ADX",
    ),
    "rom_tons": MetricDefinition(
        id="16",
        label="ROM Material Delivered (tons)",
        section=Section.LBS_ON_GROUND,
        description="Total tons of material dumped at ROM location",
        unit="tons",
        min_value=0,
        max_value=400000,
        time_window_minutes=720,
        source="SNOWFLAKE",
        table="PROD_WG.LOAD_HAUL.LH_HAUL_CYCLE",
    ),
}

# Combine all metrics
ALL_METRICS = {
    **LOADING_METRICS,
    **HAULAGE_METRICS,
    **LBS_ON_GROUND_METRICS,
}


class BusinessRuleEngine:
    """Applies business rules to calculate metric values."""
    
    def __init__(self):
        self.thresholds = Thresholds()
        self.trend_thresholds = TrendThresholds()
    
    def calculate_actual_status(self, actual: float, target: float) -> MetricStatus:
        """Calculate status based on actual vs target ratio."""
        if target == 0:
            return MetricStatus.UNKNOWN
        ratio = (actual / target) * 100
        return self.thresholds.get_status(ratio)
    
    def calculate_projected_status(self, projected: float, shift_target: float) -> MetricStatus:
        """Calculate status based on projected vs shift target ratio."""
        if shift_target == 0:
            return MetricStatus.UNKNOWN
        ratio = (projected / shift_target) * 100
        return self.thresholds.get_status(ratio)
    
    def calculate_trend(
        self, 
        current: float, 
        previous: float
    ) -> Tuple[float, TrendDirection, MetricStatus]:
        """Calculate trend value, direction, and status."""
        if previous == 0:
            return 0.0, TrendDirection.STABLE, MetricStatus.UNKNOWN
        
        change_pct = ((current - previous) / previous) * 100
        direction = self.trend_thresholds.get_direction(current, previous)
        status = self.trend_thresholds.get_status(change_pct)
        
        return change_pct, direction, status
    
    def build_metric_value(
        self,
        metric_def: MetricDefinition,
        actual: float,
        target: float,
        projected: float,
        previous_actual: float,
        timestamp: datetime
    ) -> MetricValue:
        """Build complete MetricValue with all calculations."""
        trend_value, trend_direction, trend_status = self.calculate_trend(
            actual, previous_actual
        )
        
        return MetricValue(
            actual=actual,
            target=target,
            projected=projected,
            trend_value=trend_value,
            trend_direction=trend_direction,
            actual_status=self.calculate_actual_status(actual, target),
            projected_status=self.calculate_projected_status(projected, target),
            trend_status=trend_status,
            timestamp=timestamp,
            unit=metric_def.unit,
        )


# Singleton instance
business_rules = BusinessRuleEngine()
