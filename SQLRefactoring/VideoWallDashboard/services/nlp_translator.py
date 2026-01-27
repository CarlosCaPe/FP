"""
🧠 NLP Query Translator
========================
Translates natural language to KQL/SQL queries using the semantic model.
Supports English and Spanish keywords.

This module is the "brain" of the intelligent dashboard chat.
"""

from dataclasses import dataclass
from typing import Dict, Any, List, Optional, Tuple
from pathlib import Path
import yaml
import re


@dataclass
class QueryResult:
    """Result of query translation."""
    success: bool
    source: str  # ADX, SNOWFLAKE, HELP
    database: str
    query: str
    explanation: str
    metric_type: str
    site_code: str
    confidence: float  # 0.0 to 1.0


# =============================================================================
# KEYWORD MAPPINGS (English + Spanish)
# =============================================================================
KEYWORD_MAPPINGS = {
    'ios_level': {
        'keywords': ['ios', 'stockpile', 'level', 'inventory', 'silo', 'nivel', 'inventario', 'pila'],
        'source': 'ADX',
        'description_en': 'IOS Level (In-Ore Stockpile)',
        'description_es': 'Nivel IOS (Stockpile de Mineral)',
    },
    'crusher_rate': {
        'keywords': ['crusher', 'crushing', 'triturador', 'trituradora', 'chancadora', 'chancado'],
        'source': 'ADX',
        'description_en': 'Crusher Rate (TPH)',
        'description_es': 'Tasa de Chancado (TPH)',
    },
    'dig_rate': {
        'keywords': ['dig', 'loading', 'shovel', 'excavator', 'pala', 'carga', 'excavadora', 'carguío'],
        'source': 'SNOWFLAKE',
        'description_en': 'Dig Rate (TPOH)',
        'description_es': 'Tasa de Excavación (TPOH)',
    },
    'truck_count': {
        'keywords': ['truck', 'haul', 'fleet', 'camion', 'camión', 'acarreo', 'flota', 'trucks'],
        'source': 'SNOWFLAKE',
        'description_en': 'Truck Fleet Status',
        'description_es': 'Estado de Flota de Camiones',
    },
    'cycle_time': {
        'keywords': ['cycle', 'time', 'tiempo', 'ciclo', 'duracion', 'duración'],
        'source': 'SNOWFLAKE',
        'description_en': 'Cycle Time (minutes)',
        'description_es': 'Tiempo de Ciclo (minutos)',
    },
    'mill_rate': {
        'keywords': ['mill', 'molino', 'ball', 'sag', 'molienda', 'grinding'],
        'source': 'ADX',
        'description_en': 'Mill Rate (TPH)',
        'description_es': 'Tasa de Molienda (TPH)',
    },
    'priority_shovels': {
        'keywords': ['priority', 'top', 'best', 'ranking', 'mejores', 'principales', 'líderes'],
        'source': 'SNOWFLAKE',
        'description_en': 'Top Producing Shovels',
        'description_es': 'Palas de Mayor Producción',
    },
    'tons_delivered': {
        'keywords': ['tons', 'delivered', 'dump', 'toneladas', 'entregado', 'descarga', 'material'],
        'source': 'SNOWFLAKE',
        'description_en': 'Tons Delivered by Destination',
        'description_es': 'Toneladas por Destino',
    },
    'compliance': {
        'keywords': ['compliance', 'cumplimiento', 'adherence', 'adherencia'],
        'source': 'SNOWFLAKE',
        'description_en': 'Operational Compliance',
        'description_es': 'Cumplimiento Operacional',
    },
    'all_sensors': {
        'keywords': ['sensor', 'sensors', 'all', 'todo', 'sensores', 'tags', 'pi'],
        'source': 'ADX',
        'description_en': 'All Active Sensors',
        'description_es': 'Todos los Sensores Activos',
    },
}

# =============================================================================
# SITE MAPPINGS
# =============================================================================
SITE_ALIASES = {
    # Morenci
    'mor': 'MOR', 'morenci': 'MOR',
    # Bagdad
    'bag': 'BAG', 'bagdad': 'BAG',
    # Miami (SAM)
    'sam': 'SAM', 'miami': 'SAM', 'mia': 'SAM',
    # Climax
    'cmx': 'CMX', 'climax': 'CMX',
    # Sierrita
    'sie': 'SIE', 'sierrita': 'SIE',
    # New Mexico
    'nmo': 'NMO', 'newmexico': 'NMO', 'new mexico': 'NMO', 'nm': 'NMO',
    # Cerro Verde
    'cve': 'CVE', 'cerroverde': 'CVE', 'cerro verde': 'CVE', 'cv': 'CVE',
}

SITE_DATABASES = {
    'MOR': 'Morenci',
    'BAG': 'Bagdad',
    'SAM': 'Miami',
    'CMX': 'Climax',
    'SIE': 'Sierrita',
    'NMO': 'NewMexico',
    'CVE': 'CerroVerde',
}

SITE_NAMES = {
    'MOR': 'Morenci',
    'BAG': 'Bagdad',
    'SAM': 'Miami',
    'CMX': 'Climax',
    'SIE': 'Sierrita',
    'NMO': 'New Mexico',
    'CVE': 'Cerro Verde',
}

# =============================================================================
# QUERY TEMPLATES
# =============================================================================
QUERY_TEMPLATES = {
    'ios_level': {
        'MOR': """FCTSCURRENT()
| where sensor_id in ('MOR-CC06_LI00601_PV', 'MOR-CC10_LI0102_PV')
| project 
    Sensor = sensor_id,
    Level_Pct = round(todouble(value), 2),
    Timestamp = timestamp,
    UOM = uom
| order by Level_Pct desc""",
        'default': """FCTSCURRENT()
| where sensor_id contains 'LI' or sensor_id contains 'Level'
| where todouble(value) > 0 and todouble(value) < 100
| project Sensor = sensor_id, Level_Pct = round(todouble(value), 2), Timestamp = timestamp
| order by Level_Pct desc
| take 10"""
    },
    
    'crusher_rate': {
        'MOR': """FCTSCURRENT()
| where sensor_id in ('MOR-CR03_WI00317_PV', 'MOR-CR02_WI01203_PV')
| project 
    Crusher = case(
        sensor_id == 'MOR-CR03_WI00317_PV', 'Mill Crusher #3',
        sensor_id == 'MOR-CR02_WI01203_PV', 'MFL Crusher',
        sensor_id),
    Rate_TPH = round(todouble(value), 0),
    Target = iff(sensor_id == 'MOR-CR03_WI00317_PV', 8500, 4500),
    Status = case(
        todouble(value) >= 8000, '✅ ON TARGET',
        todouble(value) >= 6000, '⚠️ BELOW',
        '🔴 LOW'),
    Timestamp = timestamp""",
        'default': """FCTSCURRENT()
| where sensor_id contains 'CR' or sensor_id contains 'Crusher'
| where todouble(value) > 100
| project Sensor = sensor_id, Rate_TPH = round(todouble(value), 0), Timestamp = timestamp
| order by Rate_TPH desc
| take 10"""
    },
    
    'dig_rate': {
        'template': """SELECT 
    '{site}' as SITE,
    COUNT(DISTINCT EXCAV_ID) as SHOVEL_COUNT,
    ROUND(SUM(MEASURED_PAYLOAD_METRIC_TONS)) as TOTAL_TONS,
    ROUND(SUM(MEASURED_PAYLOAD_METRIC_TONS) / 
          NULLIF(TIMESTAMPDIFF(minute, MIN(CYCLE_START_TS_LOCAL), MAX(CYCLE_START_TS_LOCAL)) / 60.0, 0)) as DIG_RATE_TPOH
FROM PROD_WG.LOAD_HAUL.LH_LOADING_CYCLE
WHERE SITE_CODE = '{site}'
  AND CYCLE_START_TS_LOCAL >= DATEADD(hour, -24, CURRENT_TIMESTAMP())"""
    },
    
    'truck_count': {
        'template': """SELECT 
    '{site}' as SITE,
    COUNT(DISTINCT TRUCK_ID) as ACTIVE_TRUCKS,
    COUNT(*) as TOTAL_CYCLES,
    ROUND(AVG(TOTAL_CYCLE_DURATION_CALENDAR_MINS), 1) as AVG_CYCLE_MIN,
    ROUND(SUM(REPORT_PAYLOAD_SHORT_TONS)) as TOTAL_TONS_HAULED
FROM PROD_WG.LOAD_HAUL.LH_HAUL_CYCLE
WHERE SITE_CODE = '{site}'
  AND CYCLE_START_TS_LOCAL >= DATEADD(hour, -24, CURRENT_TIMESTAMP())"""
    },
    
    'cycle_time': {
        'template': """SELECT 
    '{site}' as SITE,
    ROUND(AVG(TOTAL_CYCLE_DURATION_CALENDAR_MINS), 1) as AVG_CYCLE_MIN,
    ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY TOTAL_CYCLE_DURATION_CALENDAR_MINS), 2) as MEDIAN_MIN,
    ROUND(MIN(TOTAL_CYCLE_DURATION_CALENDAR_MINS), 1) as MIN_CYCLE_MIN,
    ROUND(MAX(TOTAL_CYCLE_DURATION_CALENDAR_MINS), 1) as MAX_CYCLE_MIN,
    COUNT(*) as TOTAL_CYCLES
FROM PROD_WG.LOAD_HAUL.LH_HAUL_CYCLE
WHERE SITE_CODE = '{site}'
  AND CYCLE_START_TS_LOCAL >= DATEADD(hour, -24, CURRENT_TIMESTAMP())
  AND TOTAL_CYCLE_DURATION_CALENDAR_MINS BETWEEN 10 AND 120"""
    },
    
    'mill_rate': {
        'default': """FCTSCURRENT()
| where sensor_id contains 'Mill' or sensor_id contains 'SAG' or sensor_id contains 'Ball'
| where todouble(value) > 50
| project Sensor = sensor_id, Rate_TPH = round(todouble(value), 0), Timestamp = timestamp, UOM = uom
| order by Rate_TPH desc
| take 10"""
    },
    
    'priority_shovels': {
        'template': """SELECT 
    EXCAV_ID as SHOVEL,
    COUNT(*) as LOADS,
    ROUND(SUM(MEASURED_PAYLOAD_METRIC_TONS)) as TOTAL_TONS,
    ROUND(AVG(MEASURED_PAYLOAD_METRIC_TONS), 1) as AVG_LOAD_TONS
FROM PROD_WG.LOAD_HAUL.LH_LOADING_CYCLE
WHERE SITE_CODE = '{site}'
  AND CYCLE_START_TS_LOCAL >= DATEADD(hour, -24, CURRENT_TIMESTAMP())
GROUP BY EXCAV_ID
ORDER BY TOTAL_TONS DESC
LIMIT 5"""
    },
    
    'tons_delivered': {
        'template': """SELECT 
    DUMP_LOC_ID as DESTINATION,
    COUNT(*) as DUMPS,
    ROUND(SUM(REPORT_PAYLOAD_SHORT_TONS)) as TOTAL_TONS
FROM PROD_WG.LOAD_HAUL.LH_HAUL_CYCLE
WHERE SITE_CODE = '{site}'
  AND CYCLE_START_TS_LOCAL >= DATEADD(hour, -24, CURRENT_TIMESTAMP())
GROUP BY DUMP_LOC_ID
ORDER BY TOTAL_TONS DESC
LIMIT 10"""
    },
    
    'compliance': {
        'template': """SELECT 
    '{site}' as SITE,
    COUNT(*) as TOTAL_EVENTS,
    COUNT(DISTINCT EXCAV_ID) as ACTIVE_SHOVELS,
    ROUND(AVG(LOADING_CYCLE_DIG_ELEV_AVG_FEET), 2) as AVG_DIG_ELEVATION_FT
FROM PROD_WG.LOAD_HAUL.LH_LOADING_CYCLE
WHERE SITE_CODE = '{site}'
  AND CYCLE_START_TS_LOCAL >= DATEADD(hour, -1, CURRENT_TIMESTAMP())"""
    },
    
    'all_sensors': {
        'default': """FCTSCURRENT()
| where todouble(value) > 0
| summarize 
    Count = count(),
    Last_Reading = max(timestamp)
    by sensor_id
| order by Last_Reading desc
| take 20"""
    },
}


class NLPQueryTranslator:
    """
    Natural Language to Query Translator.
    Converts user questions into executable KQL/SQL queries.
    """
    
    def __init__(self, semantic_model_path: Optional[str] = None):
        self.semantic_model = None
        if semantic_model_path:
            self._load_semantic_model(semantic_model_path)
    
    def _load_semantic_model(self, path: str) -> None:
        """Load semantic model from YAML file."""
        try:
            with open(path, 'r', encoding='utf-8') as f:
                self.semantic_model = yaml.safe_load(f)
        except Exception:
            self.semantic_model = None
    
    def _detect_site(self, text: str, default: str = 'MOR') -> str:
        """Detect site code from text."""
        text_lower = text.lower()
        
        for alias, code in SITE_ALIASES.items():
            if alias in text_lower:
                return code
        
        return default
    
    def _detect_metric(self, text: str) -> Tuple[Optional[str], float]:
        """
        Detect metric type from text.
        Returns (metric_type, confidence)
        """
        text_lower = text.lower()
        
        best_match = None
        best_score = 0
        
        for metric_type, config in KEYWORD_MAPPINGS.items():
            matches = sum(1 for kw in config['keywords'] if kw in text_lower)
            if matches > best_score:
                best_score = matches
                best_match = metric_type
        
        confidence = min(best_score * 0.3, 1.0) if best_match else 0.0
        return best_match, confidence
    
    def _get_query(self, metric_type: str, site_code: str) -> str:
        """Get query for metric and site."""
        templates = QUERY_TEMPLATES.get(metric_type, {})
        
        # Check for site-specific query
        if site_code in templates:
            return templates[site_code]
        
        # Check for template
        if 'template' in templates:
            return templates['template'].format(site=site_code)
        
        # Default query
        return templates.get('default', '')
    
    def translate(self, user_input: str, current_site: str = 'MOR') -> QueryResult:
        """
        Translate natural language input to query.
        
        Args:
            user_input: User's natural language question
            current_site: Currently selected site code
            
        Returns:
            QueryResult with query details
        """
        # Detect site (or use current)
        detected_site = self._detect_site(user_input, current_site)
        
        # Detect metric type
        metric_type, confidence = self._detect_metric(user_input)
        
        if not metric_type:
            return QueryResult(
                success=False,
                source='HELP',
                database='',
                query='',
                explanation=self._get_help_text(),
                metric_type='help',
                site_code=detected_site,
                confidence=0.0
            )
        
        # Get query configuration
        config = KEYWORD_MAPPINGS[metric_type]
        source = config['source']
        database = SITE_DATABASES.get(detected_site, 'Morenci')
        site_name = SITE_NAMES.get(detected_site, detected_site)
        
        # Get query
        query = self._get_query(metric_type, detected_site)
        
        # Build explanation
        desc = config['description_es']
        explanation = f"📊 **{desc}** para {site_name}"
        
        return QueryResult(
            success=True,
            source=source,
            database=database,
            query=query,
            explanation=explanation,
            metric_type=metric_type,
            site_code=detected_site,
            confidence=confidence
        )
    
    def _get_help_text(self) -> str:
        """Get help text for unrecognized queries."""
        return """❓ **Comandos disponibles:**

🔹 `ios level` - Nivel de stockpile
🔹 `crusher rate` - Tasa de trituración
🔹 `dig rate` - Tasa de excavación
🔹 `truck count` - Conteo de camiones
🔹 `cycle time` - Tiempo de ciclo
🔹 `mill rate` - Tasa de molienda
🔹 `top shovels` - Mejores palas
🔹 `tons delivered` - Toneladas entregadas
🔹 `all sensors` - Todos los sensores

💡 **Tip:** Agrega el nombre del site
Ejemplo: `crusher rate bagdad`"""
    
    def get_quick_queries(self) -> List[Dict[str, str]]:
        """Get list of quick query buttons."""
        return [
            {'label': '📊 IOS', 'query': 'ios level'},
            {'label': '🔨 Crusher', 'query': 'crusher rate'},
            {'label': '🚚 Trucks', 'query': 'truck count'},
            {'label': '⏱️ Cycle', 'query': 'cycle time'},
            {'label': '⛏️ Dig', 'query': 'dig rate'},
            {'label': '🏆 Top', 'query': 'top shovels'},
        ]


# Singleton instance
translator = NLPQueryTranslator()


def translate_query(user_input: str, site_code: str = 'MOR') -> QueryResult:
    """Convenience function to translate query."""
    return translator.translate(user_input, site_code)
