#!/bin/bash

flag=`klist 2>&1 >/dev/null`
[[ -z $flag ]] && kinit -R && echo Credentials renewed...
expire=`klist 2>/dev/null | grep krbtgt | awk -F ' ' '{print $3, $4}'`
expire=${expire:-$(date)}
elapsed=$(($(date -d "$expire" +%s)-$(date +%s)))
[[ $elapsed -gt 1800 ]] && echo Authentication skipped... && exit 0

set -ueE -o pipefail

echo Authentication started...

[[ "$SVC_ACCT_USER" ]]
[[ "$FUNC_APP_KEYVAULT" ]]
[[ "$SVC_ACCT_KEY" ]]

az login -i >/dev/null
SVC_ACCT_PASS=`az keyvault secret show --vault-name "${FUNC_APP_KEYVAULT}" --name "${SVC_ACCT_KEY}" --query "value" -o tsv`
kinit -C "$SVC_ACCT_USER" <<< "$SVC_ACCT_PASS"

echo Authentication completed...
