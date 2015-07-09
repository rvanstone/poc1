#!/bin/sh

<#include "/generic/templates/linuxExportEnvVars.ftl">
<#import "/sql/commonFunctions.ftl" as cmn>

DB2_COMMAND="${deployed.container.db2Home}/bin/db2"

<#if !cmn.lookup('username')??>
$DB2_COMMAND CONNECT TO ${deployed.container.databaseName}
<#else>
  <#if !cmn.lookup('password')??>
$DB2_COMMAND CONNECT TO ${deployed.container.databaseName} USER "${cmn.lookup('username')}"
  <#else>
$DB2_COMMAND CONNECT TO ${deployed.container.databaseName} USER "${cmn.lookup('username')}" USING "${cmn.lookup('password')}"
  </#if>
</#if>
res=$?
if [ $res != 0 ] ; then
        exit $res
fi

$DB2_COMMAND ${cmn.lookup('additionalOptions')!} -tvf "${step.uploadedArtifactPath}"
res=$?
if [ $res != 0 ] ; then
        exit $res
fi

$DB2_COMMAND DISCONNECT ${deployed.container.databaseName}
res=$?
if [ $res != 0 ] ; then
        exit $res
fi
