"""
Configuration settings for the Video Wall Dashboard.
Central location for all environment and application settings.
"""
from dataclasses import dataclass, field
from typing import Dict, List, Optional
from enum import Enum


class DataSource(Enum):
    """Available data sources."""
    SNOWFLAKE = "snowflake"
    ADX = "adx"


class ColorThreshold(Enum):
    """Standard color coding thresholds."""
    GREEN = 90  # >= 90%
    ORANGE = 80  # >= 80% and < 90%
    RED = 0     # < 80%


@dataclass
class SnowflakeConfig:
    """Snowflake connection configuration."""
    account: str = "FCX-NA"
    warehouse: str = "WH_BATCH_DE_NONPROD"
    database: str = "PROD_WG"
    schema: str = "LOAD_HAUL"
    authentication: str = "externalbrowser"
    
    @property
    def tables(self) -> List[str]:
        return ["LH_LOADING_CYCLE", "LH_HAUL_CYCLE", "LH_EQUIPMENT"]


@dataclass
class ADXConfig:
    """Azure Data Explorer configuration."""
    cluster: str = "https://fctsnaproddatexp02.westus2.kusto.windows.net"
    authentication: str = "InteractiveBrowserCredential"
    
    @property
    def databases(self) -> List[str]:
        return ["Morenci", "Bagdad", "Miami", "Climax", "Sierrita", "NewMexico", "CerroVerde"]
    
    @property
    def functions(self) -> List[str]:
        return ["FCTSCURRENT()", "FCTS()"]


@dataclass
class SiteConfig:
    """Individual site configuration."""
    code: str
    name: str
    adx_database: str
    location: str
    site_type: str
    has_load_haul_data: bool = True
    pi_tags: Dict[str, str] = field(default_factory=dict)


@dataclass
class DisplayConfig:
    """Dashboard display configuration per requirements."""
    rolling_window_minutes: int = 60
    shift_hours: int = 12
    refresh_interval_seconds: int = 30
    
    # Color thresholds (percentage)
    green_threshold: float = 90.0
    orange_threshold: float = 80.0
    
    # Trend thresholds
    trend_increase_threshold: float = 0.0
    trend_decrease_orange: float = -10.0  # Orange: Decrease < 10%
    trend_decrease_red: float = -10.0     # Red: Decrease > 10%


# Site configurations
SITES: Dict[str, SiteConfig] = {
    "MOR": SiteConfig(
        code="MOR",
        name="Morenci",
        adx_database="Morenci",
        location="Arizona, USA",
        site_type="Open Pit Copper",
        pi_tags={
            "mill_crusher": "MOR-CR03_WI00317_PV",
            "mfl_crusher": "MOR-CR02_WI01203_PV",
            "ios_main": "MOR-CC06_LI00601_PV",
            "ios_small": "MOR-CC10_LI0102_PV"
        }
    ),
    "BAG": SiteConfig(
        code="BAG",
        name="Bagdad",
        adx_database="Bagdad",
        location="Arizona, USA",
        site_type="Open Pit Copper",
        pi_tags={
            "crusher": "BAG-GL4CrusherMotorMotorLoad",
            "level": "BAG-MD_BAG_CC_Crusher2_TonsPerHourTarget"
        }
    ),
    "SAM": SiteConfig(
        code="SAM",
        name="Miami",
        adx_database="Miami",
        location="Arizona, USA",
        site_type="Underground/Processing"
    ),
    "CMX": SiteConfig(
        code="CMX",
        name="Climax",
        adx_database="Climax",
        location="Colorado, USA",
        site_type="Molybdenum Mine"
    ),
    "SIE": SiteConfig(
        code="SIE",
        name="Sierrita",
        adx_database="Sierrita",
        location="Arizona, USA",
        site_type="Open Pit Copper"
    ),
    "NMO": SiteConfig(
        code="NMO",
        name="NewMexico",
        adx_database="NewMexico",
        location="New Mexico, USA",
        site_type="Open Pit Copper"
    ),
    "CVE": SiteConfig(
        code="CVE",
        name="CerroVerde",
        adx_database="CerroVerde",
        location="Arequipa, Peru",
        site_type="Open Pit Copper"
    )
}


# Application settings
APP_CONFIG = {
    "title": "IROC Video Wall - Production Performance",
    "page_icon": "⛏️",
    "layout": "wide",
    "initial_sidebar_state": "collapsed"
}
