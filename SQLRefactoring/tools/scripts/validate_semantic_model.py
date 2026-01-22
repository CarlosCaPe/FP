"""
Semantic Model Validator
Checks for structural integrity and common issues
"""
import yaml
import sys

def validate_model(path):
    print("=" * 60)
    print("SEMANTIC MODEL VALIDATION")
    print("=" * 60)
    
    with open(path, 'r', encoding='utf-8') as f:
        model = yaml.safe_load(f)
    
    errors = []
    warnings = []
    
    # 1. Required top-level keys
    print("\n1. TOP-LEVEL STRUCTURE")
    required_keys = ['version', 'name', 'connections', 'outcome_definitions']
    for key in required_keys:
        if key in model:
            print(f"   ✅ {key}")
        else:
            errors.append(f"Missing required key: {key}")
            print(f"   ❌ {key} - MISSING")
    
    # 2. Connections
    print("\n2. CONNECTIONS")
    if 'connections' in model:
        for conn_name, conn in model['connections'].items():
            required_conn = {
                'snowflake': ['account', 'warehouse', 'database'],
                'adx': ['cluster']
            }
            if conn_name in required_conn:
                missing = [k for k in required_conn[conn_name] if k not in conn]
                if missing:
                    errors.append(f"Connection {conn_name} missing: {missing}")
                    print(f"   ❌ {conn_name}: missing {missing}")
                else:
                    print(f"   ✅ {conn_name}: complete")
    
    # 3. Outcome definitions
    print("\n3. OUTCOME DEFINITIONS")
    if 'outcome_definitions' in model:
        outcomes = model['outcome_definitions']
        print(f"   Count: {len(outcomes)}")
        
        required_outcome_keys = ['name', 'description', 'unit', 'sensible_range']
        for oid, odef in outcomes.items():
            missing = [k for k in required_outcome_keys if k not in odef]
            if missing:
                warnings.append(f"Outcome {oid} missing: {missing}")
        
        # Check sensible_range structure
        for oid, odef in outcomes.items():
            sr = odef.get('sensible_range', {})
            if sr and ('min' not in sr or 'max' not in sr):
                warnings.append(f"Outcome {oid} sensible_range incomplete")
        
        if not warnings:
            print("   ✅ All outcomes have complete metadata")
        else:
            print(f"   ⚠️ {len(warnings)} warnings")
    
    # 4. Sites
    print("\n4. SITES")
    sites = ['MOR', 'BAG', 'SAM', 'CMX', 'SIE', 'NMO', 'CVE']
    for site in sites:
        if site not in model:
            errors.append(f"Missing site: {site}")
            print(f"   ❌ {site} - MISSING")
        else:
            site_data = model[site]
            outcomes = site_data.get('outcomes', {})
            
            # Check required site keys
            required_site = ['name', 'adx_database', 'outcomes']
            missing_site = [k for k in required_site if k not in site_data]
            
            if missing_site:
                errors.append(f"Site {site} missing: {missing_site}")
            
            # Check outcomes
            valid_outcomes = 0
            for oid, outcome in outcomes.items():
                if 'query' in outcome and outcome.get('query'):
                    valid_outcomes += 1
                else:
                    warnings.append(f"{site}.{oid} missing query")
            
            status = "✅" if not missing_site else "⚠️"
            print(f"   {status} {site}: {valid_outcomes}/{len(outcomes)} outcomes with queries")
    
    # 5. Cross-site queries
    print("\n5. CROSS-SITE QUERIES")
    if 'cross_site_queries' in model:
        csq = model['cross_site_queries']
        print(f"   ✅ {len(csq)} cross-site queries defined")
    else:
        warnings.append("No cross-site queries defined")
        print("   ⚠️ Not defined")
    
    # 6. Column mappings
    print("\n6. COLUMN MAPPINGS")
    if 'column_mappings' in model:
        cm = model['column_mappings']
        print(f"   ✅ Defined for: {list(cm.keys())}")
    else:
        warnings.append("No column mappings")
        print("   ⚠️ Not defined")
    
    # 7. Usage examples
    print("\n7. USAGE EXAMPLES")
    if 'usage_examples' in model:
        ue = model['usage_examples']
        print(f"   ✅ {len(ue)} examples: {list(ue.keys())}")
    else:
        warnings.append("No usage examples")
        print("   ⚠️ Not defined")
    
    # 8. Sample data check
    print("\n8. SAMPLE DATA VALIDATION")
    samples_found = 0
    samples_with_data = 0
    for site in sites:
        if site in model:
            for oid, outcome in model[site].get('outcomes', {}).items():
                samples_found += 1
                sample = outcome.get('sample_data', [])
                if sample and len(sample) > 0 and 'error' not in str(sample):
                    samples_with_data += 1
    
    pct = (samples_with_data / samples_found * 100) if samples_found > 0 else 0
    print(f"   Outcomes with sample data: {samples_with_data}/{samples_found} ({pct:.1f}%)")
    
    # Summary
    print("\n" + "=" * 60)
    print("VALIDATION SUMMARY")
    print("=" * 60)
    
    if errors:
        print(f"\n❌ ERRORS ({len(errors)}):")
        for e in errors:
            print(f"   - {e}")
    else:
        print("\n✅ No critical errors")
    
    if warnings:
        print(f"\n⚠️ WARNINGS ({len(warnings)}):")
        for w in warnings[:10]:  # Show first 10
            print(f"   - {w}")
        if len(warnings) > 10:
            print(f"   ... and {len(warnings) - 10} more")
    else:
        print("\n✅ No warnings")
    
    # Final verdict
    print("\n" + "-" * 60)
    if not errors:
        print("✅ MODEL IS VALID")
        return True
    else:
        print("❌ MODEL HAS ERRORS - NEEDS FIX")
        return False


if __name__ == "__main__":
    path = "adx_semantic_models/ADX_UNIFIED.semantic.yaml"
    validate_model(path)
