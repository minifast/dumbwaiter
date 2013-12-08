require "thor"
require "aws-sdk-core"

module Dumbwaiter
  class Cli < Thor
    attr_writer :opsworks

    class MissingStack < Error; end

    desc "deploy STACK_NAME APP_NAME GIT_REF", "Deploy an application revision"
    def deploy(stack_name, app_name, revision)
      opsworks.create_deployment(
        stack_id: stack_id_for_name(stack_name),
        command: {name: "deploy"},
        custom_json: {deploy: {app_name => {scm: {revision: revision}}}}.to_json
      )
    end

    desc "rollback STACK_NAME", "Roll back an entire stack"
    def rollback(stack_name)
      opsworks.create_deployment(
        stack_id: stack_id_for_name(stack_name),
        command: {name: "rollback"}
      )
    end

    desc "list STACK_NAME", "Roll back an entire stack"
    def list(stack_name)
      stack_id = stack_id_for_name(stack_name)
      opsworks.describe_deployments(stack_id: stack_id).map do |deployment|
        revision = JSON.parse(deployment[:custom_json])["deploy"].values.first["scm"]["revision"]
        Kernel.puts "#{deployment[:created_at]} - #{revision} - #{deployment[:status]}"
      end
    end

    no_tasks do
      def stack_id_for_name(stack_name)
        stack_id = stack_ids_by_name[stack_name]
        raise MissingStack.new("No stack named #{stack_name}") unless stack_id
        stack_id
      end

      def stack_ids_by_name
        @stack_ids_by_name ||= stacks.reduce({}) do |result, stack|
          result[stack[:name]] = stack[:stack_id]
          result
        end
      end

      def stacks
        opsworks.describe_stacks
      end

      def opsworks
        @opsworks ||= Aws::OpsWorks.new(region: "us-east-1")
      end
    end
  end
end
