#!/bin/sh

<#import "/sql/commonFunctions.ftl" as cmn>

SYBASE_HOME="${deployed.container.sybHome}"
export SYBASE_HOME

# will override the declarations above if SYBASE_HOME or SYBASE_SID are present
<#include "/generic/templates/linuxExportEnvVars.ftl">
<#if !cmn.lookup('username')??>
echo 'ERROR: username not specified! Specify it in either SqlScripts or its OracleClient container'
exit 1
<#elseif !cmn.lookup('password')??>
echo 'ERROR: password not specified! Specify it in either SqlScripts or its OracleClient container'
exit 1
<#else>
# Connect to sybase - dbisql -c "uid=DBA;pwd=sql;eng=SERV1_iqdemo;links=tcpip(host=SERV2;port=1234)"
"${deployed.container.sybHome}/bin/dbisql" -c ${cmn.lookup('additionalOptions')!} uid=${cmn.lookup('username')};pwd=${cmn.lookup('password')};eng=${deployed.container.dbName};links=tcpip(host=${deployed.container.address};port=${deployed.container.port})" <<END_OF_WRAPPER
WHENEVER SQLERROR EXIT 1 ROLLBACK;
WHENEVER OSERROR EXIT 2 ROLLBACK;
@"${step.uploadedArtifactPath}"
END_OF_WRAPPER

res=$?
if [ $res != 0 ] ; then
        exit $res
fi
</#if>
