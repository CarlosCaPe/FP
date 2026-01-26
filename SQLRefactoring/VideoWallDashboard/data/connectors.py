"""
Data access layer for Snowflake and ADX connections.
Provides unified interface for querying both data sources.
"""
from abc import ABC, abstractmethod
from dataclasses import dataclass
from datetime import datetime, timedelta
from typing import Any, Dict, List, Optional
import logging

logger = logging.getLogger(__name__)


@dataclass
class QueryResult:
    """Standardized query result."""
    data: List[Dict[str, Any]]
    columns: List[str]
    row_count: int
    execution_time_ms: float
    source: str
    query: str
    timestamp: datetime


class DataConnector(ABC):
    """Abstract base class for data connectors."""
    
    @abstractmethod
    def connect(self) -> bool:
        """Establish connection to data source."""
        pass
    
    @abstractmethod
    def disconnect(self) -> None:
        """Close connection."""
        pass
    
    @abstractmethod
    def execute_query(self, query: str) -> QueryResult:
        """Execute query and return results."""
        pass
    
    @abstractmethod
    def is_connected(self) -> bool:
        """Check if connection is active."""
        pass


class SnowflakeConnector(DataConnector):
    """Snowflake data connector."""
    
    def __init__(
        self,
        account: str = "FCX-NA",
        warehouse: str = "WH_BATCH_DE_NONPROD",
        database: str = "PROD_WG",
        schema: str = "LOAD_HAUL",
    ):
        self.account = account
        self.warehouse = warehouse
        self.database = database
        self.schema = schema
        self._connection = None
    
    def connect(self) -> bool:
        """Establish Snowflake connection using externalbrowser auth."""
        try:
            import snowflake.connector
            self._connection = snowflake.connector.connect(
                account=self.account,
                warehouse=self.warehouse,
                database=self.database,
                schema=self.schema,
                authenticator="externalbrowser",
            )
            logger.info("Connected to Snowflake")
            return True
        except Exception as e:
            logger.error(f"Snowflake connection failed: {e}")
            return False
    
    def disconnect(self) -> None:
        """Close Snowflake connection."""
        if self._connection:
            self._connection.close()
            self._connection = None
            logger.info("Disconnected from Snowflake")
    
    def is_connected(self) -> bool:
        """Check if Snowflake connection is active."""
        return self._connection is not None
    
    def execute_query(self, query: str) -> QueryResult:
        """Execute Snowflake query."""
        if not self.is_connected():
            raise ConnectionError("Not connected to Snowflake")
        
        start_time = datetime.now()
        cursor = self._connection.cursor()
        
        try:
            cursor.execute(query)
            columns = [desc[0] for desc in cursor.description]
            rows = cursor.fetchall()
            data = [dict(zip(columns, row)) for row in rows]
            
            execution_time = (datetime.now() - start_time).total_seconds() * 1000
            
            return QueryResult(
                data=data,
                columns=columns,
                row_count=len(data),
                execution_time_ms=execution_time,
                source="SNOWFLAKE",
                query=query,
                timestamp=datetime.now(),
            )
        finally:
            cursor.close()


class ADXConnector(DataConnector):
    """Azure Data Explorer connector."""
    
    def __init__(
        self,
        cluster: str = "https://fctsnaproddatexp02.westus2.kusto.windows.net",
        database: str = "Morenci",
    ):
        self.cluster = cluster
        self.database = database
        self._client = None
    
    def connect(self) -> bool:
        """Establish ADX connection using interactive browser auth."""
        try:
            from azure.kusto.data import KustoClient, KustoConnectionStringBuilder
            from azure.identity import InteractiveBrowserCredential
            
            credential = InteractiveBrowserCredential()
            kcsb = KustoConnectionStringBuilder.with_aad_user_token_authentication(
                self.cluster,
                credential.get_token("https://kusto.kusto.windows.net/.default").token
            )
            self._client = KustoClient(kcsb)
            logger.info(f"Connected to ADX cluster: {self.cluster}")
            return True
        except Exception as e:
            logger.error(f"ADX connection failed: {e}")
            return False
    
    def disconnect(self) -> None:
        """Close ADX connection."""
        self._client = None
        logger.info("Disconnected from ADX")
    
    def is_connected(self) -> bool:
        """Check if ADX connection is active."""
        return self._client is not None
    
    def execute_query(self, query: str) -> QueryResult:
        """Execute KQL query."""
        if not self.is_connected():
            raise ConnectionError("Not connected to ADX")
        
        start_time = datetime.now()
        
        try:
            response = self._client.execute(self.database, query)
            primary_results = response.primary_results[0]
            
            columns = [col.column_name for col in primary_results.columns]
            data = [dict(zip(columns, row)) for row in primary_results.rows]
            
            execution_time = (datetime.now() - start_time).total_seconds() * 1000
            
            return QueryResult(
                data=data,
                columns=columns,
                row_count=len(data),
                execution_time_ms=execution_time,
                source="ADX",
                query=query,
                timestamp=datetime.now(),
            )
        except Exception as e:
            logger.error(f"ADX query failed: {e}")
            raise


class MockDataConnector(DataConnector):
    """Mock data connector for development/testing."""
    
    def __init__(self, source: str = "MOCK"):
        self.source = source
        self._connected = False
    
    def connect(self) -> bool:
        self._connected = True
        return True
    
    def disconnect(self) -> None:
        self._connected = False
    
    def is_connected(self) -> bool:
        return self._connected
    
    def execute_query(self, query: str) -> QueryResult:
        """Return mock data based on query patterns."""
        import random
        
        # Generate sample data based on query type
        if "DIG" in query.upper() or "LOADING" in query.upper():
            data = self._mock_loading_data()
        elif "HAUL" in query.upper() or "CYCLE" in query.upper():
            data = self._mock_haulage_data()
        elif "FCTSCURRENT" in query.upper():
            data = self._mock_adx_data()
        else:
            data = [{"value": random.uniform(80, 100)}]
        
        return QueryResult(
            data=data,
            columns=list(data[0].keys()) if data else [],
            row_count=len(data),
            execution_time_ms=random.uniform(50, 200),
            source=self.source,
            query=query,
            timestamp=datetime.now(),
        )
    
    def _mock_loading_data(self) -> List[Dict]:
        """Generate mock loading section data."""
        import random
        return [
            {
                "SITE_CODE": "MOR",
                "TOTAL_DIG_EVENTS": random.randint(2500, 3000),
                "UNIQUE_DIG_LOCATIONS": random.randint(15, 25),
                "ACTIVE_SHOVELS": random.randint(10, 15),
                "AVG_DIG_ELEVATION_FT": round(random.uniform(5000, 5500), 2),
                "TOTAL_TONS_24HR": round(random.uniform(600000, 700000), 2),
            }
        ]
    
    def _mock_haulage_data(self) -> List[Dict]:
        """Generate mock haulage section data."""
        import random
        return [
            {
                "SITE_CODE": "MOR",
                "ACTIVE_TRUCKS": random.randint(100, 130),
                "TOTAL_CYCLES": random.randint(2500, 3000),
                "AVG_CYCLE_TIME_MINS": round(random.uniform(45, 60), 2),
                "TOTAL_TONS_HAULED": round(random.uniform(650000, 750000), 2),
            }
        ]
    
    def _mock_adx_data(self) -> List[Dict]:
        """Generate mock ADX sensor data."""
        import random
        return [
            {
                "sensor_id": "MOR-CR03_WI00317_PV",
                "value": round(random.uniform(8000, 9000), 2),
                "timestamp": datetime.now().isoformat(),
                "uom": "TPH",
            },
            {
                "sensor_id": "MOR-CC06_LI00601_PV",
                "value": round(random.uniform(25, 75), 2),
                "timestamp": datetime.now().isoformat(),
                "uom": "%",
            },
        ]


class DataService:
    """Unified data service managing all connectors."""
    
    def __init__(self, use_mock: bool = True):
        self.use_mock = use_mock
        self._snowflake: Optional[DataConnector] = None
        self._adx: Optional[DataConnector] = None
    
    def initialize(self) -> None:
        """Initialize all data connectors."""
        if self.use_mock:
            self._snowflake = MockDataConnector("SNOWFLAKE")
            self._adx = MockDataConnector("ADX")
        else:
            self._snowflake = SnowflakeConnector()
            self._adx = ADXConnector()
        
        self._snowflake.connect()
        self._adx.connect()
    
    def shutdown(self) -> None:
        """Shutdown all connectors."""
        if self._snowflake:
            self._snowflake.disconnect()
        if self._adx:
            self._adx.disconnect()
    
    def query_snowflake(self, query: str) -> QueryResult:
        """Execute Snowflake query."""
        if not self._snowflake:
            raise RuntimeError("Snowflake connector not initialized")
        return self._snowflake.execute_query(query)
    
    def query_adx(self, query: str) -> QueryResult:
        """Execute ADX query."""
        if not self._adx:
            raise RuntimeError("ADX connector not initialized")
        return self._adx.execute_query(query)
    
    def query(self, query: str, source: str = "SNOWFLAKE") -> QueryResult:
        """Execute query on specified source."""
        if source.upper() == "SNOWFLAKE":
            return self.query_snowflake(query)
        elif source.upper() == "ADX":
            return self.query_adx(query)
        else:
            raise ValueError(f"Unknown data source: {source}")


# Singleton instance
data_service = DataService(use_mock=True)
