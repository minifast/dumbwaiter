require "thor"
require "aws-sdk-core"
require "dumbwaiter/deployment_custom_json"

module Dumbwaiter
  class Cli < Thor
    class MissingStack < Error; end
    class MissingApp < Error; end

    desc "deploy STACK_NAME APP_NAME GIT_REF", "Deploy an application revision"
    def deploy(stack_name, app_name, revision)
      stack_id = stack_id_for_name(stack_name)
      custom_json = DeploymentCustomJson.create(app_name, revision).to_json
      opsworks.create_deployment(
        stack_id: stack_id,
        app_id: app_id_for_name(stack_id, app_name),
        command: {name: "deploy", args: {migrate: ["true"]}},
        custom_json: custom_json
      )
    end

    desc "rollback STACK_NAME APP_NAME", "Roll back an application"
    def rollback(stack_name, app_name)
      stack_id = stack_id_for_name(stack_name)
      opsworks.create_deployment(
        stack_id: stack_id,
        app_id: app_id_for_name(stack_id, app_name),
        command: {name: "rollback"}
      )
    end

    desc "list STACK_NAME", "List all the deployments for a stack"
    def list(stack_name)
      stack_id = stack_id_for_name(stack_name)
      app_deployments = deployments(stack_id).select do |deployment|
        %w(rollback deploy).include?(deployment.command.name)
      end

      app_deployments.each do |deployment|
        custom_json = DeploymentCustomJson.from_json(deployment.custom_json || "{}")
        Kernel.puts "#{deployment.created_at} - #{deployment.command.name} - #{deployment.status} - #{custom_json.git_ref}"
      end
    end

    no_tasks do
      def app_id_for_name(stack_id, app_name)
        app_id = app_ids_by_name(stack_id)[app_name]
        raise MissingApp.new("No app named #{app_name}") unless app_id
        app_id
      end

      def stack_id_for_name(stack_name)
        stack_id = stack_ids_by_name[stack_name]
        raise MissingStack.new("No stack named #{stack_name}") unless stack_id
        stack_id
      end

      def stack_ids_by_name
        @stack_ids_by_name ||= stacks.reduce({}) do |result, stack|
          result[stack.name] = stack.stack_id
          result
        end
      end

      def app_ids_by_name(stack_id)
        apps(stack_id).reduce({}) do |result, app|
          result[app.name] = app.app_id
          result
        end
      end

      def stacks
        @stacks ||= opsworks.describe_stacks.stacks
      end

      def apps(stack_id)
        @apps ||= {}
        @apps[stack_id] ||= opsworks.describe_apps(stack_id: stack_id).apps
      end

      def deployments(stack_id)
        @deployments ||= {}
        @deployments[stack_id] ||= opsworks.describe_deployments(stack_id: stack_id).deployments
      end

      def opsworks
        @opsworks ||= Aws::OpsWorks.new(region: "us-east-1")
      end
    end
  end
end
