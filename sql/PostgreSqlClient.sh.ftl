#!/bin/sh

<#import "/sql/commonFunctions.ftl" as cmn>
<#include "/generic/templates/linuxExportEnvVars.ftl">

<#if deployed??>
    <#assign container=deployed.container>
</#if>

<#if (container.useLocalhost)>
    <#assign hostname="localhost">
<#else>
    <#assign hostname="${container.host.address}">
</#if>

<#if !cmn.lookup('username')??>
echo 'ERROR: username not specified! Specify it in either SqlScripts or its PostgreSqlClient container'
exit 1
<#else>
<#if cmn.lookup('password')??>
TMP_PGPASS=`pwd`/tmp-pgpass
echo ${hostname}:${container.port}:${container.databaseName}:${cmn.lookup('username')}:${cmn.lookup('password')} > $TMP_PGPASS
chmod 600 $TMP_PGPASS
export PGPASSFILE=$TMP_PGPASS
</#if>

<#if params??>
echo "${params.testSqlStatement}" > test.sql
    <#assign file="test.sql">
<#else>
    <#assign file="${step.uploadedArtifactPath}">
</#if>

"${container.postgreSqlHome}/bin/psql" --set ON_ERROR_STOP=1 --dbname=${container.databaseName} --host=${hostname} --port=${container.port} --username=${cmn.lookup('username')} --no-password ${cmn.lookup('additionalOptions')!} --file=${file}

res=$?
if [ $res != 0 ] ; then
        exit $res
fi
</#if>
