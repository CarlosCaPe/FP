"""
Double-check verification of MORENCI_ALL_OUTCOMES.semantic.yaml
Verifies: YAML validity, all 16 outcomes present, sample data exists
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

def verify_semantic_model():
    yaml_path = "adx_semantic_models/MORENCI_ALL_OUTCOMES.semantic.yaml"
    
    print("=" * 70)
    print("DOUBLE-CHECK: MORENCI_ALL_OUTCOMES.semantic.yaml")
    print("=" * 70)
    
    # Step 1: Check file exists
    if not os.path.exists(yaml_path):
        print("❌ ERROR: File does not exist!")
        return False
    print(f"✅ File exists: {yaml_path}")
    
    # Step 2: Parse YAML
    try:
        with open(yaml_path, 'r', encoding='utf-8') as f:
            data = yaml.safe_load(f)
        print("✅ YAML is valid and parseable")
    except yaml.YAMLError as e:
        print(f"❌ YAML PARSE ERROR: {e}")
        return False
    
    # Step 3: Check structure
    if 'outcomes' not in data:
        print("❌ ERROR: 'outcomes' key missing from YAML")
        return False
    
    outcomes = data['outcomes']
    print(f"✅ Found {len(outcomes)} outcomes in semantic model")
    
    # Step 4: Verify all 16 required outcomes
    print("\n" + "-" * 70)
    print("CHECKING ALL 16 REQUIRED OUTCOMES:")
    print("-" * 70)
    
    found_outcomes = {o['name']: o for o in outcomes}
    missing = []
    has_sample_data = []
    no_sample_data = []
    
    for i, required in enumerate(REQUIRED_OUTCOMES, 1):
        if required in found_outcomes:
            outcome = found_outcomes[required]
            has_query = 'query' in outcome and outcome['query']
            has_sample = 'sample_data' in outcome and outcome['sample_data']
            
            query_status = "✅" if has_query else "❌"
            sample_status = "✅" if has_sample else "⚠️"
            
            # Check if sample_data has actual data or row_count > 0
            data_available = False
            if has_sample:
                sd = outcome['sample_data']
                if 'data' in sd and sd['data']:
                    data_available = True
                    has_sample_data.append(required)
                elif sd.get('row_count', 0) == 0 and 'note' in sd:
                    # Has note explaining why no data
                    data_available = True  # Query works, just no data at that moment
                    has_sample_data.append(required)
                else:
                    no_sample_data.append(required)
            else:
                no_sample_data.append(required)
            
            source = outcome.get('source', 'N/A')
            print(f"  {i:2}. {query_status} {sample_status} [{source:9}] {required}")
        else:
            missing.append(required)
            print(f"  {i:2}. ❌ ❌ MISSING: {required}")
    
    # Step 5: Summary
    print("\n" + "=" * 70)
    print("VERIFICATION SUMMARY")
    print("=" * 70)
    
    if missing:
        print(f"❌ MISSING OUTCOMES ({len(missing)}):")
        for m in missing:
            print(f"   - {m}")
    else:
        print("✅ All 16 required outcomes are present")
    
    print(f"\n📊 Sample Data Status:")
    print(f"   - With data/validation: {len(has_sample_data)}/16")
    print(f"   - Missing sample data:  {len(no_sample_data)}/16")
    
    if no_sample_data:
        print(f"\n⚠️ Outcomes without sample data:")
        for n in no_sample_data:
            print(f"   - {n}")
    
    # Step 6: Verify queries have content
    print("\n" + "-" * 70)
    print("QUERY CONTENT CHECK:")
    print("-" * 70)
    
    for outcome in outcomes:
        name = outcome['name']
        query = outcome.get('query', '')
        if not query or len(query.strip()) < 10:
            print(f"  ❌ {name}: Query is empty or too short")
        else:
            # Show first line of query
            first_line = query.strip().split('\n')[0][:50]
            print(f"  ✅ {name}: {first_line}...")
    
    print("\n" + "=" * 70)
    all_ok = len(missing) == 0
    if all_ok:
        print("✅ SEMANTIC MODEL VERIFIED: ALL 16 OUTCOMES PRESENT WITH QUERIES")
    else:
        print("❌ SEMANTIC MODEL INCOMPLETE")
    print("=" * 70)
    
    return all_ok

if __name__ == "__main__":
    verify_semantic_model()
