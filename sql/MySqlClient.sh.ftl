#!/bin/sh

<#import "/sql/commonFunctions.ftl" as cmn>
<#include "/generic/templates/linuxExportEnvVars.ftl">

<#if !cmn.lookup('username')??>
echo 'ERROR: username not specified! Specify it in either SqlScripts or its MySqlClient container'
exit 1
<#else>
"${deployed.container.mySqlHome}/bin/mysql" --user=${cmn.lookup('username')} <#if cmn.lookup('password')??>--password=${cmn.lookup('password')}</#if> ${cmn.lookup('additionalOptions')!} ${deployed.container.databaseName} < "${step.uploadedArtifactPath}"
res=$?
if [ $res != 0 ] ; then
        exit $res
fi
</#if>


