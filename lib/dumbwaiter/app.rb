require "dumbwaiter/deployment_custom_json"

class Dumbwaiter::App
  class NotFound < Exception; end

  attr_reader :stack, :opsworks_app, :opsworks

  def self.all(stack, opsworks = Aws::OpsWorks.new(region: "us-east-1"))
    opsworks.describe_apps(stack_id: stack.id).apps.map { |app| new(stack, app, opsworks) }
  end

  def self.find(stack, app_name, opsworks = Aws::OpsWorks.new(region: "us-east-1"))
    app = all(stack, opsworks).detect { |app| app.name == app_name }
    raise NotFound.new("No app found with name #{app_name}") if app.nil?
    app
  end

  def self.find_by_id(stack, app_id, opsworks = Aws::OpsWorks.new(region: "us-east-1"))
    app = all(stack, opsworks).detect { |app| app.id == app_id }
    raise NotFound.new("No app found with id #{app_id}") if app.nil?
    app
  end

  def initialize(stack, opsworks_app, opsworks = Aws::OpsWorks.new(region: "us-east-1"))
    @stack = stack
    @opsworks_app = opsworks_app
    @opsworks = opsworks
  end

  def name
    opsworks_app.name
  end

  def id
    opsworks_app.app_id
  end

  def deploy(revision = nil)
    deployment = as_deployment("deploy", args: {migrate: ["true"]})
    unless revision.nil?
      custom_json = Dumbwaiter::DeploymentCustomJson.create(name, revision)
      deployment[:custom_json] = custom_json.to_json
    end
    opsworks.create_deployment(deployment)
  end

  def rollback
    opsworks.create_deployment(as_deployment("rollback"))
  end

  protected

  def as_deployment(command_name, args = {})
    {
      app_id: id,
      stack_id: stack.id,
      command: {name: command_name}.merge(args),
    }
  end
end
