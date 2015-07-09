<#function lookup p>
  <#if deployed?? >
      <#if deployed[p]?? >
          <#return deployed[p] />
      <#else>
          <#return deployed.container[p] />
      </#if>
  <#else>
      <#return container[p] />
  </#if>
</#function>
