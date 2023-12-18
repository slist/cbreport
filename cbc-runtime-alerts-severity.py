#!/usr/bin/env python3

import sys

# CBC SDK Base
from cbc_sdk import CBCloudAPI

# CBC ContainerRuntimeAlert
from cbc_sdk.platform import ContainerRuntimeAlert

argprofile = "default"

if len(sys.argv) > 1:
    argprofile = str(sys.argv[1])
    if argprofile == "":
        argprofile = "default"

# API keys
cb = CBCloudAPI(profile=argprofile)

# Get Container Runtime alerts from last 12 weeks
alerts = cb.select(ContainerRuntimeAlert).set_time_range('last_update_time', range="-12w")

for alert in alerts:
    print(alert.severity)

