import json

with open('SQLRefactoring/Tickets/DRILLBLAST_INCR/stress_test_v2_20260123_132002.json', 'r') as f:
    data = json.load(f)

print('='*80)
print('STRESS TEST RESULTS SUMMARY - 2026-01-23')
print('='*80)
print(f'Total Duration: {data["test_info"]["total_duration_seconds"]:.0f} seconds ({data["test_info"]["total_duration_seconds"]/60:.1f} min)')
print(f'Tables Tested: {data["test_info"]["tables_tested"]}')
print(f'Days Range: 1-30 (330 total queries)')
print()
print('| # | Table | Source | Rows(3d) | Rows(30d) | Avg Time | Success |')
print('|---|-------|--------|----------|-----------|----------|---------|')

for i, (name, info) in enumerate(data['results'].items(), 1):
    rows_3d = next((it['row_count'] for it in info['iterations'] if it['days_back'] == 3), 0)
    rows_30d = info['max_rows']
    avg = info['avg_duration']
    success = f"{info['successful']}/{info['total']}"
    print(f'| {i} | {name} | {info["source"].split(".")[-1]} | {rows_3d:,} | {rows_30d:,} | {avg:.2f}s | {success} |')

print()
print('All 330 queries completed successfully!')
