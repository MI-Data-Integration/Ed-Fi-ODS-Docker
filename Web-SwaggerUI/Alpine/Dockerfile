# SPDX-License-Identifier: Apache-2.0
# Licensed to the Ed-Fi Alliance under one or more agreements.
# The Ed-Fi Alliance licenses this file to you under the Apache License, Version 2.0.
# See the LICENSE and NOTICES files in the project root for more information.

FROM mcr.microsoft.com/dotnet/aspnet:8.0-alpine AS base
RUN apk --no-cache add unzip=~6 dos2unix=~7 bash=~5 gettext=~0 icu=~74 curl=~8 && \
    addgroup -S edfi && adduser -S edfi -G edfi

# Start a new layer so that the above layer can be cached
FROM base AS build

LABEL maintainer="Ed-Fi Alliance, LLC and Contributors <techsupport@ed-fi.org>"

ENV VERSION="6.2.2329"
ENV DOCS_VIRTUAL_NAME=docs
ENV ODS_VIRTUAL_NAME=api
ENV WebApiVersionUrl="https://localhost/${ODS_VIRTUAL_NAME}/"
ENV UseReverseProxyHeaders=true
ENV PathBase="${DOCS_VIRTUAL_NAME}"

# Alpine image does not contain Globalization Cultures library so we need to install ICU library to get fopr LINQ expression to work
# Disable the globaliztion invariant mode (set in base image)
ENV DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=false

WORKDIR /app
COPY --chmod=600 appsettings.template.json /app/appsettings.template.json
COPY --chmod=500 run.sh /app/run.sh

COPY app.zip /app/SwaggerUI.zip

RUN umask 0077 && \
    unzip /app/SwaggerUI.zip -d /app && \
    rm -f /app/SwaggerUI.zip && \
    dos2unix /app/*.json && \
    dos2unix /app/*.sh && \
    rm -f /app/*.exe && \
    apk del unzip dos2unix curl && \
    chown -R edfi /app

EXPOSE 8080
USER edfi
ENTRYPOINT ["/app/run.sh"]
