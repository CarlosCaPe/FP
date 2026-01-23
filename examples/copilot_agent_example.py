"""
GitHub Copilot SDK - Ejemplo Básico
====================================
Este ejemplo muestra cómo usar el SDK para crear un agente simple.
Requiere Copilot CLI instalado: https://docs.github.com/en/copilot/how-tos/set-up/install-copilot-cli

USO FUTURO: Crear chatbot para consultar datos ADX en lenguaje natural.

Ejemplo de uso:
    python copilot_agent_example.py "¿Cuál es el nivel actual del IOS en Morenci?"
"""

import asyncio
import sys
from copilot import CopilotClient

async def run_agent(prompt: str) -> str:
    """
    Ejecuta un prompt usando el agente de Copilot.
    El agente puede ejecutar herramientas, leer archivos, etc.
    """
    async with CopilotClient() as client:
        # Crear una sesión de agente
        response = await client.ask(prompt)
        return response.content

async def run_agent_with_tools(prompt: str) -> str:
    """
    Ejecuta un prompt con herramientas personalizadas habilitadas.
    Puedes definir skills/tools propios para consultar ADX, etc.
    """
    async with CopilotClient() as client:
        # Configurar opciones del agente
        response = await client.ask(
            prompt,
            # model="gpt-4",  # Opcional: especificar modelo
            # tools_enabled=True,  # Habilitar herramientas
        )
        return response.content

# =============================================================================
# EJEMPLO: Agente ADX (para implementar después)
# =============================================================================
# 
# from azure.identity import InteractiveBrowserCredential
# from azure.kusto.data import KustoClient, KustoConnectionStringBuilder
# 
# async def adx_query_agent(natural_language_query: str) -> str:
#     """
#     Agente que traduce lenguaje natural a KQL y ejecuta en ADX.
#     
#     Ejemplo:
#         "¿Cuál es el nivel actual del IOS principal en Morenci?"
#         → Genera KQL → Ejecuta en ADX → Devuelve resultado
#     """
#     # 1. Usar Copilot para generar KQL
#     async with CopilotClient() as client:
#         kql_prompt = f"""
#         Genera una query KQL para Azure Data Explorer basada en esta pregunta:
#         "{natural_language_query}"
#         
#         Contexto:
#         - Cluster: fctsnaproddatexp02.westus2.kusto.windows.net
#         - Database: Morenci (para datos de sensores)
#         - Función FCTSCURRENT: valores actuales de sensores
#         - Sensor IOS principal: MOR-CC06_LI00601_PV
#         
#         Devuelve SOLO el KQL, sin explicación.
#         """
#         kql_response = await client.ask(kql_prompt)
#         kql = kql_response.content
#     
#     # 2. Ejecutar en ADX
#     # credential = InteractiveBrowserCredential()
#     # ... ejecutar query y devolver resultado
#     
#     return kql

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Uso: python copilot_agent_example.py 'tu pregunta aquí'")
        print("\nEjemplo:")
        print("  python copilot_agent_example.py '¿Qué archivos Python hay en este proyecto?'")
        sys.exit(1)
    
    prompt = sys.argv[1]
    print(f"\n🤖 Pregunta: {prompt}\n")
    
    try:
        result = asyncio.run(run_agent(prompt))
        print(f"📝 Respuesta:\n{result}")
    except Exception as e:
        print(f"❌ Error: {e}")
        print("\n⚠️  Asegúrate de tener Copilot CLI instalado y autenticado.")
        print("   Instalación: https://docs.github.com/en/copilot/how-tos/set-up/install-copilot-cli")
