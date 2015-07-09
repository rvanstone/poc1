@echo off
setlocal

<#import "/sql/commonFunctions.ftl" as cmn>
<#include "/generic/templates/windowsSetEnvVars.ftl">

<#if !cmn.lookup('username')??>
echo 'ERROR: username not specified! Specify it in either SqlScripts or its MySqlClient container'
endlocal
exit /B 1
<#else>

"${deployed.container.mySqlHome}\bin\mysql" --user=${cmn.lookup('username')} <#if cmn.lookup('password')??>--password=${cmn.lookup('password')}</#if> ${cmn.lookup('additionalOptions')!} ${deployed.container.databaseName} < "${step.uploadedArtifactPath}"

set RES=%ERRORLEVEL%
if not %RES% == 0 (
  exit %RES%
)

endlocal
</#if>

