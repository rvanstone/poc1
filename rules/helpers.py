from com.xebialabs.deployit.plugin.generic.step import ScriptExecutionStep
import re
from os.path import exists, join, isfile
from os import listdir
from java.io import File


class deployed_helper:
    def __init__(self, deployed):
        self.deployed = deployed
        self.__deployed = deployed._delegate
        self.script_pattern = re.compile(self.deployed.scriptRecognitionRegex)
        self.rollback_pattern = re.compile(self.deployed.rollbackScriptRecognitionRegex)
        self.artifact_folder = deployed.getFile().path

    def __list_scripts(self, func):
        return [ff for ff in listdir(self.artifact_folder) if isfile(self.path_of(ff)) and func(ff)]

    def list_create_scripts(self):
        return self.__list_scripts(self.is_create_script)

    def list_rollback_scripts(self):
        return self.__list_scripts(self.is_rollback_script)

    def rollback_script_for(self, script_name):
        if self.is_create_script(script_name):
            rollback_script = self.script_pattern.match(script_name).group(1) + self.deployed.rollbackScriptPostfix
            return rollback_script if exists(self.path_of(rollback_script)) else None
        else:
            raise Exception("Expected a create script, got " + script_name)

    def path_of(self, script_name):
        return join(self.artifact_folder, script_name)

    def is_script(self, script_name):
        return self.is_create_script(script_name) or self.is_rollback_script(script_name)

    def is_create_script(self, script_name):
        return True if self.script_pattern.match(script_name) else False

    def is_rollback_script(self, script_name):
        return True if self.rollback_pattern.match(script_name) else False

    def extract_checkpointname(self, script_name):
        match = self.script_pattern.match(script_name)
        if not match:
            rollback_match = self.rollback_pattern.match(script_name)
            postfix = self.deployed.rollbackScriptPostfix
            rm = rollback_match.group(0) if rollback_match else None
            print rm
            rm = rm[:-len(postfix)] if rm and rm.endswith(postfix) else None
            print rm
            return rm
        else:
            return match.group(1) if match else None

    def create_script_step(self, script, options=None):
        if not options:
            options = self.deployed.createOptions
        step = self.__script_step(script, self.deployed.createOrder, "Run")
        self.__add_script_resources(step, script, self.script_pattern)
        self.__add_optional_resources(step, options, script)
        return step

    def destroy_script_step(self, script, options=None):
        if not options:
            options = self.deployed.destroyOptions
        step = self.__script_step(script, self.deployed.destroyOrder, "Rollback")
        self.__add_script_resources(step, script, self.rollback_pattern)
        self.__add_optional_resources(step, options, script)
        return step

    def __script_step(self, script, order, verb):
        step = ScriptExecutionStep(
            order,
            self.deployed.getExecutorScript(),
            self.deployed.container._delegate,  # Evil, we need to do our own unwrapping here.
            {'deployed': self.__deployed},
            "%s %s on %s" % (verb, script, self.deployed.container.name))

        # Common resources
        common_resource_path = self.path_of(self.deployed.commonScriptFolderName)
        if exists(common_resource_path):
            step.fileResources.add(File(common_resource_path))

        return step

    def __add_script_resources(self, step, script, regex):
        m = regex.match(script)
        script_resource = self.path_of(m.group(1))
        if m and exists(script_resource):
            step.fileResources.add(File(script_resource))

    def __add_optional_resources(self, step, options, script):
        if "uploadTemplateClasspathResources" in options:
            step.getTemplateClasspathResources().addAll(self.__deployed.getTemplateClasspathResources())
        if "uploadClasspathResources" in options:
            step.getClasspathResources().addAll(self.__deployed.getClasspathResources())
        if "uploadArtifactData" in options:
            step.setArtifact(File(self.path_of(script)))
