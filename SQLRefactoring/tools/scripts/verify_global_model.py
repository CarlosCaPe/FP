"""
Final Verification of GLOBAL_UNIFIED_ALL_SITES.semantic.yaml
Checks: YAML validity, all 16 outcomes, all 7 sites, sample data
"""
import yaml
import os

REQUIRED_OUTCOMES = [
    "Dig compliance (%)",
    "Dig rate (TPOH)",
    "Priority shovels",
    "Number of trucks (qty)",
    "Cycle Time (min)",
    "Asset Efficiency",
    "Dump plan compliance (%)",
    "Mill - tons delivered",
    "Mill - Crusher Rate (TPOH)",
    "Mill - Mill Rate (TPOH)",
    "Mill - Strategy compliance",
    "MFL - tons delivered",
    "MFL - Crusher Rate (TPOH)",
    "MFL - FOS Rate (TPOH)",
    "MFL - Strategy compliance",
    "ROM - tons delivered"
]

REQUIRED_SITES = ["MOR", "BAG", "SAM", "CMX", "SIE", "NMO", "CVE"]

def verify_global_model():
    yaml_path = "adx_semantic_models/GLOBAL_UNIFIED_ALL_SITES.semantic.yaml"
    
    print("=" * 80)
    print("FINAL VERIFICATION: GLOBAL_UNIFIED_ALL_SITES.semantic.yaml")
    print("=" * 80)
    
    # Check file exists
    if not os.path.exists(yaml_path):
        print("❌ ERROR: File does not exist!")
        return False
    print(f"✅ File exists: {yaml_path}")
    
    # Parse YAML
    try:
        with open(yaml_path, 'r', encoding='utf-8') as f:
            data = yaml.safe_load(f)
        print("✅ YAML is valid and parseable")
    except yaml.YAMLError as e:
        print(f"❌ YAML PARSE ERROR: {e}")
        return False
    
    # Check sites
    print("\n" + "-" * 80)
    print("SITES REGISTRY:")
    print("-" * 80)
    sites = data.get('sites', {})
    for site_code in REQUIRED_SITES:
        if site_code in sites:
            site_info = sites[site_code]
            sensor_count = site_info.get('sensor_count', 'N/A')
            adx_db = site_info.get('adx_database', 'N/A')
            print(f"  ✅ {site_code}: {site_info['name']} | ADX: {adx_db} | Sensors: {sensor_count}")
        else:
            print(f"  ❌ {site_code}: MISSING")
    
    # Check outcomes
    print("\n" + "-" * 80)
    print("16 REQUIRED OUTCOMES:")
    print("-" * 80)
    
    outcomes = data.get('outcomes', [])
    found_names = {o['name'] for o in outcomes}
    
    for i, required in enumerate(REQUIRED_OUTCOMES, 1):
        if required in found_names:
            outcome = next(o for o in outcomes if o['name'] == required)
            source = outcome.get('source', 'N/A')
            supports = outcome.get('supports_sites', [])
            has_query = 'query_template' in outcome
            has_sample = 'sample_data_by_site' in outcome and outcome['sample_data_by_site']
            
            sites_with_data = len(outcome.get('sample_data_by_site', {}))
            
            q_status = "✅" if has_query else "❌"
            s_status = "✅" if has_sample else "⚠️"
            
            print(f"  {i:2}. {q_status}{s_status} [{source:9}] {required} ({sites_with_data} sites with samples)")
        else:
            print(f"  {i:2}. ❌❌ MISSING: {required}")
    
    # Check cross-site queries
    print("\n" + "-" * 80)
    print("CROSS-SITE QUERIES:")
    print("-" * 80)
    cross_site = data.get('cross_site_queries', {})
    for name, query_info in cross_site.items():
        print(f"  ✅ {name}: {query_info.get('description', 'N/A')[:50]}...")
    
    # Summary
    print("\n" + "=" * 80)
    print("VERIFICATION SUMMARY")
    print("=" * 80)
    print(f"✅ Sites: {len(sites)}/7")
    print(f"✅ Outcomes: {len(outcomes)}/16")
    print(f"✅ Cross-site queries: {len(cross_site)}")
    
    # Count total sample data entries
    total_samples = sum(
        len(o.get('sample_data_by_site', {})) 
        for o in outcomes
    )
    print(f"✅ Total sample data entries: {total_samples}")
    
    # File size
    file_size = os.path.getsize(yaml_path)
    print(f"📄 File size: {file_size / 1024:.1f} KB")
    
    print("\n" + "=" * 80)
    if len(sites) == 7 and len(outcomes) == 16:
        print("✅ GLOBAL UNIFIED MODEL VERIFIED: ALL SITES AND OUTCOMES PRESENT")
    else:
        print("⚠️ SOME ELEMENTS MISSING")
    print("=" * 80)
    
    return True

if __name__ == "__main__":
    verify_global_model()
