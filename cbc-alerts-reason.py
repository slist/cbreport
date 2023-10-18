#!/usr/bin/env python3

import sys

# CBC SDK Base
from cbc_sdk import CBCloudAPI

# CBC ContainerRuntimeAlert
from cbc_sdk.platform import ContainerRuntimeAlert

# API keys
cb = CBCloudAPI(profile='default')

# Get Container Runtime alerts from last 12 weeks
alerts = cb.select(ContainerRuntimeAlert).set_time_range('last_update_time', range="-12w")

for alert in alerts:
    print(alert.cluster_name, alert.namespace, alert.reason, alert.rule_name)
