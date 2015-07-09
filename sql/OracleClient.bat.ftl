@echo off
setlocal

<#import "/sql/commonFunctions.ftl" as cmn>
<#include "/generic/templates/windowsSetEnvVars.ftl">

set ORACLE_HOME=${deployed.container.oraHome}

echo WHENEVER SQLERROR EXIT 1 ROLLBACK; > wrapper.sql
echo WHENEVER OSERROR EXIT 2 ROLLBACK; >> wrapper.sql
echo @"${step.uploadedArtifactPath}" >> wrapper.sql

<#if !cmn.lookup('username')??>
echo 'ERROR: username not specified! Specify it in either SqlScripts or its OracleClient container'
endlocal
exit /B 1
<#elseif !cmn.lookup('password')??>
echo 'ERROR: password not specified! Specify it in either SqlScripts or its OracleClient container'
endlocal
exit /B 1
<#else>

echo EXIT | "${deployed.container.oraHome}\bin\sqlplus" ${cmn.lookup('additionalOptions')!} -L ${cmn.lookup('username')}/${cmn.lookup('password')}@${deployed.container.sid} @wrapper.sql

set RES=%ERRORLEVEL%
if not %RES% == 0 (
  exit %RES%
)

endlocal
</#if>
