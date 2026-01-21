import os
import asyncio
import logging
from datetime import datetime, timezone

from azure.core.exceptions import ResourceExistsError
from azure.data.tables.aio import TableClient
from azure.monitor.opentelemetry import configure_azure_monitor

async def is_locked():
    async with TableClient.from_connection_string(conn_str=st_conn_str, table_name=table_name) as table_client:
        try:
            await table_client.create_table()
        except ResourceExistsError:
            pass
        try:
            item = await table_client.get_entity('auth', 'failure')
        except:
            last_time = datetime.min.replace(tzinfo=timezone.utc)
        else:
            last_time = item.metadata.get('timestamp')
        finally:
            return (datetime.now(timezone.utc) - last_time).total_seconds()//60 < 30

async def lock_auth():
    async with TableClient.from_connection_string(conn_str=st_conn_str, table_name=table_name) as table_client:
        try:
            await table_client.create_table()
        except ResourceExistsError:
            pass
        item = {'PartitionKey': 'auth', 'RowKey': 'failure'}
        await table_client.upsert_entity(item)

async def login():
    # if slot != 'Production':
    #     return

    locked = await is_locked()
    if locked:
        return

    configure_azure_monitor(logger_name=process, connection_string=appi_conn_str)
    logger = logging.getLogger(process)
    logger.setLevel(logging.INFO)

    environment = dict(os.environ)
    proc = await asyncio.create_subprocess_shell(
        'sh -c /kerberos/login.sh',
        env=environment,
        stdout=asyncio.subprocess.PIPE,
        stderr=asyncio.subprocess.PIPE
    )

    stdout, stderr = await proc.communicate()
    stdout = stdout.decode().strip()
    stderr = stderr.decode().strip()

    extra = {'proc': process, 'instance_id': instance, 'account': user, 'keyvault': keyvault, 'key': key} # 'slot': slot

    if stdout:
        if 'password will expire' in stdout:
            logger.warning(stdout, extra=extra)
        else:
            logger.info(stdout, extra=extra)
    if stderr:
        if 'while getting initial credentials' in stderr:
            await lock_auth()
            logger.error(stderr.rstrip('.') + '. Authentication temporarily suspended', extra=extra)
        else:
            logger.error(stderr, extra=extra)

process = 'auth'
table_name = 'FUSELocks'
# slot = os.environ.get('WEBSITE_SLOT_NAME')
instance = os.environ.get('WEBSITE_INSTANCE_ID')
st_conn_str = os.environ.get('AzureWebJobsStorage')
appi_conn_str = os.environ.get('APPLICATIONINSIGHTS_CONNECTION_STRING')
user = os.environ.get('SVC_ACCT_USER')
keyvault = os.environ.get('SVC_ACCT_KEYVAULT')
key = os.environ.get('SVC_ACCT_KEY')

asyncio.run(login())
