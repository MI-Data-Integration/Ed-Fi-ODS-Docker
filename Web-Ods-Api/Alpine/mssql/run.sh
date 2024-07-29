#!/bin/bash
# SPDX-License-Identifier: Apache-2.0
# Licensed to the Ed-Fi Alliance under one or more agreements.
# The Ed-Fi Alliance licenses this file to you under the Apache License, Version 2.0.
# See the LICENSE and NOTICES files in the project root for more information.

set -e
set +x

if [[ "$TPDM_ENABLED" != true ]]; then
    export Plugin__Folder="./Plugin_Disabled"
fi

if [ -z "$LOG4NET_SCHEMA" ]; then
    LOG4NET_SCHEMA="api"
fi

envsubst < /app/appsettings.template.json > /app/appsettings.json
envsubst < /app/log4net.template.$LOG4NET_SCHEMA.config > /app/log4net.config

if [ "$DEBUG" == "true" ]; then
    cat ./appsettings.json;
    cat ./log4net.config;
fi

dotnet EdFi.Ods.WebApi.dll
