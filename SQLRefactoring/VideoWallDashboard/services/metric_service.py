"""
Metric service for fetching and calculating dashboard metrics.
Provides unified interface for all metric data operations.
"""
from dataclasses import dataclass
from datetime import datetime, timedelta
from typing import Dict, List, Optional, Tuple
import logging

from data.connectors import data_service, QueryResult
from data.queries import format_query, get_query
from models.metrics import (
    business_rules,
    MetricDefinition,
    MetricValue,
    LOADING_METRICS,
    HAULAGE_METRICS,
    LBS_ON_GROUND_METRICS,
    ALL_METRICS,
)

logger = logging.getLogger(__name__)


@dataclass
class SiteConfig:
    """Configuration for a specific site."""
    code: str
    name: str
    rolling_minutes: int = 60
    shift_hours: int = 12
    pi_tags: Dict[str, str] = None


# Default site configuration (Morenci)
DEFAULT_SITE = SiteConfig(
    code="MOR",
    name="Morenci",
    rolling_minutes=60,
    shift_hours=12,
    pi_tags={
        "mill_crusher": "MOR-CR03_WI00317_PV",
        "mfl_crusher": "MOR-CR02_WI01203_PV",
        "ios_main": "MOR-CC06_LI00601_PV",
        "ios_small": "MOR-CC10_LI0102_PV",
    }
)


class MetricService:
    """Service for fetching and calculating metrics."""
    
    def __init__(self, site: SiteConfig = None):
        self.site = site or DEFAULT_SITE
        self._cache: Dict[str, Tuple[datetime, any]] = {}
        self._cache_ttl = timedelta(seconds=30)
    
    def _is_cached(self, key: str) -> bool:
        """Check if key is in cache and not expired."""
        if key not in self._cache:
            return False
        cached_time, _ = self._cache[key]
        return datetime.now() - cached_time < self._cache_ttl
    
    def _get_cached(self, key: str) -> Optional[any]:
        """Get cached value if valid."""
        if self._is_cached(key):
            _, value = self._cache[key]
            return value
        return None
    
    def _set_cached(self, key: str, value: any) -> None:
        """Set cache value."""
        self._cache[key] = (datetime.now(), value)
    
    # =========================================================================
    # LOADING SECTION
    # =========================================================================
    
    def get_dig_compliance(self) -> MetricValue:
        """Get dig compliance metric."""
        cache_key = f"dig_compliance_{self.site.code}"
        cached = self._get_cached(cache_key)
        if cached:
            return cached
        
        metric_def = LOADING_METRICS["dig_compliance"]
        
        query = format_query(
            "dig_compliance",
            rolling_minutes=self.site.rolling_minutes,
            site_code=self.site.code,
        )
        
        result = data_service.query(query, "SNOWFLAKE")
        
        if result.data:
            row = result.data[0]
            # Calculate compliance based on events in dig zones
            # For now, use a derived value (actual calculation requires spatial analysis)
            total_events = row.get("TOTAL_DIG_EVENTS", 100)
            active_shovels = row.get("ACTIVE_SHOVELS", 10)
            
            # Mock compliance calculation (real would use bucket coordinates vs dig zones)
            actual = min(95, 75 + (active_shovels * 1.5))
            target = metric_def.target_value or 100
            projected = min(100, actual + 5)
            previous = actual * 0.98  # Mock previous value
            
            value = business_rules.build_metric_value(
                metric_def=metric_def,
                actual=actual,
                target=target,
                projected=projected,
                previous_actual=previous,
                timestamp=result.timestamp,
            )
            
            self._set_cached(cache_key, value)
            return value
        
        return self._get_default_metric(metric_def)
    
    def get_dig_rate(self) -> MetricValue:
        """Get dig rate metric."""
        cache_key = f"dig_rate_{self.site.code}"
        cached = self._get_cached(cache_key)
        if cached:
            return cached
        
        metric_def = LOADING_METRICS["dig_rate"]
        
        query = format_query(
            "dig_rate",
            rolling_minutes=self.site.rolling_minutes,
            site_code=self.site.code,
        )
        
        result = data_service.query(query, "SNOWFLAKE")
        
        if result.data:
            row = result.data[0]
            actual = float(row.get("dig_rate_tph", row.get("TOTAL_TONS", 0)))
            if "TOTAL_TONS" in row:
                # Calculate rate from total tons
                actual = float(row["TOTAL_TONS"]) / (self.site.rolling_minutes / 60)
            
            # Target from 36H plan (mock)
            target = 35000
            projected = actual * 1.1
            previous = actual * 0.95
            
            value = business_rules.build_metric_value(
                metric_def=metric_def,
                actual=actual,
                target=target,
                projected=projected,
                previous_actual=previous,
                timestamp=result.timestamp,
            )
            
            self._set_cached(cache_key, value)
            return value
        
        return self._get_default_metric(metric_def)
    
    def get_priority_shovels(self) -> List[Dict]:
        """Get priority shovels data."""
        cache_key = f"priority_shovels_{self.site.code}"
        cached = self._get_cached(cache_key)
        if cached:
            return cached
        
        query = format_query(
            "priority_shovels",
            rolling_minutes=self.site.rolling_minutes,
            site_code=self.site.code,
        )
        
        result = data_service.query(query, "SNOWFLAKE")
        
        shovels = []
        for row in result.data[:5]:
            shovels.append({
                "id": row.get("shovel_id", row.get("SHOVEL_NAME", "Unknown")),
                "material": row.get("material_type", "Mill"),
                "compliance": 80 + (len(shovels) * 2),  # Mock compliance
                "rate": float(row.get("rate_tph", row.get("TOTAL_TONS", 4100))),
                "trend": "↑" if len(shovels) % 2 == 0 else "↓",
            })
        
        self._set_cached(cache_key, shovels)
        return shovels
    
    # =========================================================================
    # HAULAGE SECTION
    # =========================================================================
    
    def get_cycle_time(self) -> MetricValue:
        """Get cycle time metric."""
        cache_key = f"cycle_time_{self.site.code}"
        cached = self._get_cached(cache_key)
        if cached:
            return cached
        
        metric_def = HAULAGE_METRICS["cycle_time"]
        
        query = format_query(
            "cycle_time",
            rolling_minutes=self.site.rolling_minutes,
            site_code=self.site.code,
        )
        
        result = data_service.query(query, "SNOWFLAKE")
        
        if result.data:
            row = result.data[0]
            actual = float(row.get("avg_cycle_time_mins", row.get("AVG_CYCLE_TIME_MINS", 45)))
            target = 45  # Target from plan
            projected = actual * 0.98
            previous = actual * 1.02
            
            value = business_rules.build_metric_value(
                metric_def=metric_def,
                actual=actual,
                target=target,
                projected=projected,
                previous_actual=previous,
                timestamp=result.timestamp,
            )
            
            self._set_cached(cache_key, value)
            return value
        
        return self._get_default_metric(metric_def)
    
    def get_truck_count(self) -> MetricValue:
        """Get truck count metric."""
        cache_key = f"truck_count_{self.site.code}"
        cached = self._get_cached(cache_key)
        if cached:
            return cached
        
        metric_def = HAULAGE_METRICS["truck_count"]
        
        query = format_query(
            "truck_count",
            rolling_minutes=self.site.rolling_minutes,
            site_code=self.site.code,
        )
        
        result = data_service.query(query, "SNOWFLAKE")
        
        if result.data:
            row = result.data[0]
            actual = float(row.get("active_trucks", row.get("ACTIVE_TRUCKS", 75)))
            target = 76  # Planned truck count
            projected = actual
            previous = actual - 2
            
            value = business_rules.build_metric_value(
                metric_def=metric_def,
                actual=actual,
                target=target,
                projected=projected,
                previous_actual=previous,
                timestamp=result.timestamp,
            )
            
            self._set_cached(cache_key, value)
            return value
        
        return self._get_default_metric(metric_def)
    
    def get_dump_compliance(self) -> MetricValue:
        """Get dump compliance metric."""
        cache_key = f"dump_compliance_{self.site.code}"
        cached = self._get_cached(cache_key)
        if cached:
            return cached
        
        metric_def = HAULAGE_METRICS["dump_compliance"]
        
        query = format_query(
            "dump_compliance",
            rolling_minutes=self.site.rolling_minutes,
            site_code=self.site.code,
        )
        
        result = data_service.query(query, "SNOWFLAKE")
        
        # Calculate compliance from dump locations
        # Real calculation would compare actual vs planned dump locations
        actual = 88  # Mock value
        target = 100
        projected = 92
        previous = 86
        
        value = business_rules.build_metric_value(
            metric_def=metric_def,
            actual=actual,
            target=target,
            projected=projected,
            previous_actual=previous,
            timestamp=datetime.now(),
        )
        
        self._set_cached(cache_key, value)
        return value
    
    def get_asset_efficiency(self) -> MetricValue:
        """Get asset efficiency metric."""
        cache_key = f"asset_efficiency_{self.site.code}"
        cached = self._get_cached(cache_key)
        if cached:
            return cached
        
        metric_def = HAULAGE_METRICS["asset_efficiency"]
        
        query = format_query(
            "asset_efficiency",
            rolling_minutes=self.site.rolling_minutes,
            site_code=self.site.code,
        )
        
        result = data_service.query(query, "SNOWFLAKE")
        
        if result.data:
            row = result.data[0]
            cycles_per_truck = float(row.get("cycles_per_truck", row.get("CYCLES_PER_TRUCK", 10)))
            expected_cycles = 12  # Expected cycles per truck per shift portion
            actual = min(100, (cycles_per_truck / expected_cycles) * 100)
            target = 100
            projected = actual * 1.02
            previous = actual * 0.97
            
            value = business_rules.build_metric_value(
                metric_def=metric_def,
                actual=actual,
                target=target,
                projected=projected,
                previous_actual=previous,
                timestamp=result.timestamp,
            )
            
            self._set_cached(cache_key, value)
            return value
        
        return self._get_default_metric(metric_def)
    
    # =========================================================================
    # LBS ON GROUND SECTION
    # =========================================================================
    
    def get_mill_crusher_rate(self) -> MetricValue:
        """Get mill crusher rate from ADX."""
        cache_key = f"mill_crusher_{self.site.code}"
        cached = self._get_cached(cache_key)
        if cached:
            return cached
        
        metric_def = LBS_ON_GROUND_METRICS["mill_crusher"]
        pi_tag = self.site.pi_tags.get("mill_crusher", "MOR-CR03_WI00317_PV")
        
        query = format_query("mill_crusher", pi_tag=pi_tag)
        
        result = data_service.query(query, "ADX")
        
        if result.data:
            row = result.data[0]
            actual = float(row.get("rate_tph", row.get("value", 8500)))
            target = 4350  # Plan value
            projected = actual * 0.98
            previous = actual * 1.01
            
            value = business_rules.build_metric_value(
                metric_def=metric_def,
                actual=actual,
                target=target,
                projected=projected,
                previous_actual=previous,
                timestamp=result.timestamp,
            )
            
            self._set_cached(cache_key, value)
            return value
        
        return self._get_default_metric(metric_def)
    
    def get_material_delivered(self, material_type: str) -> Dict:
        """Get material delivered for a specific type (mill, mfl, rom)."""
        cache_key = f"material_{material_type}_{self.site.code}"
        cached = self._get_cached(cache_key)
        if cached:
            return cached
        
        query_name = f"{material_type}_tons"
        
        query = format_query(
            query_name,
            shift_hours=self.site.shift_hours,
            site_code=self.site.code,
        )
        
        result = data_service.query(query, "SNOWFLAKE")
        
        total_tons = 0
        for row in result.data:
            total_tons += float(row.get("total_tons", row.get("TOTAL_TONS", 0)))
        
        # Targets vary by material type
        targets = {"mill": 108000, "mfl": 60000, "rom": 250000}
        target = targets.get(material_type, 100000)
        
        data = {
            "actual": total_tons,
            "target": target,
            "projected": total_tons * 1.15,
            "trend": 6.12,  # Mock trend
            "status": "green" if total_tons / target >= 0.9 else "orange",
        }
        
        self._set_cached(cache_key, data)
        return data
    
    def get_ios_strategy(self) -> List[Dict]:
        """Get IOS strategy stockpile data."""
        cache_key = f"ios_strategy_{self.site.code}"
        cached = self._get_cached(cache_key)
        if cached:
            return cached
        
        pi_tag_main = self.site.pi_tags.get("ios_main", "MOR-CC06_LI00601_PV")
        pi_tag_small = self.site.pi_tags.get("ios_small", "MOR-CC10_LI0102_PV")
        
        query = format_query(
            "ios_level",
            pi_tag_main=pi_tag_main,
            pi_tag_small=pi_tag_small,
        )
        
        result = data_service.query(query, "ADX")
        
        # Build stockpile grid (6 indicators as per requirements)
        stockpiles = []
        base_rate = 100
        
        for i in range(6):
            direction = "up" if i % 3 != 2 else "down"
            hours = [12, 12, 12, 6, 6, 6][i]
            rate = [300, 300, 300, 50, 50, 50][i]
            
            stockpiles.append({
                "rate": rate,
                "capacity_hours": hours,
                "direction": direction,
                "level_pct": 50 + (i * 8),
            })
        
        self._set_cached(cache_key, stockpiles)
        return stockpiles
    
    # =========================================================================
    # HELPERS
    # =========================================================================
    
    def _get_default_metric(self, metric_def: MetricDefinition) -> MetricValue:
        """Get default metric value when data is unavailable."""
        return business_rules.build_metric_value(
            metric_def=metric_def,
            actual=0,
            target=metric_def.target_value or 100,
            projected=0,
            previous_actual=0,
            timestamp=datetime.now(),
        )
    
    def get_all_loading_metrics(self) -> Dict:
        """Get all loading section metrics."""
        return {
            "dig_compliance": self.get_dig_compliance(),
            "dig_rate": self.get_dig_rate(),
            "priority_shovels": self.get_priority_shovels(),
        }
    
    def get_all_haulage_metrics(self) -> Dict:
        """Get all haulage section metrics."""
        return {
            "cycle_time": self.get_cycle_time(),
            "truck_count": self.get_truck_count(),
            "dump_compliance": self.get_dump_compliance(),
            "asset_efficiency": self.get_asset_efficiency(),
        }
    
    def get_all_lbs_on_ground_metrics(self) -> Dict:
        """Get all lbs on ground section metrics."""
        return {
            "mill_crusher": self.get_mill_crusher_rate(),
            "mill_tons": self.get_material_delivered("mill"),
            "mfl_tons": self.get_material_delivered("mfl"),
            "rom_tons": self.get_material_delivered("rom"),
            "ios_stockpiles": self.get_ios_strategy(),
        }


# Singleton instance
metric_service = MetricService()
