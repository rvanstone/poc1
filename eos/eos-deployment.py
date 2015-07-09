def emptyOrNone(s):
    return s is None or len(s.strip()) == 0


def extract_nomura_pkgs(deltas):
    containers = {}
    for delta in deltas.deltas:
        delta_op = str(delta.operation)
        deployed = delta.previous if delta_op == "DESTROY" else delta.deployed
        if str(deployed.type) == "nomura.Package":
            container = deployed.container
            if not container.name in containers.keys():
                containers[container.name] = []
            containers[container.name].append(deployed)

    return containers


def generate_steps(containers, context):
    xml = """<deploy>\r"""
    for container_name, deployeds in containers.items():
        xml += "    <placement>\r"
        container = None
        for deployed in deployeds:
            container = deployed.container
            xml += "        <package groupId='%s' artifactId='%s' version='%s' />\r " % (deployed.groupId, deployed.artifactId, deployed.version)
        xml += "        <host key='%s'/>\r" % container.address
        xml += "    </placement>\r"
    xml += "</deploy>"

    step = steps.jython(description="Perform deployment using EOSLPS", script_path="eos/perform-deploy.py", jython_context={"xml":xml, "restEndpoint": deployedApplication.environment.eosRestApiUrl})
    if len(containers) > 0:
      context.addStep(step)

generate_steps(extract_nomura_pkgs(deltas), context)
