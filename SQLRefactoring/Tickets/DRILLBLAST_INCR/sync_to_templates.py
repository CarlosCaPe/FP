"""Sync fixed DEV procedures back to templates (DDL-Scripts)"""
from pathlib import Path
import re

deploy_dev = Path(__file__).parent / "DEPLOY_DEV" / "PROCEDURES"
templates = Path(__file__).parent / "DDL-Scripts" / "API_REF" / "FUSE" / "PROCEDURES"

# Procedures that were fixed
fixed_procs = [
    "R__BLAST_PLAN_INCR_P.sql",
    "R__DRILL_CYCLE_INCR_P.sql",
    "R__DRILL_PLAN_INCR_P.sql",
    "R__BLAST_PLAN_EXECUTION_INCR_P.sql",
]

print("=" * 70)
print("Syncing fixed procedures from DEPLOY_DEV to DDL-Scripts templates")
print("=" * 70)

for proc in fixed_procs:
    dev_path = deploy_dev / proc
    template_path = templates / proc
    
    if not dev_path.exists():
        print(f"❌ {proc}: DEV file not found")
        continue
    
    # Read DEV version
    content = dev_path.read_text(encoding="utf-8")
    
    # Convert back to Jinja templates
    # DEV_API_REF -> {{ envi }}_API_REF
    content = re.sub(r'\bDEV_API_REF\b', '{{ envi }}_API_REF', content)
    
    # PROD_WG -> {{ RO_PROD }}_WG
    content = re.sub(r'\bPROD_WG\b', '{{ RO_PROD }}_WG', content)
    
    # Write to template
    template_path.write_text(content, encoding="utf-8")
    print(f"✅ {proc}: Synced to template")

print("\n" + "=" * 70)
print("Verification - checking for {{ envi }} and {{ RO_PROD }} in templates")
print("=" * 70)

for proc in fixed_procs:
    template_path = templates / proc
    content = template_path.read_text(encoding="utf-8")
    
    has_envi = "{{ envi }}" in content
    has_ro_prod = "{{ RO_PROD }}" in content
    
    if has_envi and has_ro_prod:
        print(f"✅ {proc}: Templates correct")
    else:
        issues = []
        if not has_envi:
            issues.append("missing {{ envi }}")
        if not has_ro_prod:
            issues.append("missing {{ RO_PROD }}")
        print(f"⚠️ {proc}: {', '.join(issues)}")

print("\nDone!")
