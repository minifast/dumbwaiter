require "thor"
require "aws-sdk-core"
require "dumbwaiter/deployment_custom_json"
require "dumbwaiter/stack"

module Dumbwaiter
  class Cli < Thor
    desc "deploy STACK_NAME APP_NAME GIT_REF", "Deploy an application revision"
    def deploy(stack_name, app_name, revision)
      stack = Stack.find(stack_name)
      app = App.find(stack, app_name)
      app.deploy(revision)
    rescue Dumbwaiter::Stack::NotFound, Dumbwaiter::App::NotFound => e
      raise Thor::Error.new(e.message)
    end

    desc "rollback STACK_NAME APP_NAME", "Roll back an application"
    def rollback(stack_name, app_name)
      stack = Stack.find(stack_name)
      app = App.find(stack, app_name)
      app.rollback
    rescue Dumbwaiter::Stack::NotFound, Dumbwaiter::App::NotFound => e
      raise Thor::Error.new(e.message)
    end

    desc "list STACK_NAME", "List all the deployments for a stack"
    def list(stack_name)
      stack = Stack.find(stack_name)

      deployments = stack.deployments.select do |deployment|
        %w(rollback deploy).include?(deployment.command_name)
      end

      deployments.each do |deployment|
        Kernel.puts(deployment.to_log)
      end
    rescue Dumbwaiter::Stack::NotFound => e
      raise Thor::Error.new(e.message)
    end

    desc "stacks", "List all the stacks"
    def stacks
      Stack.all.each { |stack| Kernel.puts("#{stack.name}: #{stack.apps.map(&:name).join(', ')}") }
    end
  end
end
