"""
Verificar membresía en grupos de Azure AD
"""
from azure.identity import InteractiveBrowserCredential
import requests

print("Autenticando con Azure AD...")
credential = InteractiveBrowserCredential()

# Obtener token para Microsoft Graph
token = credential.get_token("https://graph.microsoft.com/.default")

headers = {
    "Authorization": f"Bearer {token.token}",
    "Content-Type": "application/json"
}

# 1. Obtener info del usuario actual
print("\n👤 Usuario actual:")
me = requests.get("https://graph.microsoft.com/v1.0/me", headers=headers).json()
print(f"   Nombre: {me.get('displayName')}")
print(f"   Email: {me.get('mail') or me.get('userPrincipalName')}")
print(f"   ID: {me.get('id')}")

# 2. Buscar el grupo SG-ENT-FCTS-ADX-Viewer
print("\n🔍 Buscando grupo SG-ENT-FCTS-ADX-Viewer...")
groups_search = requests.get(
    "https://graph.microsoft.com/v1.0/groups",
    params={"$filter": "displayName eq 'SG-ENT-FCTS-ADX-Viewer'"},
    headers=headers
).json()

if groups_search.get('value'):
    group = groups_search['value'][0]
    group_id = group['id']
    print(f"   ✅ Grupo encontrado: {group['displayName']}")
    print(f"   ID: {group_id}")
    
    # 3. Verificar si estoy en el grupo
    print("\n🔐 Verificando membresía...")
    check = requests.post(
        f"https://graph.microsoft.com/v1.0/groups/{group_id}/checkMemberObjects",
        headers=headers,
        json={"ids": [me.get('id')]}
    )
    
    if check.status_code == 200:
        result = check.json()
        if group_id in result.get('value', []):
            print("   ✅ SÍ estás en el grupo!")
        else:
            print("   ❌ NO estás en el grupo")
    else:
        # Alternativa: listar miembros y buscar
        print("   Verificando de otra forma...")
        is_member = requests.get(
            f"https://graph.microsoft.com/v1.0/me/memberOf",
            headers=headers
        ).json()
        
        member_of_groups = [g.get('displayName') for g in is_member.get('value', []) if g.get('@odata.type') == '#microsoft.graph.group']
        
        if 'SG-ENT-FCTS-ADX-Viewer' in member_of_groups:
            print("   ✅ SÍ estás en el grupo!")
        else:
            print("   ❌ NO estás en el grupo")
            print(f"\n   Grupos en los que estás ({len(member_of_groups)}):")
            for g in sorted(member_of_groups)[:20]:
                print(f"      • {g}")
            if len(member_of_groups) > 20:
                print(f"      ... y {len(member_of_groups) - 20} más")
else:
    print("   ❌ Grupo no encontrado (puede que no tengas permiso para verlo)")
    
    # Alternativa: buscar en mis grupos
    print("\n📋 Buscando en tus grupos...")
    my_groups = requests.get(
        "https://graph.microsoft.com/v1.0/me/memberOf",
        headers=headers
    ).json()
    
    adx_groups = [g.get('displayName') for g in my_groups.get('value', []) 
                  if g.get('@odata.type') == '#microsoft.graph.group' 
                  and ('ADX' in g.get('displayName', '') or 'FCTS' in g.get('displayName', ''))]
    
    if adx_groups:
        print("   Grupos relacionados con ADX/FCTS:")
        for g in adx_groups:
            print(f"      • {g}")
    else:
        print("   No encontré grupos con 'ADX' o 'FCTS' en tu membresía")
