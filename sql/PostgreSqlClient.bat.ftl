@echo off
setlocal

<#import "/sql/commonFunctions.ftl" as cmn>
<#include "/generic/templates/windowsSetEnvVars.ftl">

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
endlocal
exit /B 1
<#else>
<#if cmn.lookup('password')??>
set TMP_PGPASS=%CD%/tmp-pgpass.conf
echo ${hostname}:${container.port}:${container.databaseName}:${cmn.lookup('username')}:${cmn.lookup('password')}>%TMP_PGPASS%
set PGPASSFILE=%TMP_PGPASS%
</#if>

<#if params??>
echo ${params.testSqlStatement}>test.sql
    <#assign file="test.sql">
<#else>
    <#assign file="${step.uploadedArtifactPath}">
</#if>

"${container.postgreSqlHome}\bin\psql" --set ON_ERROR_STOP=1 --dbname=${container.databaseName} --host=${hostname} --port=${container.port} --username=${cmn.lookup('username')} --no-password ${cmn.lookup('additionalOptions')!} --file="${file}"

endlocal
set RES=%ERRORLEVEL%
if not %RES% == 0 (
exit %RES%
)
</#if>
