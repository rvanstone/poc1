@echo off
setlocal

<#include "/generic/templates/windowsSetEnvVars.ftl">
<#import "/sql/commonFunctions.ftl" as cmn>

<#assign DB2='"${deployed.container.db2Home}\\bin\\db2"' />
<#assign DB2CMD='"${deployed.container.db2Home}\\bin\\db2cmd"' />

<#if !cmn.lookup('username')??>
echo ${DB2} CONNECT TO ${deployed.container.databaseName} > wrapper.bat
<#else>
    <#if !cmn.lookup('password')??>
echo ${DB2} CONNECT TO ${deployed.container.databaseName} USER "${cmn.lookup('username')}" > wrapper.bat
    <#else>
echo ${DB2} CONNECT TO ${deployed.container.databaseName} USER "${cmn.lookup('username')}" USING "${cmn.lookup('password')}" > wrapper.bat
    </#if>
</#if>
echo ${DB2} ${cmn.lookup('additionalOptions')!} -tvf "${step.uploadedArtifactPath}" >> wrapper.bat
echo ${DB2} DISCONNECT ${deployed.container.databaseName} >> wrapper.bat

${DB2CMD} /c /i /w wrapper.bat

set RES=%ERRORLEVEL%
if not %RES% == 0 (
  exit %RES%
)

endlocal
